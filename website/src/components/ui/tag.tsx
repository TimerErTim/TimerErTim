import { tv } from "@/lib/tw";
import { type ReactNode } from "react";

const tagStyles = tv({
  base: [
    "inline-block font-semibold text-background text-tiny leading-tiny px-2.5 py-0.5",
    "rounded-sm border-shadow bg-info",
  ],
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
