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
  title: "How local System-One models compare to TypeSafe's Jev when assisting in the Operating Room",
  description: "Operating rooms are full of equipment controls, and a voice assistant could make them easier to use. I test whether JevK5-2B, an open-weight 2B model, can run locally on an RTX 2080 and control a virtual operating room. Compared with TypeSafe's Jev, it falls behind on both accuracy and speed.",
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
  updated-at: datetime(year: 2026, month: 10, day: 21),
  bibl: bibliography("bib.yaml"),
)

#import "components/comparison.typ": llm-decision-model-comparison-table
#import "components/systemone-choices.typ": systemone-choices
#import "components/field-f1-chart.typ": field-f1-chart
#import "results.typ": latency-raw, model-comparison-raw
#import "deps.typ": z

#let jev-data = model-comparison-raw.models.find(it => (
  it.model_name == "jev-latest"
))
#let jevk5-data = model-comparison-raw.models.find(
  it => it.model_name == "alibiserikbay/JevK5-2B",
)
#let format-percent(value) = z.zi.percent(value * 100)
#let format-count(value) = z.num(value)
#let format-f1(model, field) = format-percent(
  model.field_f1.find(it => it.field == field).f1,
)
#let format-recall(model, field) = format-percent(
  model.field_f1.find(it => it.field == field).recall,
)
#let latency-data(model-name) = latency-raw.per_model.find(
  it => it.model_name == model-name,
)
#let format-latency(model-name) = {
  let report = latency-data(model-name)
  z.zi.ms(report.report.fresh.utterance.p50_ms)
  " / "
  z.zi.ms(report.report.fresh.utterance.p95_ms)
}

= System-One and Jev

If the term is unfamiliar to you, here is the short version: System 1 is the
fast, intuitive, and emotional system, while System 2 is the slow, deliberate,
and logical one.
Daniel Kahneman, Nobel Prize laureate in Economics, coined this term in his
psychology work on judgment and decision making, which challenged the idea that
humans are rational decision makers.
@src:kahnemann-thinking-fast-and-slow

TypeSafe leaned into this and named their new type of classification models
"System-One Models", in contrast to text-generating Large Language Models
(LLMs), which are more like System 2.
Jev is their first System-One model release.
@src:typesafe-systemone

== How do they compare to LLMs?

LLMs work by predicting the most probable next token, step by step.
Especially for machine-to-machine communication, people have tried to squeeze
LLM output into a schema.
There are techniques for that, but they limit the model in its reasoning
capabilities @src:typesafe-systemone, and they are nowhere near efficient enough
for realtime applications at a feasible cost.

So what does Jev do differently?
It takes the same input as basic LLMs (which is plain text) and a set of
questions with their answer candidates.
Its output is then a set of probabilities for each question.
The model fundamentally does not generate text and therefore cannot return an
answer outside the supplied schema.
#footnote[Which does *not* mean it cannot pick an incorrect answer.]
That reliability and efficiency make it a good fit for realtime applications.
@src:typesafe-systemone

#{
  show: figure.with(
    caption: [Comparison between System-One and LLMs @src:typesafe-systemone],
  )
  llm-decision-model-comparison-table()
}

Oh, and they are really really cheap.
Jev is currently listed at 0.0047€ per 1M input tokens, with output tokens being
free.
TypeSafe attributes this price to the massive parallelism of its decision heads.
@src:typesafe-systemone

== Local Open-Weight alternatives

Despite Jev having been released only on September 15th, open-weight
alternatives have sprouted up like mushrooms.
They mostly work by architecturally modifying and fine-tuning a pre-trained
model on a specific dataset.
Since the problem is so much easier, way smaller models get acceptable results.

#success-callout(heading: [Open weights #sym.arrow Great news for privacy])[
  TypeSafe AI claims not to train on your data @src:typesafe-systemone, which
  sounds good on paper.
  For highly sensitive applications, like handling health data, this is not
  enough.
  Open-weight models can be self-hosted, which gives the operator more control
  over where inference data goes.
  It does not guarantee that the whole application keeps no data off-premises.
]

Some notable contenders are:
- #link("https://github.com/allebee/jevk5")[JevK5] - 4B params, the open-weight
  benchmark leader when I started this experiment
- #link("https://github.com/jaredpalmer/kev")[Kev] - Similar design to JevK5
- #link(
    "https://huggingface.co/google/diffusiongemma-26B-A4B-it",
  )[DiffusionGemma] - \~26B params, based on diffusion
- #link("https://github.com/NandhaKishorM/laya")[Laya] - \~500MB size, less than
  50ms latency even on CPU, often requires fine-tuning

= Project introduction

== The virtual operating room

Operating rooms have lots of equipment, and each device brings its own controls.
A voice assistant could save you the constant reaching for knobs and menus.
But a natural command is not enough on its own.
The system has to identify which device and setting the speaker means, handle
values precisely, and avoid changing anything the speaker did not ask to change.

