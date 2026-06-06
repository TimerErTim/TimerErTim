import { createTV } from "tailwind-variants";
import { extendTailwindMerge } from "tailwind-merge";

import { themeFontSizes, themeSemanticColors } from "@/site/theme.generated";

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
    },
  },
};

export const twMerge = extendTailwindMerge(twMergeConfig);

export const tv = createTV({ twMerge: true, twMergeConfig });
