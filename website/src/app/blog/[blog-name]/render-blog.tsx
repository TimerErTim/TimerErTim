"use client";

import { TransitBlogMetadata } from "@/model/blogs";
import { useEffect, useMemo, useRef, useState } from "react";
import { decompress } from "brotli-compress/js";
import { decode } from "@ably/vcdiff-decoder";
import { useTheme } from "@/lib/theme";
import { useContainerWidth } from "@/lib/container-width";
import { LoadingSpinner } from "@/components/ui/spinner";
import { mergeRefs } from "@/lib/refs";

function decompressBase64String(base64String: string): Uint8Array {
    const binaryString = atob(base64String);
    const buffer = Uint8Array.from(binaryString, (c) => c.charCodeAt(0));
    return decompress(buffer);
}

function decodeDelta(reference: Uint8Array, deltaBytes: Uint8Array): Uint8Array {
    return decode(deltaBytes, reference);
}

function decodeText(buffer: Uint8Array): string {
    return new TextDecoder("utf-8").decode(buffer);
}

function selectVariant(
    variants: TransitBlogMetadata["variants"],
    theme: "light" | "dark",
    containerWidth: number,
) {
    const themeVariants = variants.filter((v) => v.theme === theme);
    if (themeVariants.length === 0) {
        return variants[0];
    }
    const sorted = [...themeVariants].sort((a, b) => b.width_pt - a.width_pt);
    for (const v of sorted) {
        if (v.width_pt <= containerWidth) return v;
    }
    return sorted[sorted.length - 1];
}

export default function RenderBlog({ blogData }: { blogData: TransitBlogMetadata }) {
    const [ready, setReady] = useState(false);

    useEffect(() => {
        setReady(true);
    }, []);

    const decompressedRefBytes = useMemo(() => {
        if (!ready) return null;
        const refVariant = blogData.variants.find(
            (v) => v.filename === blogData.compressionRefFilename,
        );
        if (!refVariant) {
            throw new Error(
                `Reference file ${blogData.compressionRefFilename} not found for decompression`,
            );
        }
        return decompressBase64String(refVariant.compressedBase64);
    }, [blogData, ready]);

    const decompressedRefSvg = useMemo(() => {
        if (!decompressedRefBytes) return null;
        return decodeText(decompressedRefBytes);
    }, [decompressedRefBytes]);

    const theme = useTheme();
    const [divRef, divWidth] = useContainerWidth();

    const svgContent = useMemo(() => {
        if (!decompressedRefSvg || !decompressedRefBytes) return null;
        if (blogData.variants.length === 1) return decompressedRefSvg;
        const variant = selectVariant(blogData.variants, theme, divWidth);
        if (!variant) {
            return decompressedRefSvg;
        }
        if (variant.filename === blogData.compressionRefFilename) {
            return decompressedRefSvg;
        }
        const decompressedDelta = decompressBase64String(variant.compressedBase64);
        const decodedDelta = decodeDelta(decompressedRefBytes, decompressedDelta);
        return decodeText(decodedDelta);
    }, [blogData, theme, divWidth, decompressedRefSvg, decompressedRefBytes]);

    const containerRef = useRef<HTMLDivElement>(null);

    // Inject the SVG content into the DOM
    useEffect(() => {
        if (!containerRef.current || !svgContent) return;

        // 1. Set the raw HTML
        containerRef.current.innerHTML = svgContent;

        // 2. Find and "re-run" the scripts
        const scripts = containerRef.current.getElementsByTagName('script');
        // Remove any previous scripts that were inserted from this source
        const prevScripts = document.querySelectorAll('script[typst-svg-script-applied="1"]');
        prevScripts.forEach(s => s.parentNode?.removeChild(s));
        for (let script of scripts) {
            // Mark original script for identification
            script.setAttribute('typst-svg-script', '1');

            // Create and append the new script
            const newScript = document.createElement('script');
            // Wrap the script content in a catch-all block
            newScript.textContent = 
            `try {${script.textContent}} catch (e) {console.warn("Injected script error suppressed:", e);}`;
            newScript.setAttribute('typst-svg-script-applied', '1');
            document.body.appendChild(newScript);
        }
    }, [svgContent]);

    return (
        <div
            ref={mergeRefs(divRef, containerRef)}
            className="w-full flex items-center justify-center"
        >
            <LoadingSpinner />
        </div>
    );
}
