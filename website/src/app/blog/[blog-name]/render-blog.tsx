"use client";

import { TransitBlogMetadata } from "@/model/blogs";
import { useCallback, useEffect, useMemo, useRef, useState } from "react";
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

    const variantByFilename = useMemo(() => {
        return new Map(blogData.variants.map((variant) => [variant.filename, variant]));
    }, [blogData.variants]);

    const decodedBytesCache = useRef(new Map<string, Uint8Array>());

    const getDecodedBytes = useCallback((filename: string): Uint8Array => {
        const cached = decodedBytesCache.current.get(filename);
        if (cached) {
            return cached;
        }

        const decodeWithVisit = (current: string, visiting: Set<string>): Uint8Array => {
            const cachedBytes = decodedBytesCache.current.get(current);
            if (cachedBytes) {
                return cachedBytes;
            }
            if (visiting.has(current)) {
                throw new Error(`Compression cycle detected at ${current}`);
            }
            visiting.add(current);

            const variant = variantByFilename.get(current);
            if (!variant) {
                throw new Error(`Variant ${current} not found for decompression`);
            }

            const decompressedPayload = decompressBase64String(variant.compressedBase64);
            let decoded: Uint8Array;
            if (variant.referenceVariant === null) {
                decoded = decompressedPayload;
            } else {
                const referenceBytes = decodeWithVisit(variant.referenceVariant, visiting);
                decoded = decodeDelta(referenceBytes, decompressedPayload);
            }

            decodedBytesCache.current.set(current, decoded);
            return decoded;
        };

        return decodeWithVisit(filename, new Set());
    }, [variantByFilename]);

    const theme = useTheme();
    const [divRef, divWidth] = useContainerWidth();

    const svgContent = useMemo(() => {
        if (!ready) return null;
        if (blogData.variants.length === 1) {
            const onlyVariant = blogData.variants[0];
            if (!onlyVariant) return null;
            return decodeText(getDecodedBytes(onlyVariant.filename));
        }
        const variant = selectVariant(blogData.variants, theme, divWidth);
        const fallbackVariant = blogData.variants[0];
        if (!variant) {
            if (!fallbackVariant) return null;
            return decodeText(getDecodedBytes(fallbackVariant.filename));
        }
        return decodeText(getDecodedBytes(variant.filename));
    }, [blogData.variants, theme, divWidth, ready, getDecodedBytes]);

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
