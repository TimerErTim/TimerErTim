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
    return (
      <div className={shellClass}>{children}</div>
    );
  }


  if (!sidebar) {
    return (
      <div className={shellClass}>
        {children}
        {subContent && <div className="mt-8 min-w-0">{subContent}</div>}
      </div>
    );
  }

  if (sidebarLayout === "match-content") {
    return (
      <div className={shellClass}>
        <div className="relative">
          <div className="min-w-0 lg:pr-[calc(220px+2.5rem)]">{children}</div>
          <aside className="hidden lg:block absolute top-0 right-0 h-full w-[220px] max-h-full overflow-hidden">
            {sidebar}
          </aside>
        </div>
        {subContent && <div className="mt-8 min-w-0">{subContent}</div>}
      </div>
    );
  }

  return (
    <div className={shellClass}>
      <div className="grid min-h-[calc(100vh-14rem)] grid-cols-1 lg:grid-cols-[minmax(0,1fr)_220px] gap-10 items-stretch">
        <div className="min-w-0 flex flex-col">{children}</div>
        <aside className="hidden lg:flex lg:min-h-0 lg:flex-col">
          <div className="sticky top-6 min-h-0 flex-1 overflow-y-auto">
            {sidebar}
          </div>
        </aside>
      </div>
      {subContent && <div className="mt-8 min-w-0">{subContent}</div>}
    </div>
  );
}
