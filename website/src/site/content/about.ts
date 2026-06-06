import { identity } from "@/site/identity";

export const aboutContent = {
  title: "About",
  body: `Personal site and blog by ${identity.name}. Essays on software, tools, and whatever else seems worth writing down.`,
} as const;
