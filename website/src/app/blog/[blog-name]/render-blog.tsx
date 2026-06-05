"use client";

import { TransitBlogMetadata } from "@/model/blogs";
import { useMemo } from "react";
import { decompress } from "brotli-compress/js";
import { decode } from "@ably/vcdiff-decoder";
import { useEffect, useState } from "react";
import { useTheme } from "@/lib/theme";


export default function RenderBlog({ blogData }: { blogData: TransitBlogMetadata }) {
    const inBrowser = typeof window != "undefined"
    // Defer actual svg decompression until CSR for lighter html
    const [initialRender, setInitialRender] = useState(true)

    function decompressBase64String(
        base64String: string
    ): Uint8Array {
        const binaryString = atob(base64String);
        const buffer = Uint8Array.from(binaryString, c => c.charCodeAt(0));
        const decompressed = decompress(buffer);
        return decompressed;
    }

    function decodeDelta(
        reference: Uint8Array,
        deltaBytes: Uint8Array
    ): Uint8Array {
        const decompressed = decode(deltaBytes, reference);
        return decompressed;
    }

    function decodeText(
        buffer: Uint8Array
    ): string {
        return new TextDecoder('utf-8').decode(buffer);
    }

    useEffect(() => {
        setInitialRender(false);
    }, []);

    const decompressedRefBytes = useMemo(() => {
        const refVariant = blogData.variants.find(v => v.filename === blogData.compressionRefFilename);
        if (!refVariant) {
            throw new Error(`Reference file ${blogData.compressionRefFilename} not found for decompression`);
        }
        const refFileBase64 = refVariant.compressedBase64;
        return decompressBase64String(refFileBase64);
    }, [blogData]);

    const decompressedRefSvg = useMemo(() => {
        return decodeText(decompressedRefBytes);
    }, [decompressedRefBytes]);

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
        const decompressedDelta = decompressBase64String(variant.compressedBase64);
        const decodedDelta = decodeDelta(decompressedRefBytes, decompressedDelta);
        return decodeText(decodedDelta);
    }, [blogData, theme, windowWidth, decompressedRefSvg]);

    const svgDangerouslySet = useMemo(() => {
        return { __html: svgContent };
    }, [svgContent])

    return inBrowser && !initialRender ?
        <div
            dangerouslySetInnerHTML={svgDangerouslySet}
            suppressHydrationWarning
            className="w-full h-full flex items-center justify-center"
        /> :
        <div />
}