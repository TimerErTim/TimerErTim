import { useCallback, useEffect, useRef, useState } from "react";

export function useContainerWidth(
    initialWidth: number = 1024
) {
    const [width, setWidth] = useState(initialWidth);
    const observerRef = useRef<ResizeObserver | null>(null);
    const containerRef = useCallback((node: HTMLDivElement | null) => {
        observerRef.current?.disconnect();
        observerRef.current = null;
        if (!node) {
            return;
        }
        const updateWidth = () => {
            setWidth(node.clientWidth);
        };
        updateWidth();
        const observer = new ResizeObserver(updateWidth);
        observer.observe(node);
        observerRef.current = observer;
    }, []);
    useEffect(() => () => observerRef.current?.disconnect(), []);
    return [containerRef, width] as const;
}