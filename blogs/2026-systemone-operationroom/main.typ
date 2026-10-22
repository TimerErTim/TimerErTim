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
  description: "Operating rooms have lots of knobs and levers to turn. Voice assistants are already common in smart homes, but reliable, real-time control is a different challenge in an operating room. I test JevK5-2B, an open-weight 2B model, running locally on my RTX 2080, and compare it with TypeSafe's Jev on a virtual operating room task. Jev is more accurate and faster in my tests, so this JevK5-2B setup doesn't yet look like a practical local alternative.",
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
#import "components/room-overview.typ": (
  annotated-room, object-colors, room-fields-table,
)
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

#cite(form: none, <src:yt-video>)

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

== Local Open-Weight alternatives <chp:local-open-weight-alternatives>

Despite Jev having been released only on September 15th, open-weight
alternatives have sprouted up like mushrooms.
They mostly work by architecturally modifying and fine-tuning a pre-trained
language model on a specific dataset.
Since the problem space is less fragmented, way smaller models get acceptable
results.

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

So let me quickly cook up a beautiful virtual room for this experiment.
This room has an #text(
  object-colors.insufflator,
)[insufflator], an operating #text(object-colors.light)[light], a surgical
#text(object-colors.table)[table], and an #text(
  object-colors.endoscope,
)[endoscope].
Each object maps to a handful of state fields, such as gas flow, light
brightness, table tilt, or endoscope zoom.
@fig:annotated-room shows the room and @tbl:room-fields-table shows the set of
actions for each object.

#{
  show: it => [#it <fig:annotated-room>]
  show: figure.with(
    caption: [
      The virtual operating room with the controlled equipment highlighted in
      color: insufflator, light, table, and endoscope.
    ],
  )
  annotated-room()
}

#{
  show: it => [#it <tbl:room-fields-table>]
  show: figure.with(
    caption: [Equipment fields represented in the virtual room.],
  )
  room-fields-table()
}

There are a lot of complex components involved to make this work reliably in the
real world.
Luckily, the virtual room simplifies things greatly and allows us to focus on
the narrow question of whether a System-One model can turn short utterances into
actionable commands we can automatically apply to the objects in the room.

== From utterance to room state

The API gives the model the current state, the utterance, and questions about
possible actions to modify the fields/attributes of the objects in the room.
@tbl:systemone-choices shows the three kinds of questions in the API.
The possible answers are predetermined by the application, read more on that
in <chp:defining-the-choices>.

#{
  show: it => [#it <tbl:systemone-choices>]
  show: figure.with(
    caption: [System-One question types and example outputs.],
  )
  systemone-choices()
}

For example, a question could ask which of several light modes the speaker
requested or what brightness value they want.
@raw:systemone_input.json shows a request for “Zoom the camera in.”
The response score of 3.79 is not a defined “one step in” command.
Application logic still has to map it to a target and enforce allowed bounds.
#footnote[The JSON example is not representative for the actual application
  choice schema.] The example also asks about the light, where `null` means no
requested change.

#{
  show: block.with(breakable: true)
  {
    show: it => [#it <raw:systemone_input.json>]
    show: figure.with(
      caption: [A System-One model input: an utterance and current room state in
        JSON.],
      kind: raw,
    )
    show: block.with(breakable: false)
    show: zebraw.with(indentation: 2)
    raw(read("assets/systemone_input.json").trim(), block: true, lang: "json")
  }
  {
    show: it => [#it <raw:systemone_output.json>]
    show: figure.with(
      caption: [The model's prediction: typed field outputs per equipment, not
        direct hardware commands.],
      kind: raw,
    )
    show: block.with(breakable: false)
    show: zebraw.with(indentation: 2)
    raw(read("assets/systemone_output.json").trim(), block: true, lang: "json")
  }
}

In @raw:systemone_output.json the model output is not the room state itself.
Application code still has to interpret the answer, apply limits, and decide
whether to act based on confidence thresholds.
The confidence score of a valid `choice` is very important, as it cannot name an
option outside its criteria answer space, but it can still choose an incorrect
option.
So that is our only way to know how much to trust that confined answer.

== Defining the choices <chp:defining-the-choices>

In some cases the answer space is trivial, like for the light mode, which is
either `Normal`, `AmbientRed`, `CavityFocus`, or `null` if no change is
requested.
But what about other continuous fields like the brightness?

#{
  show: it => [#it <tbl:criteria-table>]
  show: figure.with(
    caption: [Illustrative candidate criteria for two numeric room fields.],
  )
  import "components/criteria-table.typ": criteria-table
  criteria-table(
    columns: (auto, 1fr, 1fr, 1fr),
    headers: (
      [
        #set text(fill: catppuccin-accents.red)
        20
      ],
      [
        #set text(fill: catppuccin-accents.red)
        95
      ],
    ),
  )
}

Let's take a look at the utterance "_Turn up the brightness by #text(
  catppuccin-accents.red,
)[twenty] percent and set the table tilt to #text(catppuccin-accents.red)[ninety
  five] degrees._"
.
Here the highlighted numbers are added as candidates to the criteria table for
every actionable field, as shown in @tbl:criteria-table.
By isolating the numeric values, we delegate the task of associating concrete
values to actionable deltas to the model.
This is the heavy lifting part of the task.


// TODO: Document exactly how numeric phrases map to candidate targets, including current-state handling and bounds.

== Running locally

// TODO: mention why this is important for hospitals

As mentioned in @chp:local-open-weight-alternatives, running the model locally
is important for GDPR compliance.
The less hardware is required, the easier it is to set up for institutions,
especially hospitals.
So naturally I wanted to try out how far we can get with one.

