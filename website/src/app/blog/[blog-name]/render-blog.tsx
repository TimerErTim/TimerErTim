"use client";

import { TransitBlogMetadata } from "@/model/blogs";
import { useTheme } from "@/theme";
import { useMemo, useEffect, useState } from "react";
import { decompress } from "brotli-compress/js";
import { decode } from "@ably/vcdiff-decoder";


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

    function selectVariant(variants: TransitBlogMetadata["variants"], theme: "light" | "dark", windowWidth: number) {
        const themeVariants = variants.filter(v => v.theme === theme);
        if (themeVariants.length === 0) {
            return variants[0];
        }
        const sorted = [...themeVariants].sort((a, b) => a.width_pt - b.width_pt);
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

    const svgContent = useMemo(() => {
        if (blogData.variants.length === 1) return decompressedRefSvg;
        const variant = selectVariant(blogData.variants, theme, windowWidth);
        if (!variant) {
            return decompressedRefSvg;
        }
        if (variant.filename === blogData.compressionRefFilename) {
            return decompressedRefSvg;
        }
        const decompressedDelta = decompressBase64String(variant.compressedBase64);
        const decodedDelta = decodeDelta(decompressedRefBytes, decompressedDelta);
        return decodeText(decodedDelta);
    }, [blogData, theme, windowWidth, decompressedRefSvg, decompressedRefBytes]);
    
    return (
        <div>
            {inBrowser && !initialRender ?
            <div dangerouslySetInnerHTML={{ __html: svgContent }} suppressHydrationWarning/> :
            <div/>}
        </div>
    );
}
