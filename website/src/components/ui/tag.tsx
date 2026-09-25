import { tv } from "@/lib/tw";
import { type MouseEventHandler, type ReactNode } from "react";
import Link from "next/link";
import type { Route } from "next";

const tagStyles = tv({
  base: [
    "inline-flex items-center gap-1 font-semibold text-background text-tiny leading-tiny px-2.5 py-0.5",
    "rounded-sm border-shadow transition-colors select-none",
  ],
  variants: {
    active: {
      true: "bg-accent text-background font-bold",
      false: "bg-info text-background",
    },
    clickable: {
      true: "cursor-pointer no-underline hover:opacity-90 active:scale-95",
      false: "",
    },
  },
  defaultVariants: {
    active: false,
    clickable: false,
  },
});

export type TagProps = {
  children: ReactNode;
  className?: string;
  active?: boolean;
  href?: Route | string;
  onClick?: MouseEventHandler<HTMLElement>;
};

export function Tag({
  children,
  className,
  active = false,
  href,
  onClick,
}: TagProps) {
  const isClickable = Boolean(href || onClick);
  const classes = tagStyles({ active, clickable: isClickable, className });

  if (href) {
    return (
      <Link href={href as Route} className={classes} onClick={onClick}>
        {children}
      </Link>
    );
  }

  if (onClick) {
    return (
      <button type="button" className={classes} onClick={onClick}>
        {children}
      </button>
    );
  }

  return <span className={classes}>{children}</span>;
}
