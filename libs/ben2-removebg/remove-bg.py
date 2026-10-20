#!/usr/bin/env python

import argparse
import copy
import os
import queue
import subprocess
import sys
import threading
from pathlib import Path

import cv2
import numpy as np
import torch
import torch.nn.functional as F
from ben2 import BEN_Base
from ben2.modeling_ben2 import (
    add_audio_to_video,
    img_transform,
    img_transform32,
    refine_foreground_process,
    rgb_loader_refiner,
)
from PIL import Image
from tqdm import tqdm



def parse_args():
    parser = argparse.ArgumentParser(
        description="Entfernt den Hintergrund aus Videos mittels offiziellem BEN2 segment_video."
    )
    parser.add_argument(
        "--input", "-i", type=str, required=True, help="Pfad zum Quellvideo (z.B. input.mp4)"
    )
    parser.add_argument(
        "--output-dir",
        "-o",
        type=str,
        default=None,
        help="Ausgabeordner oder Zieldatei (Format wird aus der Dateiendung erkannt)",
    )
    parser.add_argument(
        "--mask-only",
        action="store_true",
        help=(
            "Gibt nur die Alpha-Maske als Graustufen-Video aus (weiß=Vordergrund, "
            "schwarz=Hintergrund; Format wird aus der Dateiendung erkannt)"
        ),
    )
    parser.add_argument(
        "--bg-color",
        type=str,
        default="0,255,0",
        help="Hintergrundfarbe für MP4 als R,G,B (Standard: 0,255,0 für Greenscreen)",
    )
    parser.add_argument(
        "--batch",
        type=int,
        default=1,
        help="Anzahl paralleler Worker/Modell-Kopien (Empfehlung: 1 bis max. 3 für Endverbraucher-GPUs)",
    )
    parser.add_argument(
        "--refine",
        action="store_true",
        help="Aktiviert 'refine_foreground' für saubere Kanten (dauert etwas länger)",
    )
    parser.add_argument(
        "--alpha-threshold",
        type=float,
        default=0.5,
        metavar="0..1",
        help=(
            "Verwirft BEN2-Sigmoid-Alpha-Werte unter diesem Wert (0..1; Standard: 0.5). "
            "Höher reduziert schwache Fehlmasken, kann aber feine Kanten entfernen."
        ),
    )
    parser.add_argument(
        "--min-region-area",
        type=int,
        default=64,
        metavar="PIXELS",
        help="Kleinste verbundene Maskenregion auf dem 1024x1024 BEN2-Maskenraster (Standard: 64)",
    )
    parser.add_argument(
        "--all-regions",
        action="store_true",
        help="Behält statt nur der größten auch andere Regionen ab --min-region-area",
    )
    parser.add_argument(
        "--temporal-smoothing",
        type=float,
        default=0.2,
        metavar="0..1",
        help=(
            "Anteil der vorherigen Maske zur zeitlichen Stabilisierung (Standard: 0.2; "
            "0 deaktiviert, höhere Werte können Nachzieheffekte verursachen)"
        ),
    )
    return validate_args(parser.parse_args())


def validate_args(args):
    if not 0 <= args.alpha_threshold <= 1:
        raise SystemExit("Fehler: --alpha-threshold muss zwischen 0 und 1 liegen.")
    if args.min_region_area < 0:
        raise SystemExit("Fehler: --min-region-area darf nicht negativ sein.")
    if not 0 <= args.temporal_smoothing < 1:
        raise SystemExit("Fehler: --temporal-smoothing muss zwischen 0 (inklusive) und 1 (exklusive) liegen.")
    return args


def _clean_mask(mask, alpha_threshold, min_region_area, keep_largest):
    """Suppress weak alpha and disconnected noise on BEN2's 1024x1024 mask grid."""
    alpha = np.asarray(mask, dtype=np.uint8)
    threshold = max(1, int(round(alpha_threshold * 255)))
    alpha = np.where(alpha >= threshold, alpha, 0).astype(np.uint8)
    if min_region_area == 0 and not keep_largest:
        return alpha
    binary = (alpha > 0).astype(np.uint8)
    count, labels, stats, _ = cv2.connectedComponentsWithStats(binary, connectivity=8)
    if count <= 1:
        return np.where(binary, alpha, 0).astype(np.uint8)

    component_areas = stats[1:, cv2.CC_STAT_AREA]
    largest_label = int(np.argmax(component_areas)) + 1
    keep = np.zeros(count, dtype=bool)
    for label in range(1, count):
        area = int(stats[label, cv2.CC_STAT_AREA])
        keep[label] = area >= min_region_area and (not keep_largest or label == largest_label)
    return np.where(keep[labels], alpha, 0).astype(np.uint8)


