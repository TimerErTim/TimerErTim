"use client";

import * as React from "react";

import { ThemeProvider } from "@/theme";

export function Providers({ children }: { children: React.ReactNode }) {
  return <ThemeProvider>{children}</ThemeProvider>;
}
