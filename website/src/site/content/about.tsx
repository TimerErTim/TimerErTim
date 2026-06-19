import { prose, title } from "@/components/primitives";

export const aboutDescription =
  "Tim Peko (TimerErTim). Bioinformatics student in Hagenberg. I build things and write about them here.";

export default function AboutContent() {
  return (
    <article className="max-w-xl">
      <h1 className={title()}>About</h1>

      <div className={`${prose()} mt-2 flex flex-col gap-4`}>
        <p>
          I&apos;m Tim Peko, TimerErTim online. I start projects I tell myself are
          useless and then keep going. Most of this site comes from that.
        </p>

        <section>
          <h2 className={title({ size: "sm" })}>Now</h2>
          <p className="mt-2">
            Studying Bioinformatics at <a href="https://fh-ooe.at/studienangebot/medizin-und-bioinformatik-bachelor">FH Oberösterreich, Hagenberg</a>. Simultaneously working at <a href="https://www.optadata.at/">opta
            data Österreich</a>. I try to establish <a href="https://typst.app/">Typst</a> at my university.
          </p>
        </section>

        <section>
          <h2 className={title({ size: "sm" })}>Projects</h2>
          <ul className="mt-2 flex flex-col gap-3 pl-5 list-disc">
            <li>
              <strong>Document Dataset Synthesizer</strong>. Synthetic training data for
              an in-house classifier. My A-level project. We won the competition.
            </li>
            <li>
              <strong>order.expert</strong>. Diabetes supply ordering, live in Austrian
              states. Less paper, clearer flow for patients.
            </li>
            <li>
              <strong>Typst at Hagenberg</strong>. Talks and experiments with students
              who care about typesetting.
            </li>
          </ul>
        </section>

        <section>
          <h2 className={title({ size: "sm" })}>Off the clock</h2>
          <p className="mt-2">
            I travel when I can and try to collect expierences wherever possible. Both beat reading about it
            from a desk.
          </p>
        </section>

        <p>
          From February or March 2027 I want three months abroad for an internship in a deep learning or bioinformatics team. Until
          then: blog and side builds on this site.
        </p>
      </div>
    </article>
  );
}