JevK5 has a model version with 2B parameters that can somehow run on my
RTX 2080.
The server exposes a System-One-compatible API, so the surrounding request
format stays close to the hosted Jev example.
I use the model and package revision shown in @fig:pyproject_jevk5, which is
enough to reproduce the environment setup with #link(
  "https://docs.astral.sh/uv/",
)[uv].

#{
  show: it => [#it <fig:pyproject_jevk5>]
  show: figure.with(
    caption: [The pyproject.toml file for the JevK5-2B model used.],
    kind: raw,
    placement: none,
  )
  show: block.with(breakable: false)
  show: zebraw.with(header: [pyproject.toml])
  raw(read("assets/pyproject_jevk5.toml").trim(), block: true, lang: "toml")
}

I start the server with `uv run jevk5-serve --model alibiserikbay/JevK5-2B`.

= Evaluation

== Dataset and procedure

I use five virtual surgery scenarios:
- appendectomy,
- hernia repair,
- fundoplication,
- cholecystectomy, and
- sleeve gastrectomy.

The benchmark setup uses 1,000 generated cases with 12 utterances each,
including small talk that should not change room state.
The benchmark uses `inclusionai/ling-3.0-flash-vl` as the generator for cases
and expected output states.
That makes a large test set quickly, but generated labels are not
expert-reviewed ground truth.
You can find the benchmark in the #link(
  "https://github.com/TimerErTim/stop",
)[TimerErTim/stop] repository.

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
  show: it => [#it <tbl:overview-results-table>]
  show: figure.with(
    caption: [Overall metrics for Jev and JevK5-2B benchmark results.],
    placement: none,
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
The paired comparison in @tbl:overview-results-table uses the same cases for
both models and points in the same direction.

For the full comparison, the field accuracy is #format-percent(
  jev-data.accuracy_fresh,
) for Jev and #format-percent(jevk5-data.accuracy_fresh) for JevK5-2B.
In rolling mode, it is #format-percent(
  jev-data.accuracy_rolling,
) and #format-percent(jevk5-data.accuracy_rolling), respectively.

The table's field macro-F1 averages per-field F1 scores, so a field with many
examples does not drown out one with poor performance.
The models do not have the same coverage in every sample set, so treat this as a
summary of the supplied measurements rather than a like-for-like benchmark.

== It depends on the field

#{
  show: it => [#it <fig:field-f1-chart>]
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

Analyzing @fig:field-f1-chart, Jev handles several fields well in this generated
set, but safety interlock activation is a glaring exception: its F1 is
#format-f1(
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
I discovered cases where an utterance like “tilt table by 5 degrees” has an
expected state of `table_tilt: -5`, which goes against my intuition and also
against Jev's as it seems.

// TODO: Audit generated table-tilt labels for direction and sign mismatches. Compare examples like “tilt table by 5 degrees” with their expected values.


== Fast enough, on which machine?

Jev's recorded p50/p95 latency is #format-latency("jev-latest") per utterance.
That is more than enough to count as real-time interaction.
The average human response time is around 200ms, which is excluding the time to
physically execute the command, so Jev does not lag behind.


#warning-callout(heading: [
  “It runs locally” and “it is useful locally” are two different pairs of shoes.
])[
  #show strong: math.bold
  JevK5-2B's latency is *#format-latency(
    "alibiserikbay/JevK5-2B",
  )*.
  So the local model ran on my RTX 2080, but this particular 2B configuration
  was not fast enough for the near-real-time interaction I had in mind.
]

// TODO: Add a latency figure with hardware details, warm-up policy, and whether timing includes network or API overhead.

= Conclusion

System-One's constrained outputs are an appealing interface for
equipment-control software.
The schema narrows what the model can return, and the API scores each field
directly.
That is a much better contract than parsing free-form text.

JevK5-2B did not turn out to be a practical local substitute for Jev in this
setup.
It was less accurate and much slower, and both models missed nearly every
positive safety-interlock case.
If privacy is the reason to run locally, it currently costs more accuracy and
latency than I would accept.

So no, local System-One control is not ready.
But the failure modes I saw could be explained by sub-optimal data and
instruction setup.
Next steps are to investigate whether better data and more guardrails can close
the gap without moving the safety boundary.

== Potential improvements

- *Better data, better training.*
  JevK5-2B runs the default checkpoint.
  I did not tune it, I just pointed the server at it.
  My bet is that fine-tuning on messier utterances, ambiguous phrasing, field
  boundary cases and background noise buys more than swapping architectures.
  That needs human-reviewed labels instead of the generated ones I used, which
  would also make the benchmark mean more than “it works on my generated test
  set”.
- *A faster box.*
  The RTX 2080 is what I had, not what I would buy for this.
  A newer card, or a smaller or quantized checkpoint, would probably bring
  latency into a comfortable range.
  Whether that gets below the \~200 ms human response time on hardware a
  hospital would actually buy, I have not tested.
- *Better guardrails and guidance.*
  Rule-based field validation and abstention on low confidence were cheap to
  add, and they catch the errors the schema lets through on its own.
  That being said, corrective measures could make a lot of sense in addition to
  those.



// TODO: Test calibrated confidence thresholds and abstention policies per field; measure the accuracy/coverage/silent-failure trade-off.
// TODO: Investigate why safety-interlock recall is so low.
// TODO: Embed the demo video where the web format allows it. Otherwise link to the YouTube recording and add links to the GitHub project and general reference materials.

