import { title, prose } from "@/components/primitives";
import { site } from "@/site";

export default function AboutPage() {
  return (
    <div>
      <h1 className={title()}>{site.content.about.title}</h1>
      <p className={`${prose()} mt-6 max-w-xl`}>
        {site.content.about.body}
      </p>
    </div>
  );
}
