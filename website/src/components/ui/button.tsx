import { type VariantProps } from "tailwind-variants";
import { depthSmMotion, tv } from "@/lib/tw";
import { forwardRef, type ButtonHTMLAttributes } from "react";

export const buttonStyles = tv({
  base: [
    "inline-flex items-center justify-center gap-2 font-bold",
    "cursor-pointer border-sm rounded-sm shadow-sm",
    depthSmMotion,
    "focus-visible:shadow-info focus-visible:outline-info focus-visible:outline-2 focus-visible:outline-offset-0 focus-visible:border-info",
    "disabled:opacity-50 disabled:pointer-events-none",
  ],
  variants: {
    variant: {
      primary:
        "text-foreground shadow-accent border-accent hover:bg-accent/25",
      secondary:
        "bg-background border-shadow text-foreground hover:bg-accent/18",
      ghost:
        "bg-transparent shadow-none text-foreground hover:bg-overlay hover:translate-none hover:shadow-none active:translate-none",
      link: "border-0 bg-transparent p-0 shadow-none text-info font-semibold underline decoration-shadow decoration-2 underline-offset-[3px] hover:underline hover:translate-none hover:shadow-none active:translate-none",
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
  ({ className, variant = "primary", size = "md", type = "button", children, ...props }, ref) => {
    return (
      <button
        ref={ref}
        className={buttonStyles({ variant, size, className })}
        type={type}
        {...props}
      >
        {children}
      </button>
    );
  },
);

Button.displayName = "Button";
