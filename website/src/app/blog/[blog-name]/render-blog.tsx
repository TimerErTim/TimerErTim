"use client";

import { TransitBlogMetadata } from "@/model/blogs";
import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { decompress } from "brotli-compress/js";
import { Idiomorph } from 'idiomorph';
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

    const svgVariant = useMemo(() => {
        if (!ready) return null;
        if (blogData.variants.length === 1) {
            return blogData.variants[0];
        }
        return selectVariant(blogData.variants, theme, divWidth);
    }, [blogData.variants, theme, divWidth, ready]);

    const svgContent = useMemo(() => {
        if (!svgVariant) return null;
        return decodeText(getDecodedBytes(svgVariant.filename));
    }, [svgVariant, getDecodedBytes]);

    const containerRef = useRef<HTMLDivElement>(null);

    // Inject the SVG content into the DOM
    useEffect(() => {
        if (!containerRef.current || !svgContent) return;

        // 1. Set the raw HTML using idiomorph
        try {
            //containerRef.current.innerHTML = svgContent;
            Idiomorph.morph(containerRef.current, svgContent, {
                morphStyle: 'innerHTML',
                callbacks: {
                    afterNodeMorphed(_old, newNode) {
                        // 2. Wait for the next animation frame
                        requestAnimationFrame(() => {

                            if (newNode instanceof SVGGraphicsElement) {
                                const triggerReflow = (newNode as any as HTMLElement).offsetHeight;
                                // 3. Synchronously read clientRect to flush the layout queue
                                void newNode.getBoundingClientRect();
                                const rect = newNode.getBBox()
                                if (rect.width == 0 && rect.height == 0) {
                                    console.log(newNode)
                                    console.log(newNode.getElementsByTagName("image").length > 0)
                                    // Remount the node in the DOM by removing and re-inserting it
                                    const parent = newNode.parentNode;
                                    if (parent) {
                                        const next = newNode.nextSibling;
                                        parent.removeChild(newNode);
                                        if (next) {
                                            parent.insertBefore(newNode, next);
                                        } else {
                                            parent.appendChild(newNode);
                                        }
                                        console.log("reinserted")
                                        console.log(newNode.getBBox())
                                    }

                                }
                            } else if (newNode instanceof HTMLElement) {
                                void newNode.offsetWidth // TypeScript knows this is safe
                            }
                        });
                    }
                }
            });
        } catch (error) {
            if (!(error instanceof SyntaxError)) {
                console.error('Error morphing SVG content:', error);
            }
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
