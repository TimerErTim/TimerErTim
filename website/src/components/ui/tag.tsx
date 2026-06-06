import { tv } from "@/lib/tw";
import { type ReactNode } from "react";

const tagStyles = tv({
  base: "inline-block border border-info bg-info/25 text-foreground text-tiny leading-tiny px-2 py-0.5 rounded-sm",
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
