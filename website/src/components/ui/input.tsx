import { tv } from "@/lib/tw";
import { type InputHTMLAttributes, type ReactNode } from "react";

const inputShellStyles = tv({
  base: [
    "flex w-full items-center bg-background",
    "border-md border-shadow rounded-sm shadow-sm",
    "transition-[border-color] duration-30 ease-linear",
    "focus-within:shadow-info focus-within:outline-info focus-within:outline-2 focus-within:outline-offset-0 focus-within:border-info",
  ],
});

const inputStyles = tv({
  base: "w-full bg-transparent text-foreground text-small leading-small placeholder:text-muted focus:outline-none",
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
      <div className={inputShellStyles({ className })}>
        <input className={inputStyles({ size })} {...props} />
      </div>
    );
  }

  return (
    <div className={inputShellStyles({ className })}>
      {startContent && (
        <span className="pl-3 text-muted flex-shrink-0">{startContent}</span>
      )}
      <input
        className={inputStyles({
          size,
          className: "border-0 focus:outline-none",
        })}
        {...props}
      />
      {endContent && (
        <span className="pr-3 text-muted flex-shrink-0">{endContent}</span>
      )}
    </div>
  );
}
