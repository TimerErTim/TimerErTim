import { tv } from "@/lib/tw";
import { type InputHTMLAttributes, type ReactNode } from "react";

const inputStyles = tv({
  base: "w-full bg-overlay border border-border text-foreground text-small leading-small placeholder:text-muted focus:outline focus:outline-2 focus:outline-offset-0 focus:outline-accent",
  variants: {
    size: {
      sm: "px-2.5 py-1 text-tiny leading-tiny",
      md: "px-3 py-1.5",
    },
  },
  defaultVariants: {
    size: "md",
  },
});

type InputProps = Omit<InputHTMLAttributes<HTMLInputElement>, "size"> & {
  className?: string;
  startContent?: ReactNode;
  endContent?: ReactNode;
  size?: "sm" | "md";
};

export function Input({
  className,
  startContent,
  endContent,
  size,
  ...props
}: InputProps) {
  if (!startContent && !endContent) {
    return (
      <input
        className={inputStyles({ size, className })}
        {...props}
      />
    );
  }

  return (
    <div className="flex items-center border border-border bg-overlay focus-within:outline focus-within:outline-2 focus-within:outline-offset-0 focus-within:outline-accent">
      {startContent && (
        <span className="pl-3 text-muted flex-shrink-0">{startContent}</span>
      )}
      <input
        className={inputStyles({
          size,
          className: `border-0 bg-transparent focus:outline-none ${className ?? ""}`,
        })}
        {...props}
      />
      {endContent && (
        <span className="pr-3 text-muted flex-shrink-0">{endContent}</span>
      )}
    </div>
  );
}