For this experiment, I use a virtual room rather than actual equipment or a
clinical workflow.
It has an insufflator, an operating light, a surgical table, and an endoscope.
Each object maps to a handful of state fields, such as gas flow, light
brightness, table tilt, or endoscope zoom.
Here is the room and the set of actions for each object.

#{
  show: figure.with(
    caption: [
      The virtual operating room with the controlled equipment highlighted in
      color: insufflator, light, table, and endoscope.
    ],
  )
  import "components/room-overview.typ": annotated-room
  annotated-room()
}

#{
  show: figure.with(
    caption: [Equipment fields represented in the virtual room.],
  )
  import "components/room-overview.typ": room-fields-table
  room-fields-table()
}

No patient, physical device, or clinical workflow is part of this experiment.
I focus on the narrow question of whether a System-One model can turn short
utterances into those room-state fields.

== From utterance to room state

The API gives the model the current state, the utterance, and questions about
possible field values.
The choices are defined by the application.
For example, a question could ask which of several light modes the speaker
requested or what brightness value they want.
Here is a request for “Zoom the camera in.”
The response score of 3.79 is not a defined “one step in” command.
Application logic still has to map it to a target and enforce allowed bounds.
The example also asks about the light, where `null` means no requested change.

There are three kinds of questions in the API.
The table below shows each one in context.

#{
  show: figure.with(
    caption: [System-One question types and example outputs.],
  )
  systemone-choices()
}

#{
  show: figure.with(
    caption: [A single utterance becomes typed field answers.
      The camera score is a prediction, not a command sent to equipment.],
  )
  raw(read("assets/systemone_input.json").trim(), block: true, lang: "json")
  raw(read("assets/systemone_output.json").trim(), block: true, lang: "json")
}

The model output is not the room state itself.
Application code still has to interpret the answer, apply limits, and decide
whether to act.
That boundary matters: a valid `choice` cannot name an option outside its
schema, but it can still choose the wrong option.

== Defining the choices

For the benchmark, I describe possible values for each field and ask the model
to select among them.
Numeric commands need a little care.
If someone says “turn the brightness up by twenty percent,” the model must infer
the requested change, then choose a supported target.
“Up” is relative to current state; `20` is not automatically the correct answer
unless the application defines that mapping.

The criteria table shows candidate language for light brightness and table tilt.
It shows what the classifier sees, not a complete specification of device safety
limits.

#{
  show: figure.with(
    caption: [Illustrative candidate criteria for two numeric room fields.],
  )
  import "components/criteria-table.typ": criteria-table
  criteria-table(columns: (auto, 1fr, 1fr, 1fr))
}

// TODO: Document exactly how numeric phrases map to candidate targets, including current-state handling and bounds.

= Running locally

JevK5 includes a 2B-parameter model that runs on my RTX 2080.
The server exposes a System-One-compatible API, so the surrounding request
format stays close to the hosted Jev example.
I use the model and package revision shown below; this is enough to reproduce
the environment setup, but not the whole benchmark pipeline.

#{
  show: zebraw.with(header: [pyproject.toml])
  raw(read("assets/pyproject_jevk5.toml").trim(), block: true, lang: "toml")
}

I start the server with
`uv run jevk5-serve --model alibiserikbay/JevK5-2B --port 8090 --host 0.0.0.0`.
The host option binds beyond localhost, so do not put this on an untrusted
network without access controls.

== What “local” does and does not mean

Running inference on hardware the hospital controls means the request does not
need to be sent to a hosted model provider.
That matters for sensitive health data.
Local hosting is one important piece of a privacy-conscious system, alongside
the hospital’s existing rules for data access and handling.

= Evaluation

== Dataset and procedure

I use five virtual surgery scenarios: appendectomy, hernia repair,
fundoplication, cholecystectomy, and sleeve gastrectomy.
The benchmark setup uses 1,000 generated cases with 12 utterances each,
including small talk that should not change room state.
The benchmark uses `inclusionai/ling-3.0-flash-vl` as the generator for cases
and expected output states.
That makes a large test set quickly, but generated labels are not the same thing
as expert-reviewed clinical ground truth.

I evaluate each utterance on its own and count the predicted field values that
match the expected values.
The comparison data contains #format-count(
  jev-data.entries,
) Jev entries and #format-count(jevk5-data.entries) JevK5-2B entries from
#format-count(jevk5-data.cases) local-model cases.
The paired comparison uses those same entries.
JevK5-2B is correct where Jev is not on #format-count(
  model-comparison-raw.paired.first().only_a_correct,
) entries.
Jev is correct where JevK5-2B is not on #format-count(
  model-comparison-raw.paired.first().only_b_correct,
).

