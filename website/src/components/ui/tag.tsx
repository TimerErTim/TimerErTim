import { tv } from "tailwind-variants";
import { type ReactNode } from "react";

const tagStyles = tv({
  base: "inline-block border border-info/30 bg-info/10 text-info text-tiny leading-tiny px-2 py-0.5 rounded-sm",
});

export function Tag({
  children,
  className,
}: {
  children: ReactNode;
  className?: string;
}) {
  return <span className={tagStyles({ className })}>{children}</span>;
}
