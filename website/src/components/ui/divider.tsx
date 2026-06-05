import { tv } from "tailwind-variants";

const dividerStyles = tv({
  base: "border-t border-border w-full",
});

export function Divider({ className }: { className?: string }) {
  return <hr className={dividerStyles({ className })} />;
}
