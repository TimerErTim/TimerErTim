import { tv } from "tailwind-variants";
import { type HTMLAttributes } from "react";

const cardStyles = tv({
  base: "bg-surface border border-border p-4 transition-colors",
  variants: {
    hoverable: {
      true: "hover:bg-overlay",
      false: "",
    },
  },
  defaultVariants: {
    hoverable: false,
  },
});

export function Card({
  className,
  hoverable,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  hoverable?: boolean;
}) {
  return (
    <div className={cardStyles({ hoverable, className })} {...props} />
  );
}
