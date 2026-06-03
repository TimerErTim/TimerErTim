"use client";

import { TransitBlogMetadata } from "@/model/blogs";
import { useMemo } from "react";
import { decompress } from "brotli-compress/js";
import type { BrotliDecodeOptions } from "@/libs/brotli/decode";
import { useEffect, useState } from "react";


export default function RenderBlog({ blogData }: { blogData: TransitBlogMetadata }) {
    function decompressBase64String(
        base64String: string,
        options?: BrotliDecodeOptions,
    ) {
        const binaryString = atob(base64String);
        const buffer = Int8Array.from(binaryString, c => c.charCodeAt(0));
        const decompressed = decompress(buffer, options);
        const decoder = new TextDecoder("utf-8");
        return decoder.decode(decompressed);
    }
    
    const decompressedRefSvg = useMemo(() => {
        const refVariant = blogData.variants.find(v => v.filename === blogData.compressionRefFilename);
        if (!refVariant) {
            throw new Error(`Reference file ${blogData.compressionRefFilename} not found for decompression`);
        }
        const refFileBase64 = refVariant.compressedBase64;
        // Modern way: decode base64 to Uint8Array using Uint8Array.from and atob
        const decompressed = decompressBase64String(refFileBase64);
        return decompressed;
    }, [blogData]);


    // Helper to choose best-fit variant based on theme and width
    function selectVariant(variants: TransitBlogMetadata["variants"], theme: "light" | "dark", windowWidth: number) {
        // Filter by theme
        const themeVariants = variants.filter(v => v.theme === theme);
        if (themeVariants.length === 0) {
            // fallback to other theme if not found
            return variants[0];
        }
        // Sort by width_pt ascending
        const sorted = [...themeVariants].sort((a, b) => a.width_pt - b.width_pt);
        // Find the smallest variant that is >= windowWidth, otherwise pick largest
        for (const v of sorted) {
            if (v.width_pt >= windowWidth) return v;
        }
        return sorted[sorted.length - 1];
    }

    // Get current theme ('light' or 'dark')
    function useTheme(): "light" | "dark" {
        const [theme, setTheme] = useState<"light" | "dark">(
            typeof window !== "undefined" && window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches ? "dark" : "light"
        );
        useEffect(() => {
            const mql = window.matchMedia('(prefers-color-scheme: dark)');
            const handler = (e: MediaQueryListEvent) => setTheme(e.matches ? "dark" : "light");
            mql.addEventListener("change", handler);
            return () => mql.removeEventListener("change", handler);
        }, []);
        return theme;
    }

    function useWindowWidth() {
        const [width, setWidth] = useState(
            typeof window !== "undefined" ? window.innerWidth : 1024
        );
        useEffect(() => {
            const handleResize = () => setWidth(window.innerWidth);
            window.addEventListener("resize", handleResize);
            return () => window.removeEventListener("resize", handleResize);
        }, []);
        return width;
    }

    const theme = useTheme();
    const windowWidth = useWindowWidth();

    // Memoize SVG for current theme and window width
    const svgContent = useMemo(() => {
        // Use actual SVG reference if only one variant
        if (blogData.variants.length === 1) return decompressedRefSvg;
        // Select variant
        const variant = selectVariant(blogData.variants, theme, windowWidth);
        if (!variant) {
            return decompressedRefSvg; // fallback
        }
        if (variant.filename === blogData.compressionRefFilename) {
            return decompressedRefSvg;
        }
        //return decompressedRefSvg;
        const refVariant = blogData.variants.find(v => v.filename === blogData.compressionRefFilename);
        return decompressBase64String(variant.compressedBase64, {
            customDictionary: Buffer.from(new TextEncoder().encode(atob(refVariant?.compressedBase64!))),
        });
    }, [blogData, theme, windowWidth, decompressedRefSvg]);
    
    return (
        <div>
            <div dangerouslySetInnerHTML={{ __html: svgContent }} suppressHydrationWarning />
        </div>
    );
}