import "@/styles/globals.css";
import { Metadata, Viewport } from "next";
import clsx from "clsx";

import { Providers } from "./providers";

import { siteConfig } from "@/config/site";
import { fontSans } from "@/config/fonts";
import { Navbar } from "@/components/navbar";
import { PrePaintThemeInjectionScript } from "@/lib/theme";
import { routes, urls } from "@/paths";

export const metadata: Metadata = {
  metadataBase: new URL(urls.site()),
  title: {
    default: siteConfig.name,
    template: `%s - ${siteConfig.name}`,
  },
  description: siteConfig.description,
  icons: {
    icon: routes.favicon(),
  },
  alternates: {
    types: {
      "application/rss+xml": urls.feed(),
    },
  },
};

export const viewport: Viewport = {
  themeColor: [
    { media: "(prefers-color-scheme: light)", color: "white" },
    { media: "(prefers-color-scheme: dark)", color: "black" },
  ],
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        <PrePaintThemeInjectionScript />
      </head>
      <body
        className={clsx(
          "min-h-screen text-foreground bg-background font-sans antialiased",
          fontSans.variable,
        )}
      >
        <Providers>
          <div className="relative flex flex-col h-screen">
            <Navbar />
            <main className="container mx-auto max-w-7xl pt-16 px-6 flex-grow">
              {children}
            </main>
            <footer className="w-full flex items-center justify-center py-3">
              <a
                className="flex items-center gap-1 text-current no-underline"
                href="https://heroui.com?utm_source=next-app-template"
                rel="noopener noreferrer"
                target="_blank"
              >
                <span className="text-muted">Powered by</span>
                <p className="text-accent">HeroUI</p>
              </a>
            </footer>
          </div>
        </Providers>
      </body>
    </html>
  );
}
