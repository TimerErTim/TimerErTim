import { title, prose } from "@/components/primitives";

export default function DocsPage() {
  return (
    <div>
      <h1 className={title()}>Docs</h1>
      <p className={`${prose()} mt-6 max-w-xl`}>
        Documentation and notes will live here.
      </p>
    </div>
  );
}
