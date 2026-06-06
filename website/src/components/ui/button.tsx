import { tv, type VariantProps } from "tailwind-variants";
import { forwardRef, type ButtonHTMLAttributes } from "react";

export const buttonStyles = tv({
  base: "inline-flex items-center justify-center gap-2 font-medium transition-colors focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-accent disabled:opacity-50 disabled:pointer-events-none cursor-pointer",
  variants: {
    variant: {
      primary: "bg-accent text-foreground hover:opacity-90",
      secondary:
        "bg-surface border border-border text-foreground hover:bg-overlay",
      ghost: "text-foreground hover:bg-overlay",
      link: "text-info underline-offset-2 hover:underline p-0",
    },
    size: {
      sm: "text-tiny leading-tiny px-3 py-1",
      md: "text-small leading-small px-4 py-1.5",
    },
  },
  defaultVariants: {
    variant: "primary",
    size: "md",
  },
});

type ButtonStyleProps = VariantProps<typeof buttonStyles>;

export type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> &
  ButtonStyleProps & {
    className?: string;
  };

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, type = "button", ...props }, ref) => (
    <button
      ref={ref}
      className={buttonStyles({ variant, size, className })}
      type={type}
      {...props}
    />
  ),
);

Button.displayName = "Button";
