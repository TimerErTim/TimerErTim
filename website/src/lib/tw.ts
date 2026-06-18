import { createTV } from "tailwind-variants";
import { extendTailwindMerge } from "tailwind-merge";

import {
  themeBorderWidths,
  themeFontSizes,
  themeSemanticColors,
} from "@/site/theme.generated";

export const twMergeConfig = {
  extend: {
    theme: {
      color: [...themeSemanticColors],
    },
    classGroups: {
      "font-size": themeFontSizes.map((size) => `text-${size}`),
      leading: themeFontSizes.map((size) => `leading-${size}`),
      "text-color": [{ text: [...themeSemanticColors] }],
      "bg-color": [{ bg: [...themeSemanticColors] }],
      "border-color": [{ border: [...themeSemanticColors] }],
      "decoration-color": [{ decoration: [...themeSemanticColors] }],
      "border-w": [{ border: [...themeBorderWidths, "0"] }],
      shadow: [{ shadow: ["sm", "md", "none", ...themeSemanticColors] }],
    },
  },
};

export const twMerge = extendTailwindMerge(twMergeConfig);

export const tv = createTV({ twMerge: true, twMergeConfig });

/** Press/lift motion paired with depth-sm extrusion. */
export const depthSmMotion =
  "transition-[translate,box-shadow] duration-30 ease-linear active:shadow-none active:translate-x-depth-sm active:translate-y-depth-sm";

/** Press/lift motion paired with depth-md extrusion. */
export const depthMdMotion =
  "transition-[translate,box-shadow] duration-30 ease-linear active:shadow-none active:translate-x-depth-md active:translate-y-depth-md";
