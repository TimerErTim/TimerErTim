import { tv } from "@/lib/tw";

export const title = tv({
  base: "font-sans text-large leading-large font-bold tracking-tight text-foreground",
  variants: {
    size: {
      sm: "text-medium leading-medium",
      md: "text-large leading-large",
      lg: "text-[2rem] leading-[2.25rem]",
    },
  },
  defaultVariants: {
    size: "md",
  },
});

export const subtitle = tv({
  base: "font-sans text-medium leading-medium text-muted",
});

export const prose = tv({
  base: "prose font-sans text-medium leading-medium text-foreground",
});
