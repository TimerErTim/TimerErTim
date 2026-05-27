"use client";

import { useRef, useEffect } from 'react';
import { withGlobalRenderer } from '@myriaddreamin/typst.ts/dist/esm/contrib/global-renderer.mjs';
import * as typst from '@myriaddreamin/typst.ts';

// Remove unused: import htmlLayerCss from './typst.css?inline';

// Set default wasm module path for the typst-ts renderer
let moduleInitOptions = {
    beforeBuild: [],
    getModule: () => "/_typst_ts_renderer_bg.wasm"
};

type TypstDocumentProps = {
    artifactB64: string;
    fill?: string;
};

export default function TypstDocument({ artifactB64, fill = "#ffffff" }: TypstDocumentProps) {
    const displayDivRef = useRef<HTMLDivElement | null>(null);
    const artifact = Uint8Array.from(atob(artifactB64), c => c.charCodeAt(0));

    useEffect(() => {
        if (!displayDivRef.current) return;

        let resizeObserver: ResizeObserver | null = null;

        const doRender = (renderer: any) => {
            const divElem = displayDivRef.current;
            if (!divElem) return;
            return renderer.render({
                artifactContent: artifact,
                format: 'vector',
                backgroundColor: fill,
                container: divElem,
                pixelPerPt: 3,
            });
        };

        // Helper to trigger a (re-)render
        const triggerRender = () => {
            const divElem = displayDivRef.current;
            if (!divElem) return;
            if (!artifact?.length) {
                divElem.innerHTML = '';
                return;
            }
            withGlobalRenderer(typst.createTypstRenderer, moduleInitOptions, doRender);
        };

        triggerRender();

        // Setup ResizeObserver to trigger render on resize
        if (window.ResizeObserver) {
            resizeObserver = new ResizeObserver(() => {
                triggerRender();
            });
            if (displayDivRef.current) {
                resizeObserver.observe(displayDivRef.current);
            }
        }

        return () => {
            if (resizeObserver && displayDivRef.current) {
                resizeObserver.unobserve(displayDivRef.current);
            }
        };
    }, [artifactB64, artifact, fill]);

    // Optionally: style could be provided for .typst-app here or elsewhere
    return (
        <div>
            <div
                className="typst-app"
                style={{ height: '0' }}
                ref={displayDivRef}
            />
        </div>
    );
}
