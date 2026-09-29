#!/usr/bin/env -S uv run --script
# /// script
# dependencies = [
#     "ben2 @ git+https://github.com/PramaLLC/BEN2.git",
#     "torch>=2.1.0",
#     "opencv-python>=4.10.0",
#     "numpy",
#     "pillow",
# ]
# ///

import argparse
import subprocess
from pathlib import Path

import cv2
import numpy as np
import torch
from ben2 import BEN_Base
from ben2.modeling_ben2 import add_audio_to_video
from PIL import Image
import concurrent.futures



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
        help="Batch-Größe (Empfehlung: 1 bis max. 3 für Endverbraucher-GPUs)",
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
    print_frames_processed=True,
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
    frame_idx = 0
    batch_frames = []
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))

    try:
        if webm:
            writer = WebmAlphaWriter(output_file, fps, (width, height))
        else:
            writer = Mp4FrameWriter(output_file, fps, (width, height), rgb_value)

        while True:
            ret, frame = cap.read()
            if not ret:
                if batch_frames:
                    def infer_single(img):
                        return model.inference(img, refine_foreground)
                    with concurrent.futures.ThreadPoolExecutor() as executor:
                        batch_results = list(executor.map(infer_single, batch_frames))
               
                    for foreground in _as_frame_list(batch_results):
                        writer.write(foreground)
                    if print_frames_processed:
                        print(
                            "Processed frames {} to {} of {}".format(
                                frame_idx - len(batch_frames) + 1, frame_idx, total_frames
                            )
                        )
                break

            frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            batch_frames.append(Image.fromarray(frame_rgb))

            if len(batch_frames) == batch:
                batch_results = model.inference(batch_frames, refine_foreground)
                for foreground in _as_frame_list(batch_results):
                    writer.write(foreground)
                if print_frames_processed:
                    print(
                        "Processed frames {} to {} of {}".format(
                            frame_idx - batch + 1, frame_idx, total_frames
                        )
                    )
                batch_frames = []

            frame_idx += 1
    finally:
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
    import sys

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
        print_frames_processed=True,
        webm=args.webm or expected_output.suffix.lower() == ".webm",
        rgb_value=rgb_color,
    )

    print("\nFertig! Ausgabedatei: {}".format(written))


if __name__ == "__main__":
    main()