class TemporalMaskStabilizer:
    def __init__(self, smoothing, alpha_threshold, scene_cut_threshold=40):
        self.smoothing = smoothing
        self.alpha_threshold = int(round(alpha_threshold * 255))
        self.scene_cut_threshold = scene_cut_threshold
        self.previous_mask = None
        self.previous_frame = None

    def apply(self, image):
        if self.smoothing == 0 or image.mode != "RGBA":
            return image
        rgba = np.asarray(image).copy()
        frame = cv2.resize(rgba[:, :, :3], (160, 90), interpolation=cv2.INTER_AREA)
        mask = rgba[:, :, 3]
        scene_cut = False
        if self.previous_frame is not None:
            difference = cv2.absdiff(frame, self.previous_frame).mean()
            scene_cut = difference >= self.scene_cut_threshold
        if self.previous_mask is not None and not scene_cut:
            mask = cv2.addWeighted(
                mask, 1.0 - self.smoothing, self.previous_mask, self.smoothing, 0
            )
            mask[mask < self.alpha_threshold] = 0
            rgba[:, :, 3] = mask
        self.previous_mask = mask.copy()
        self.previous_frame = frame
        return Image.fromarray(rgba, mode="RGBA")


# Handle Pillow versions that predate Image.Resampling.
_RESAMPLING_BILINEAR = getattr(getattr(Image, "Resampling", Image), "BILINEAR")


def _make_output_mask(result, output_size, alpha_threshold, min_region_area, keep_largest):
    """Resize BEN2's sigmoid probability map without per-frame min/max scaling."""
    probability = torch.squeeze(
        F.interpolate(result, size=(1024, 1024), mode="bilinear", align_corners=False),
        0,
    )
    alpha = (
        probability.clamp(0.0, 1.0)
        .mul(255.0)
        .round()
        .to(torch.uint8)
        .squeeze()
        .cpu()
        .numpy()
    )
    alpha = _clean_mask(alpha, alpha_threshold, min_region_area, keep_largest)
    return Image.fromarray(alpha, mode="L").resize(output_size, _RESAMPLING_BILINEAR)


def parse_color(color_str):
    try:
        parts = [int(c.strip()) for c in color_str.split(",")]
        if len(parts) != 3 or not all(0 <= p <= 255 for p in parts):
            raise ValueError
        return (parts[0], parts[1], parts[2])
    except ValueError:
        raise SystemExit(
            "Fehler: --bg-color muss im Format 'R,G,B' angegeben werden (z. B. '0,255,0')."
        )


def _as_frame_list(batch_results):
    if isinstance(batch_results, Image.Image):
        return [batch_results]
    return batch_results


def _gpu_inference(
    model, pil_image, refine, alpha_threshold, min_region_area, keep_largest
):
    """Run BEN2 and apply mask cleanup before full-resolution upscaling."""
    image, h, w, original_image = rgb_loader_refiner(pil_image)
    if torch.cuda.is_available():
        img_tensor = img_transform(image).unsqueeze(0).to(next(model.parameters()).device)
    else:
        img_tensor = img_transform32(image).unsqueeze(0).to(next(model.parameters()).device)

    with torch.no_grad():
        res = model.forward(img_tensor)

    mask = _make_output_mask(
        res, original_image.size, alpha_threshold, min_region_area, keep_largest
    )
    if not refine:
        original_image.putalpha(mask)
        return original_image

    # Refine foreground using the cleaned mask at full resolution.
    return (original_image, mask)


def _refine_on_cpu(item):
    frame_idx, (original_image, mask) = item
    image_masked = refine_foreground_process(original_image, mask)
    image_masked.putalpha(mask)
    return frame_idx, image_masked


