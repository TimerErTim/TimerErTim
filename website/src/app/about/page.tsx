import { title, prose } from "@/components/primitives";

export default function AboutPage() {
  return (
    <div>
      <h1 className={title()}>About</h1>
      <p className={`${prose()} mt-6 max-w-xl`}>
        Personal site and blog by timerertim. Essays on software, tools, and
        whatever else seems worth writing down.
      </p>
    </div>
  );
}
