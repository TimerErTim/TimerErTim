import { twMerge } from "@/lib/tw";

export function LoadingSpinner({ className }: { className?: string }) {
    return (
        <div
            role="status"
            aria-label="Loading"
            className={twMerge(
                "flex w-full items-center justify-center py-16",
                className,
            )}
        >
            <div className="size-8 animate-spin rounded-full border-2 border-border border-t-accent" />
        </div>
    );
}