def _inference_worker(
    work_queue,
    refine_queue,
    result_queue,
    model,
    refine,
    alpha_threshold,
    min_region_area,
    keep_largest,
):
    out_queue = refine_queue if refine_queue is not None else result_queue
    while True:
        item = work_queue.get()
        try:
            if item is None:
                return
            frame_idx, pil_image = item
            out_queue.put(
                (
                    frame_idx,
                    _gpu_inference(
                        model,
                        pil_image,
                        refine,
                        alpha_threshold,
                        min_region_area,
                        keep_largest,
                    ),
                )
            )
        except Exception as exc:
            # Bypass the pipeline so a dead GPU worker surfaces immediately.
            result_queue.put(exc)
            return
        finally:
            work_queue.task_done()


def _refine_worker(refine_queue, result_queue):
    while True:
        item = refine_queue.get()
        try:
            if item is None:
                return
            result_queue.put(_refine_on_cpu(item))
        except Exception as exc:
            result_queue.put(exc)
            return
        finally:
            refine_queue.task_done()


def _drain_results(
    result_queue,
    writer,
    pending,
    next_write_idx,
    block,
    total_frames,
    progress,
    stabilizer=None,
):
    while next_write_idx < total_frames:
        while next_write_idx in pending:
            for foreground in _as_frame_list(pending.pop(next_write_idx)):
                if stabilizer is not None:
                    foreground = stabilizer.apply(foreground)
                writer.write(foreground)
            progress.update(1)
            next_write_idx += 1

        if next_write_idx >= total_frames:
            break

        try:
            item = result_queue.get() if block else result_queue.get_nowait()
        except queue.Empty:
            break
        if isinstance(item, Exception):
            raise item
        pending[item[0]] = item[1]

    return next_write_idx


class Mp4FrameWriter:
    def __init__(self, output_path, fps, size, rgb_value):
        width, height = size
        Path(output_path).parent.mkdir(parents=True, exist_ok=True)
        fourcc = cv2.VideoWriter_fourcc(*"mp4v")
        self._writer = cv2.VideoWriter(str(output_path), fourcc, fps, (width, height))
        if not self._writer.isOpened():
            raise IOError("Cannot open MP4 writer: {}".format(output_path))
        self._background = Image.new("RGBA", size, rgb_value + (255,))

    def write(self, image):
        if image.mode == "RGBA":
            frame = Image.alpha_composite(self._background, image).convert("RGB")
        else:
            frame = image.convert("RGB")
        self._writer.write(cv2.cvtColor(np.array(frame), cv2.COLOR_RGB2BGR))

    def close(self):
        self._writer.release()


class MaskVideoWriter:
    """Write the alpha channel as a grayscale video (white foreground, black background)."""

    def __init__(self, output_path, fps, size):
        width, height = size
        Path(output_path).parent.mkdir(parents=True, exist_ok=True)
        fourcc = cv2.VideoWriter_fourcc(*"mp4v")
        self._writer = cv2.VideoWriter(str(output_path), fourcc, fps, (width, height), isColor=False)
        if not self._writer.isOpened():
            raise IOError("Cannot open mask video writer: {}".format(output_path))

    def write(self, image):
        alpha = np.asarray(image.convert("RGBA"))[:, :, 3]
        self._writer.write(alpha)

    def close(self):
        self._writer.release()


class WebmWriter:
    def __init__(self, output_path, fps, size, mask_only=False):
        width, height = size
        Path(output_path).parent.mkdir(parents=True, exist_ok=True)
        self._output_path = str(output_path)
        self._mask_only = mask_only
        input_pixel_format = "gray" if mask_only else "rgba"
        output_pixel_format = "yuv420p" if mask_only else "yuva420p"
        try:
            self._proc = subprocess.Popen(
                [
                    "ffmpeg",
                    "-hide_banner",
                    "-loglevel",
                    "error",
                    "-y",
                    "-f",
                    "rawvideo",
                    "-pix_fmt",
                    input_pixel_format,
                    "-s",
                    "{}x{}".format(width, height),
                    "-r",
                    str(fps),
                    "-i",
                    "pipe:0",
                    "-an",
                    "-c:v",
                    "libvpx-vp9",
                    "-pix_fmt",
                    output_pixel_format,
                    "-auto-alt-ref",
                    "0",
                    self._output_path,
                ],
                stdin=subprocess.PIPE,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.PIPE,
            )
        except FileNotFoundError as exc:
            raise RuntimeError("ffmpeg not found; required for WebM output") from exc

    def write(self, image):
        if self._mask_only:
            frame = np.asarray(image.convert("RGBA"))[:, :, 3]
        else:
            frame = np.asarray(image.convert("RGBA"))
        try:
            self._proc.stdin.write(frame.tobytes())
        except BrokenPipeError as exc:
            stderr = self._proc.stderr.read().decode("utf-8", errors="replace")
            raise RuntimeError("ffmpeg failed while writing WebM: {}".format(stderr)) from exc

    def close(self):
        if self._proc.stdin is not None:
            self._proc.stdin.close()
        stderr = self._proc.stderr.read().decode("utf-8", errors="replace")
        return_code = self._proc.wait()
        if return_code != 0:
            raise RuntimeError("ffmpeg failed ({}): {}".format(return_code, stderr))
        print("WebM saved to {}".format(self._output_path))

