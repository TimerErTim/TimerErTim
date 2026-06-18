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
            <div
                className={twMerge(
                    "size-8 animate-spin rounded-full border-md border-border",
                    "border-t-accent border-l-accent border-r-accent border-b-transparent"
                )}
            />
      
        </div>
    );
}
