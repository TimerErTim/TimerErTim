#import "../common/components/xhtml.typ": xhtml
#import "../common/template.typ": blog-entry
#import "../common/theming.typ": catppuccin-accents, theme
#import "../common/deps.typ": strfmt
#import "../common/components/depth.typ": depth-shadow-block
#import "../common/components/callouts.typ": (
  danger-callout, info-callout, success-callout, warning-callout,
)
#import "../common/components/pikchr.typ": color-to-pikchr, pikchr
#import "../common/variants.typ": (
  broader-than, hide-in-preview, targets-web, web-or,
)
#import "deps.typ": conch, cz, sj, zebraw

#set text(lang: "en")
#set document(
  title: "How local System-One models compare to Typesafe's Jev when assisting in the Operating Room",
  description: "Operating rooms are sophisticated environments with lots of knobs and levers to turn. Room control assistants can greatly help in managing this complexity and have long been established in private smart homes. And yet, reliability as well as privacy concerns make realtime, natural use in operating rooms difficult. My RTX2080 - and by extension in-house hospital infrastructure - is just good enough to run JevK5-2B locally, an open-source replication of the popular Jev model by Typesafe. I am exploring its performance when assisting in the operating room, and compare it to upstream Jev. The results...", // TODO: Add results summary
  author: "Tim Peko (TimerErTim)",
  keywords: (
    "System One",
    "Jev",
    "JevK5",
    "Medicine",
    "Rust",
    "Analysis",
  ),
)
#show: blog-entry.with(
  target: "web",
  created-at: datetime(year: 2026, month: 10, day: 11),
  //updated-at: datetime(year: 2026, month: 6, day: 12),
  bibl: bibliography("bib.yaml"),
)

#import "components/comparison.typ": llm-decision-model-comparison-table

= System-One and Jev

If the term is unfamiliar to you, it probably makes most sense to start with a short differentiation between System 1 and System 2. System 1 is the fast, intuitive, and emotional system, while System 2 is the slow, more deliberative, and more logical system. This term was coined by Daniel Kahneman, a Nobel Prize laureate in Economics for his seminal work in psychology that challenged the rational model of judgment and decision making. @src:kahnemann-thinking-fast-and-slow

As a homage TypeSafe decided to name their new type of classification models "System-One Models", reflecting the contrast to text generating Large Language Models (LLMs), which are more similar to System 2. Jev is their first release of a System-One model.
@src:typesafe-systemone

== How do they compare to LLMs?

LLMs work by predicting the most probable next token step by step. Particularely in machine-machine communication, there have been efforts to conform LLM output to a certain schema. While there are techniques to achieve this, they limit the model in their reasoning capabilities @src:typesafe-systemone, and are nowhere near efficient enough to be used in realtime application at a feasable cost.

So what does Jev do differently? It takes the same input as basic LLMs (which is plain text) and a set of questions with their answer candidates. Its output is then a set of probabilities for each question. The model fundamentally does not generate text and therefore is physically incapable of hallucinating invalid answers. #footnote[Which does *not* mean unable to pick an incorrect answer] This schema reliability and gained efficiency makes it a perfect fit for realtime applications. @src:typesafe-systemone

#quote(block: true, attribution: [
  #set sub(size: 0.8em, baseline: 0.0em)
  #set super(size: 0.8em, baseline: -0.2em)
  @src:systemone-docs])[
  #{
    show: emph
  }
]

#{
  show: figure.with(
    caption: [Comparison between System-One and LLMs @src:typesafe-systemone],
  )
  llm-decision-model-comparison-table()
}

Oh, and they are really really cheap. Jev is currently listed at 0.0047€ per 1M input tokens, with output tokens being free. The massive parallelism of every decision head makes this possible. @src:typesafe-systemone

== Local Open-Weight alternatives

Despite Jev just being released on September 15th, there have sprouded up open weight alternatives like mushrooms in a forest. They mostly work by architecturally modifying and fine-tuning a pre-trained model on a specific dataset. Because of the increased problem efficiency, way smaller models can be used for acceptable results.

#success-callout(heading: [Open-Weights #sym.arrow Great news for privacy])[
  TypeSafe AI claims to not train on your data @src:typesafe-systemone, which sounds good on paper. For highly sensitive applications, like handling health data, this is not enough. Open-Weight models can be self-hosted and thus guarantee no data leaving your premises.
]

Some notable contenders are:
- #link("https://github.com/allebee/jevk5")[JevK5] - 4B Params, Open-Weight benchmark leader
- #link("https://github.com/jaredpalmer/kev")[Kev] - Similar design to JevK5
- #link("https://huggingface.co/google/diffusiongemma-26B-A4B-it")[DiffusionGemma] - \~26B Params, based on Diffusion
- #link("https://github.com/NandhaKishorM/laya")[Laya] - \~500MB Size, \<50ms Latency even on CPU, often requires fine-tuning


= Project introduction



== Setup of Operating Room

== System-One integration

_JevK5_ comes with a 2B Parameter version, and it manages to run on my RTX2080. While not as accurate as the full 4B version, it is close enough. Starting a System-One compatible API server is as simple as running `uv run jevk5-serve --model alibiserikbay/JevK5-2B --port 8090 --host 0.0.0.0` in my setup.

#{
  show: zebraw.with(
    header: [pyproject.toml],
  )
  raw(read("assets/pyproject_jevk5.toml").trim(), block: true, lang: "toml")
}


Number extraction of utterance
One Choice per object action

= Evaluation

How did we get the dataset?
How did we perform the benchmark?

= Conclusion

Outlook
Further improvements:
- Confidence calibration and gating
- Laya (+ Finetuning)

