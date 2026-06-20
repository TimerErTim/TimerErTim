"use client";

import { extractVariantText } from "concat-brotli/browser";
import { decompress } from "brotli-compress/js";
import { TransitBlogMetadata } from "@/model/blogs";
import { useEffect, useMemo, useRef, useState } from "react";
import { useTheme } from "@/lib/theme";
import { useContainerWidth } from "@/lib/container-width";
import { LoadingSpinner } from "@/components/ui/spinner";
import { mergeRefs } from "@/lib/refs";

function decompressBase64String(base64String: string): Uint8Array {
    const binaryString = atob(base64String);
    return Uint8Array.from(binaryString, (character) => character.charCodeAt(0));
}

function selectVariant(
    variants: TransitBlogMetadata["variants"],
    theme: "light" | "dark",
    containerWidth: number,
) {
    const themeVariants = variants.filter((variant) => variant.theme === theme);
    if (themeVariants.length === 0) {
        return variants[0];
    }
    const sorted = [...themeVariants].sort((left, right) => right.width_pt - left.width_pt);
    for (const variant of sorted) {
        if (variant.width_pt <= containerWidth) {
            return variant;
        }
    }
    return sorted[sorted.length - 1];
}

export default function RenderBlog({ blogData }: { blogData: TransitBlogMetadata }) {
    const [ready, setReady] = useState(false);

    useEffect(() => {
        setReady(true);
    }, []);

    const compressedBytes = useMemo(() => {
        if (!ready) {
            return null;
        }
        return decompressBase64String(blogData.compressedBase64);
    }, [blogData.compressedBase64, ready]);

    const bundleBytesRef = useRef<Uint8Array | null>(null);
    const bundleSourceRef = useRef<Uint8Array | null>(null);

    const getBundleBytes = useMemo(() => {
        return () => {
            if (!compressedBytes) {
                return null;
            }
            if (bundleSourceRef.current === compressedBytes && bundleBytesRef.current) {
                return bundleBytesRef.current;
            }
            const bundleBytes = decompress(compressedBytes);
            bundleSourceRef.current = compressedBytes;
            bundleBytesRef.current = bundleBytes;
            return bundleBytes;
        };
    }, [compressedBytes]);

    const theme = useTheme();
    const [divRef, divWidth] = useContainerWidth();

    const svgContent = useMemo(() => {
        const bundleBytes = getBundleBytes();
        if (!bundleBytes) {
            return null;
        }
        const variant = blogData.variants.length === 1
            ? blogData.variants[0]
            : selectVariant(blogData.variants, theme, divWidth);
        if (!variant) {
            return null;
        }
        return extractVariantText(bundleBytes, variant);
    }, [blogData.variants, theme, divWidth, getBundleBytes]);

    const containerRef = useRef<HTMLDivElement>(null);

    useEffect(() => {
        if (!containerRef.current || !svgContent) {
            return;
        }

        containerRef.current.innerHTML = svgContent;

        const scripts = containerRef.current.getElementsByTagName("script");
        const prevScripts = document.querySelectorAll('script[typst-svg-script-applied="1"]');
        prevScripts.forEach((script) => script.parentNode?.removeChild(script));
        for (const script of scripts) {
            script.setAttribute("typst-svg-script", "1");

            const newScript = document.createElement("script");
            newScript.textContent =
                `try {${script.textContent}} catch (e) {console.warn("Injected script error suppressed:", e);}`;
            newScript.setAttribute("typst-svg-script-applied", "1");
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
