#!/usr/bin/env -S uv run --script
# /// script
# dependencies = [
#     "ben2 @ git+https://github.com/PramaLLC/BEN2.git",
#     "torch>=2.1.0",
#     "opencv-python>=4.10.0",
# ]
# ///

import argparse
from pathlib import Path
import torch
from ben2 import BEN_Base

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
        default="./",
        help="Ausgabeordner (Standard: './')",
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

def main():
    import sys
    print("Python version:", sys.version)
    args = parse_args()
    video_path = Path(args.input)
    output_dir = str(Path(args.output_dir).resolve())
    if Path(output_dir).is_dir():
        if args.webm:
            expected_output = Path(output_dir) / "foreground.webm"
        else:
            expected_output = Path(output_dir) / "foreground.mp4"
    else:
        expected_output = Path(output_dir)

    if not video_path.exists():
        raise SystemExit("Fehler: Die Datei '{}' existiert nicht.".format(video_path))

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print("Gerät: {}".format(device))

    # Offizieller Ladevorgang von HuggingFace
    print("Lade BEN2 Modellgewichte von HuggingFace (PramaLLC/BEN2)...")
    model = BEN_Base.from_pretrained("PramaLLC/BEN2")
    model.to(device).eval()

    rgb_color = parse_color(args.bg_color)

    print("Starte Video-Segmentierung...")
    print("{} -> {}".format(video_path, expected_output))
    print(
        "Format: {}".format("Transparente WebM (Alpha-Kanal)" if args.webm else "MP4 mit Hintergrund {}".format(rgb_color))
    )

    # Native Video-Segmentierung von BEN2
    model.segment_video(
        video_path=str(video_path),
        output_path=str(expected_output),
        fps=0,  # 0 = Original-FPS beibehalten
        refine_foreground=args.refine,
        batch=args.batch,
        print_frames_processed=True,
        webm=args.webm,
        rgb_value=rgb_color,
    )

    print("\nFertig! Ausgabedatei: {}".format(expected_output))

if __name__ == "__main__":
    main()