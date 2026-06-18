import { depthMdMotion, tv } from "@/lib/tw";
import { type HTMLAttributes, type ReactNode } from "react";

export const cardStyles = tv({
  base: "bg-background border-md border-shadow rounded-md shadow-md w-full",
  variants: {
    padding: {
      none: "p-0",
      sm: "p-4",
      md: "p-5",
    },
    hoverable: {
      true: [depthMdMotion, "hover:bg-overlay/50"],
      false: "",
    },
  },
  defaultVariants: {
    padding: "sm",
    hoverable: false,
  },
});

export function Card({
  className,
  hoverable,
  padding,
  children,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  hoverable?: boolean;
  padding?: "none" | "sm" | "md";
  children: ReactNode;
}) {
  return (
    <div className={cardStyles({ hoverable, padding, className })} {...props}>
      {children}
    </div>
  );
}
