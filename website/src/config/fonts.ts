import {
  Fira_Code as FontMono,
  Inter as FontSans,
  Source_Serif_4 as FontSerif,
} from "next/font/google";

export const fontSans = FontSans({
  subsets: ["latin"],
  variable: "--font-family-sans",
});

export const fontSerif = FontSerif({
  subsets: ["latin"],
  variable: "--font-family-serif",
});

export const fontMono = FontMono({
  subsets: ["latin"],
  variable: "--font-family-mono",
});
