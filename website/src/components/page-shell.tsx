import { type ReactNode } from "react";

export type SidebarLayout = "match-content" | "fill";

export function PageShell({
  children,
  sidebar,
  subContent,
  sidebarLayout = subContent ? "match-content" : "fill",
}: {
  children: ReactNode;
  sidebar?: ReactNode;
  subContent?: ReactNode;
  sidebarLayout?: SidebarLayout;
}) {
  const shellClass = "mx-auto max-w-5xl px-6 pb-16";

  if (!sidebar && !subContent) {
    return <div className={shellClass}>{children}</div>;
  }

  if (!sidebar) {
    return (
      <div className={shellClass}>
        {children}
        {subContent && <div className="mt-8 min-w-0">{subContent}</div>}
      </div>
    );
  }

  const layoutClass =
    sidebarLayout === "fill"
      ? "flex flex-col gap-8 md:grid md:min-h-[calc(100vh-14rem)] md:grid-cols-[minmax(0,1fr)_220px] md:grid-rows-[auto_auto] md:items-stretch md:gap-x-10 md:gap-y-8"
      : "flex flex-col gap-8 md:grid md:grid-cols-[minmax(0,1fr)_220px] md:grid-rows-[auto_auto] md:gap-x-10 md:gap-y-8";

  const sidebarClass =
    sidebarLayout === "fill"
      ? "order-3 min-w-0 md:col-start-2 md:row-start-1 md:flex md:min-h-0 md:flex-col"
      : "order-3 min-w-0 md:col-start-2 md:row-start-1 md:self-start";

  const sidebarInnerClass =
    sidebarLayout === "fill"
      ? "md:sticky md:top-6 md:min-h-0 md:flex-1 md:overflow-y-auto"
      : "md:sticky md:top-6";

  return (
    <div className={shellClass}>
      <div className={layoutClass}>
        <div className="order-1 min-w-0 flex flex-col md:col-start-1 md:row-start-1">
          {children}
        </div>

        {subContent && (
          <div className="order-2 min-w-0 md:col-span-2 md:row-start-2">
            {subContent}
          </div>
        )}

        <aside className={sidebarClass}>
          <div className={sidebarInnerClass}>{sidebar}</div>
        </aside>
      </div>
    </div>
  );
}