import { type ReactNode } from "react";

export function PageShell({
  children,
  sidebar,
}: {
  children: ReactNode;
  sidebar?: ReactNode;
}) {
  if (!sidebar) {
    return (
      <div className="mx-auto max-w-3xl px-6 pb-16">{children}</div>
    );
  }

  return (
    <div className="mx-auto max-w-5xl px-6 pb-16">
      <div className="grid grid-cols-1 lg:grid-cols-[minmax(0,1fr)_220px] gap-10">
        <div className="min-w-0">{children}</div>
        <aside className="lg:pt-1">{sidebar}</aside>
      </div>
    </div>
  );
}
