"use client";

import {
    createContext,
    useContext,
    useEffect,
    useState,
    type ReactNode,
} from "react";

import type { Theme } from "./types";

const ThemeContext = createContext<Theme>("light");

function getSystemTheme(): Theme {
    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
}

export function applyThemeClass(theme: Theme) {
    const root = document.documentElement;
    root.classList.remove("light", "dark");
    root.classList.add(theme);
}

export function ThemeProvider({ children }: { children: ReactNode }) {
    const [theme, setTheme] = useState<Theme>("light");

    useEffect(() => {
        const media = window.matchMedia("(prefers-color-scheme: dark)");
        const syncTheme = () => {
            const nextTheme = getSystemTheme();
            setTheme(nextTheme);
            applyThemeClass(nextTheme);
        };

        syncTheme();
        media.addEventListener("change", syncTheme);
        return () => media.removeEventListener("change", syncTheme);
    }, []);

    return (
        <ThemeContext.Provider value={theme}>{children}</ThemeContext.Provider>
    );
}

export function useTheme(): Theme {
    return useContext(ThemeContext);
}
