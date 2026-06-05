import NextLink from "next/link";
import type { Route } from "next";
import { tv, type VariantProps } from "tailwind-variants";
import { type ComponentProps, type ReactNode } from "react";

const linkStyles = tv({
  base: "transition-colors",
  variants: {
    variant: {
      default: "text-info underline-offset-2 hover:underline",
      nav: "text-foreground no-underline hover:text-accent",
      muted: "text-muted no-underline hover:text-foreground",
      plain: "text-inherit no-underline hover:text-inherit",
    },
    active: {
      true: "text-accent font-medium",
      false: "",
    },
  },
  compoundVariants: [
    {
      variant: "nav",
      active: true,
      class: "text-accent font-medium",
    },
  ],
  defaultVariants: {
    variant: "default",
    active: false,
  },
});

type LinkStyleProps = VariantProps<typeof linkStyles>;

type SharedLinkProps = LinkStyleProps & {
  children: ReactNode;
  className?: string;
};

type ExternalLinkProps = SharedLinkProps & {
  href: string;
  external: true;
} & Omit<ComponentProps<"a">, "href" | "children" | "className">;

type InternalLinkProps = SharedLinkProps & {
  href: Route;
  external?: false;
} & Omit<ComponentProps<typeof NextLink>, "href" | "children" | "className">;

export type AppLinkProps = ExternalLinkProps | InternalLinkProps;

export function AppLink(props: AppLinkProps) {
  const { href, children, className, variant, active, ...rest } = props;
  const classes = linkStyles({ variant, active, className });

  if ("external" in props && props.external) {
    const anchorProps = rest as Omit<ComponentProps<"a">, "href" | "children" | "className">;
    return (
      <a
        className={classes}
        href={href as string}
        rel="noopener noreferrer"
        target="_blank"
        {...anchorProps}
      >
        {children}
      </a>
    );
  }

  const linkProps = rest as Omit<ComponentProps<typeof NextLink>, "href" | "children" | "className">;
  return (
    <NextLink className={classes} href={href as Route} {...linkProps}>
      {children}
    </NextLink>
  );
}
