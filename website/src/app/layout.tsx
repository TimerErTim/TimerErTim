import "./globals.css";
import { Metadata, Viewport } from "next";
import clsx from "clsx";

import { Providers } from "./providers";

import { siteConfig } from "@/config/site";
import { fontSans, fontSerif, fontMono } from "@/config/fonts";
import { SiteHeader } from "@/components/site-header";
import { SiteNav } from "@/components/site-nav";
import { PrePaintThemeInjectionScript } from "@/lib/theme";
import { routes, urls } from "@/paths";
import { SideFooter } from "@/components/side-footer";

export const metadata: Metadata = {
  metadataBase: new URL(urls.site()),
  title: {
    default: siteConfig.name,
    template: `%s · ${siteConfig.name}`,
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
    { media: "(prefers-color-scheme: light)", color: "#f7f8fb" },
    { media: "(prefers-color-scheme: dark)", color: "#111115" },
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
          "min-h-screen font-sans antialiased",
          fontSans.variable,
          fontSerif.variable,
          fontMono.variable,
        )}
      >
        <Providers>
          <div className="flex min-h-screen flex-col">
            <div className="mx-auto w-full max-w-5xl px-6">
              <SiteHeader />
              <SiteNav />
            </div>
            <main className="flex-grow">{children}</main>
            <SideFooter />
          </div>
        </Providers>
      </body>
    </html>
  );
}
