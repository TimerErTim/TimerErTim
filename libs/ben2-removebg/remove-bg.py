#!/usr/bin/env -S uv run --script
# /// script
# dependencies = [
#     "ben2 @ git+https://github.com/PramaLLC/BEN2.git",
#     "torch>=2.1.0",
#     "opencv-python>=4.10.0",
#     "numpy",
#     "pillow",
#     "tqdm",
# ]
# ///

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
from ben2 import BEN_Base
from ben2.modeling_ben2 import (
    add_audio_to_video,
    img_transform,
    img_transform32,
    postprocess_image,
    refine_foreground_process,
    rgb_loader_refiner,
)
from PIL import Image
from torchvision import transforms
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
        help="Ausgabeordner (Standard: gleiches Verzeichnis wie das Eingabevideo)",
    )
    parser.add_argument(
        "--webm",
        action="store_true",
        help="Gibt ein transparentes WebM-Video (mit echtem Alpha-Kanal) statt MP4 aus",
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
    return parser.parse_args()


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


def _gpu_inference(model, pil_image, refine):
    """Runs the network on GPU. With refine=False this is the whole job;
    with refine=True it only produces the raw mask and the blur-fusion
    refine pass runs later on a CPU worker."""
    image, h, w, original_image = rgb_loader_refiner(pil_image)
    if torch.cuda.is_available():
        img_tensor = img_transform(image).unsqueeze(0).to(next(model.parameters()).device)
    else:
        img_tensor = img_transform32(image).unsqueeze(0).to(next(model.parameters()).device)

    with torch.no_grad():
        res = model.forward(img_tensor)

    if not refine:
        alpha = postprocess_image(res, im_size=[w, h])
        pred_pil = transforms.ToPILImage()(alpha)
        mask = pred_pil.resize(original_image.size)
        original_image.putalpha(mask)
        return original_image

    # Deliver the full-res frame plus the mask to the refine stage.
    pred_pil = transforms.ToPILImage()(res.squeeze())
    return (original_image, pred_pil.resize(original_image.size))


def _refine_on_cpu(item):
    frame_idx, (original_image, mask) = item
    image_masked = refine_foreground_process(original_image, mask)
    image_masked.putalpha(mask)
    return frame_idx, image_masked


def _inference_worker(work_queue, refine_queue, result_queue, model, refine):
    out_queue = refine_queue if refine_queue is not None else result_queue
    while True:
        item = work_queue.get()
        try:
            if item is None:
                return
            frame_idx, pil_image = item
            out_queue.put((frame_idx, _gpu_inference(model, pil_image, refine)))
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
    result_queue, writer, pending, next_write_idx, block, total_frames, progress
):
    while next_write_idx < total_frames:
        while next_write_idx in pending:
            for foreground in _as_frame_list(pending.pop(next_write_idx)):
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


class WebmAlphaWriter:
    def __init__(self, output_path, fps, size):
        width, height = size
        Path(output_path).parent.mkdir(parents=True, exist_ok=True)
        self._output_path = str(output_path)
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
                    "rgba",
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
                    "yuva420p",
                    "-auto-alt-ref",
                    "0",
                    self._output_path,
                ],
                stdin=subprocess.PIPE,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.PIPE,
            )
        except FileNotFoundError as exc:
            raise RuntimeError("ffmpeg not found; required for WebM alpha output") from exc

    def write(self, image):
        if image.mode != "RGBA":
            image = image.convert("RGBA")
        try:
            self._proc.stdin.write(image.tobytes())
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
        print("WebM with alpha saved to {}".format(self._output_path))

def segment_video(
    model,
    video_path,
    output_path="./",
    fps=0,
    refine_foreground=False,
    batch=1,
    webm=False,
    rgb_value=(0, 255, 0),
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
    if output_path.is_dir() or str(output_path).endswith(("/", "\\")):
        output_file = output_path / ("foreground.webm" if webm else "foreground.mp4")
    elif output_path.suffix.lower() in {".webm", ".mp4", ".mov", ".mkv"}:
        output_file = output_path
    else:
        output_file = output_path / ("foreground.webm" if webm else "foreground.mp4")

    writer = None
    progress = None
    num_workers = max(1, batch)
    total_frames_expected = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    models = [copy.deepcopy(model) for _ in range(num_workers - 1)] + [model]
    work_queue = queue.Queue(maxsize=num_workers * 3)
    result_queue = queue.Queue()
    pending = {}
    next_write_idx = 0

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
            args=(work_queue, refine_queue, result_queue, worker_model, refine_foreground),
            daemon=True,
        )
        for worker_model in models
    ]

    try:
        if webm:
            writer = WebmAlphaWriter(output_file, fps, (width, height))
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

    if not webm:
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
    output_dir = Path(args.output_dir).resolve() if args.output_dir else video_path.parent
    if output_dir.is_dir():
        if args.webm:
            expected_output = output_dir / "foreground.webm"
        else:
            expected_output = output_dir / "foreground.mp4"
    else:
        expected_output = output_dir

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
    print(
        "Format: {}".format(
            "Transparente WebM (Alpha-Kanal)"
            if args.webm
            else "MP4 mit Hintergrund {}".format(rgb_color)
        )
    )

    written = segment_video(
        model,
        video_path=str(video_path),
        output_path=str(expected_output),
        fps=0,
        refine_foreground=args.refine,
        batch=args.batch,
        webm=args.webm or expected_output.suffix.lower() == ".webm",
        rgb_value=rgb_color,
    )

    print("\nFertig! Ausgabedatei: {}".format(written))


if __name__ == "__main__":
    main()
