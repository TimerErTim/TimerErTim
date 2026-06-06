import "./globals.css";
import { Viewport } from "next";
import clsx from "clsx";

import { Providers } from "./providers";

import { SiteHeader } from "@/components/site-header";
import { SiteNav } from "@/components/site-nav";
import { SideFooter } from "@/components/side-footer";
import { getBlogSearchEntries } from "@/lib/blog-search";
import { rootSiteMetadata } from "@/lib/site-metadata";
import { PrePaintThemeInjectionScript } from "@/lib/theme";
import { site } from "@/site";
import { fontMono, fontSans } from "@/site/fonts.generated";
import { themeColors } from "@/site/theme.generated";

export const metadata = rootSiteMetadata();

export const viewport: Viewport = {
  themeColor: [
    { media: "(prefers-color-scheme: light)", color: themeColors.light.base },
    { media: "(prefers-color-scheme: dark)", color: themeColors.dark.base },
  ],
};

export default async function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const searchEntries = await getBlogSearchEntries();

  return (
    <html
      className={clsx(fontSans.variable, fontMono.variable)}
      lang="en"
      suppressHydrationWarning
    >
      <head>
        <PrePaintThemeInjectionScript />
      </head>
      <body
        className={clsx(
          "min-h-screen font-sans antialiased",
          fontSans.className,
        )}
      >
        <Providers>
          <div className="flex min-h-screen flex-col">
            <div className="mx-auto w-full max-w-5xl px-6">
              <SiteHeader />
              <SiteNav searchEntries={searchEntries} />
            </div>
            <main className="flex-grow">{children}</main>
            <SideFooter />
          </div>
        </Providers>
      </body>
    </html>
  );
}
