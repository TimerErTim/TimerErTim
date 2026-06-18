import { tv } from "@/lib/tw";

const dividerStyles = tv({
  base: "border-t border-border w-full",
  variants: {
    size: {
      sm: "border-t-sm",
      md: "border-t-md",
      lg: "border-t-lg",
    },
  },
  defaultVariants: {
    size: "md",
  },
});

export function Divider({ size, className }: { size?: "sm" | "md" | "lg"; className?: string }) {
  return <div className={dividerStyles({ size, className })} role="separator" />;
}
