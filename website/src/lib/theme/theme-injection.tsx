export function PrePaintThemeInjectionScript() {
    return <script
        suppressHydrationWarning
        dangerouslySetInnerHTML={{
        __html: `(function(){var d=document.documentElement,t=window.matchMedia("(prefers-color-scheme: dark)").matches?"dark":"light";d.classList.remove("light","dark");d.classList.add(t);})();`,
        }}
    />
}