// TODO: Describe how cases were sampled, how expected states were checked, and why local-model evaluation covered fewer cases than Jev.
// TODO: Report benchmark hardware/software for Jev, and clarify which JevK5 measurements ran on the RTX 2080.

== Overall results

#{
  show: figure.with(
    caption: [Recorded utterance-level accuracy and other metrics for Jev and
      JevK5-2B.],
  )
  import "components/overview-results-table.typ": overview-results-table
  overview-results-table()
}

In the recorded runs, Jev performs better than JevK5-2B on utterance-level
accuracy.
Jev also performs better in the rolling evaluation, where predictions are
applied through an utterance sequence and earlier mistakes can affect later
state.
I keep these measurements separate because JevK5-2B has fewer evaluated cases.
The paired comparison uses the same cases for both models and points in the same
direction.

For the full comparison, the field accuracy is #format-percent(
  jev-data.accuracy_fresh,
) for Jev and #format-percent(jevk5-data.accuracy_fresh) for JevK5-2B.
In rolling mode, it is #format-percent(jev-data.accuracy_rolling) and
#format-percent(jevk5-data.accuracy_rolling), respectively.
The paired comparison above says the same.

The table’s field macro-F1 averages per-field F1 scores, so a field with many
examples does not drown out one with poor performance.
The models do not have the same coverage in every sample set, so treat this as a
summary of the supplied measurements, not a controlled clinical comparison.

== It depends on the field

#{
  show: figure.with(
    caption: [Field-level F1 scores from the recorded comparison data.
      Each bar measures classification quality for one state field.],
  )
  field-f1-chart(
    model-names: ("jev-latest", "alibiserikbay/JevK5-2B"),
    labels: ("Jev", "JevK5-2B"),
    height: 11cm,
  )
}

Jev handles several fields well in this generated set, but safety interlock
activation is a glaring exception: its F1 is #format-f1(
  jev-data,
  "safety_interlock_active",
), with recall of #format-recall(jev-data, "safety_interlock_active").
JevK5-2B does even worse on that field, with F1 of #format-f1(
  jevk5-data,
  "safety_interlock_active",
) and recall of #format-recall(jevk5-data, "safety_interlock_active").
Both models miss nearly all positive interlock cases.
For a control system, that alone kills any idea of letting a model own safety
decisions.
Table tilt is another weaker field for Jev, at F1 #format-f1(
  jev-data,
  "table_tilt_degrees",
).

There may be a dataset issue here too.
For example, an utterance like “tilt table by 5 degrees” could have an expected
state of `table_tilt: -5`, depending on how direction was interpreted.
If expected signs are inconsistent with the utterance, that would lower the
score without being a model error.
I have not verified this explains the table-tilt result, so it needs checking
against the cases before drawing conclusions.

// TODO: Audit generated table-tilt labels for direction and sign mismatches. Compare examples like “tilt table by 5 degrees” with their expected values.

Aggregate scores can hide exactly these failures.

== Fast enough, on which machine?

Jev’s recorded fresh p50/p95 latency is #format-latency("jev-latest") per
utterance.
JevK5-2B’s is #format-latency("alibiserikbay/JevK5-2B").
So the local model ran on my RTX 2080, but this particular 2B configuration was
not fast enough for the near-real-time interaction I had in mind.
“It runs locally” and “it is useful locally” are different claims.

// TODO: Add a latency figure with hardware details, warm-up policy, and whether timing includes network or API overhead.

= Conclusion

System-One’s constrained outputs are an appealing interface for
equipment-control software: the schema narrows what the model can return, and
the supplied API can score multiple fields directly.
My experiment does not show that JevK5-2B is a practical local substitute for
Jev.
It shows the opposite for this task and setup: lower accuracy, a very weak
safety-interlock field, and much higher latency.

// TODO: Add links to the GitHub project and general references.

This is a virtual benchmark built from generated cases.
It says nothing about safety, clinical usefulness, or performance with real
operating-room speech.
Before a model could touch real equipment, a production design would need
independent safety controls, proper handling of uncertainty, and validation with
domain experts.

// TODO: Test calibrated confidence thresholds and abstention policies per field; measure the accuracy/coverage/silent-failure trade-off.
// TODO: Investigate why safety-interlock recall is so low; do not treat confidence gating as a replacement for a deterministic safety interlock.
// TODO: Compare a faster local setup, the full JevK5 model, and fine-tuned alternatives such as Laya on identical paired examples.
// TODO: Embed the demo video where the web format allows it. Otherwise link to the YouTube recording and add links to the GitHub project and general reference materials.
// TODO: Add human-reviewed utterances and labels, including accents, interruptions, ambiguous commands, and noisy room audio.
// TODO: Link the benchmark generator, runner, and raw result artifacts so readers can reproduce every table and chart.

The next step is not to let an LLM near the operating-room switches.
It is to find out whether better data, tighter task definitions, and a faster
local model can close the gap without weakening the safety boundary.