def segment_video(
    model,
    video_path,
    output_path="./",
    fps=0,
    refine_foreground=False,
    batch=1,
    rgb_value=(0, 255, 0),
    alpha_threshold=0.5,
    min_region_area=64,
    keep_largest=True,
    temporal_smoothing=0.2,
    mask_only=False,
):
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        raise IOError("Cannot open video: {}".format(video_path))

    original_fps = cap.get(cv2.CAP_PROP_FPS)
    original_fps = 30 if original_fps == 0 else original_fps
    fps = original_fps if fps == 0 else fps

    ret, first_frame = cap.read()
    if not ret:
        cap.release()
        raise ValueError("No frames found in the video.")
    height, width = first_frame.shape[:2]
    cap.set(cv2.CAP_PROP_POS_FRAMES, 0)

    output_path = Path(output_path)
    default_name = "foreground-mask.mp4" if mask_only else "foreground.mp4"
    if output_path.is_dir() or str(output_path).endswith(("/", "\\")):
        output_file = output_path / default_name
    elif output_path.suffix.lower() in {".mp4", ".webm"}:
        output_file = output_path
    elif output_path.suffix:
        output_file = output_path.with_suffix(".mp4")
    else:
        output_file = output_path / default_name
    webm = output_file.suffix.lower() == ".webm"

    writer = None
    progress = None
    num_workers = max(1, batch)
    total_frames_expected = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    models = [copy.deepcopy(model) for _ in range(num_workers - 1)] + [model]
    work_queue = queue.Queue(maxsize=num_workers * 3)
    result_queue = queue.Queue()
    pending = {}
    next_write_idx = 0
    stabilizer = TemporalMaskStabilizer(temporal_smoothing, alpha_threshold)

    # With --refine the blur-fusion pass is pure CPU work; run it in its own
    # workers so it never blocks a GPU worker between forward passes.
    refine_workers = []
    refine_queue = None
    if refine_foreground:
        num_refine_workers = max(1, (os.cpu_count() or 2) // 2)
        refine_queue = queue.Queue(maxsize=num_refine_workers * 2)
        refine_workers = [
            threading.Thread(
                target=_refine_worker,
                args=(refine_queue, result_queue),
                daemon=True,
            )
            for _ in range(num_refine_workers)
        ]

    workers = [
        threading.Thread(
            target=_inference_worker,
            args=(
                work_queue,
                refine_queue,
                result_queue,
                worker_model,
                refine_foreground,
                alpha_threshold,
                min_region_area,
                keep_largest,
            ),
            daemon=True,
        )
        for worker_model in models
    ]

    try:
        if webm:
            writer = WebmWriter(output_file, fps, (width, height), mask_only=mask_only)
        elif mask_only:
            writer = MaskVideoWriter(output_file, fps, (width, height))
        else:
            writer = Mp4FrameWriter(output_file, fps, (width, height), rgb_value)

        for worker in workers + refine_workers:
            worker.start()

        # CAP_PROP_FRAME_COUNT is often 0 or plain wrong for some containers;
        # the real count is set after reading below so the bar ends at 100%.
        total = max(total_frames_expected, 1)
        progress = tqdm(total=total, desc="Segmenting frames", unit="frame")

        frame_idx = 0
        while True:
            ret, frame = cap.read()
            if not ret:
                break
            frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            while True:
                try:
                    work_queue.put((frame_idx, Image.fromarray(frame_rgb)), timeout=1)
                    break
                except queue.Full:
                    pass
                # Drain while feeding: if a worker died, its exception is
                # sitting on result_queue and must not be stuck behind a
                # full work_queue.
                next_write_idx = _drain_results(
                    result_queue,
                    writer,
                    pending,
                    next_write_idx,
                    block=False,
                    total_frames=frame_idx,
                    progress=progress,
                    stabilizer=stabilizer,
                )
            frame_idx += 1
            next_write_idx = _drain_results(
                result_queue,
                writer,
                pending,
                next_write_idx,
                block=False,
                total_frames=frame_idx,
                progress=progress,
                stabilizer=stabilizer,
            )

        total_frames = frame_idx
        progress.total = total_frames
        progress.refresh()

        # Drain everything the workers produced for frames we already fed
        # before asking any worker to shut down; a worker exception raised
        # here tears the pipeline down without waiting on joins.
        while next_write_idx < total_frames:
            next_write_idx = _drain_results(
                result_queue,
                writer,
                pending,
                next_write_idx,
                block=True,
                total_frames=total_frames,
                progress=progress,
                stabilizer=stabilizer,
            )

        for _ in range(num_workers):
            while True:
                try:
                    work_queue.put(None, timeout=1)
                    break
                except queue.Full:
                    pass
        # Join GPU workers before poisoning the refine stage: their last
        # results may still land on refine_queue after the read loop ends.
        for worker in workers:
            worker.join()

        if refine_queue is not None:
            for _ in refine_workers:
                while True:
                    try:
                        refine_queue.put(None, timeout=1)
                        break
                    except queue.Full:
                        pass

        progress.close()

        for worker in refine_workers:
            worker.join()
    finally:
        if progress is not None:
            progress.close()
        cap.release()
        if writer is not None:
            writer.close()

    if output_file.suffix.lower() != ".webm" and not mask_only:
        try:
            audio_output = output_file.with_name(
                "{}_output_with_audio{}".format(output_file.stem, output_file.suffix)
            )
            add_audio_to_video(str(output_file), video_path, str(audio_output))
            audio_output.replace(output_file)
        except Exception as e:
            print("No audio found in the original video")
            print(e)

    return str(output_file)


def main():
    print("Python version:", sys.version)
    args = parse_args()
    video_path = Path(args.input)
    output_path = Path(args.output_dir).resolve() if args.output_dir else video_path.parent
    default_name = "foreground-mask.mp4" if args.mask_only else "foreground.mp4"
    if output_path.is_dir() or str(output_path).endswith(("/", "\\")):
        expected_output = output_path / default_name
    elif output_path.suffix.lower() in {".mp4", ".webm"}:
        expected_output = output_path
    elif output_path.suffix:
        expected_output = output_path.with_suffix(".mp4")
    else:
        expected_output = output_path / default_name

    webm = expected_output.suffix.lower() == ".webm"
    if args.mask_only:
        output_format = "Graustufen-WebM" if webm else "Graustufen-MP4"
    else:
        output_format = (
            "Transparente WebM mit Alpha-Kanal"
            if webm
            else "MP4 mit Hintergrund {}".format(parse_color(args.bg_color))
        )
    if not video_path.exists():
        raise SystemExit("Fehler: Die Datei '{}' existiert nicht.".format(video_path))

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print("Gerät: {}".format(device))

    print("Lade BEN2 Modellgewichte von HuggingFace (PramaLLC/BEN2)...")
    model = BEN_Base.from_pretrained("PramaLLC/BEN2")
    model.to(device).eval()

    rgb_color = parse_color(args.bg_color)

    print("Starte Video-Segmentierung...")
    print("{} -> {}".format(video_path, expected_output))
    print("Format: {}".format(output_format))

    written = segment_video(
        model,
        video_path=str(video_path),
        output_path=str(expected_output),
        fps=0,
        refine_foreground=args.refine,
        batch=args.batch,
        rgb_value=rgb_color,
        alpha_threshold=args.alpha_threshold,
        min_region_area=args.min_region_area,
        keep_largest=not args.all_regions,
        temporal_smoothing=args.temporal_smoothing,
        mask_only=args.mask_only,
    )

    print("\nFertig! Ausgabedatei: {}".format(written))


if __name__ == "__main__":
    main()
