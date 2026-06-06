import { createTV } from "tailwind-variants";
import { extendTailwindMerge } from "tailwind-merge";

const semanticColors = [
  "background",
  "foreground",
  "accent",
  "muted",
  "surface",
  "overlay",
  "border",
  "danger",
  "warning",
  "success",
  "info",
] as const;

const fontSizes = ["tiny", "small", "medium", "large"] as const;

export const twMergeConfig = {
  extend: {
    theme: {
      color: [...semanticColors],
    },
    classGroups: {
      "font-size": fontSizes.map((size) => `text-${size}`),
      leading: fontSizes.map((size) => `leading-${size}`),
      "text-color": [{ text: [...semanticColors] }],
      "bg-color": [{ bg: [...semanticColors] }],
      "border-color": [{ border: [...semanticColors] }],
    },
  },
};

export const twMerge = extendTailwindMerge(twMergeConfig);

export const tv = createTV({ twMerge: true, twMergeConfig });
