#import "../common/template.typ": blog-entry
#import "../common/theming.typ": catppuccin-accents, color-cycle, theme, themes
#import "../common/variants.typ": broader-than, hide-in-preview, in-preview-or, web-only, web-or, web-page-width
#import "../common/deps.typ": codly, codly-local, lq, no-codly, strfmt
#import "../common/components/depth.typ": depth-shadow-block


#set text(lang: "en")
#set document(
  title: "Using Graph Neural Networks for coding assignment plagiarism detection based on source",
  description: "Neural networks seem like a perfect fit for detecting plagiarism attempts in coding exercises. In the Rust deep learning framework burn-rs, I built a graph convolution network with subpar accuracy, After a quick recap about that, we will explore how graph isomorphism networks and different similarity metrics can be used to improve the accuracy of the model.",
  author: "Tim Peko (TimerErTim)",
  keywords: (
    "Rust",
    "burn-rs",
    "GNN",
    "GCN",
    "GIN",
    "Plagiarism",
    "Similarity",
  ),
)
#show: blog-entry.with(
  target: auto,
  created-at: datetime(year: 2026, month: 7, day: 28),
  updated-at: datetime(year: 2026, month: 7, day: 29),
)

// Setup document content dependencies
#import "deps.typ": *
#import pinit: *
#import "../common/components/callouts.typ": (
  accent-callout, callout, danger-callout, info-callout, success-callout, warning-callout,
)
#import "../common/calc/auc.typ": auc
#import "../common/calc/analysis.typ": smooth_series
#import "../common/lib/fmt.typ": num_metric_suffix
#import "../common/components/xhtml.typ": xhtml

// Document specific styles
#show raw.where(lang: "show-tree-graph"): hg.enable-graph-in-raw(hg.tree-render)
#show raw.where(lang: "show-polar-graph"): hg.enable-graph-in-raw(
  hg.polar-render,
)
#show raw.where(lang: "show-md", block: true): it => cmarker.render(it.text)


The finished project is available under #web-or[
  @try-it-out-yourself
][
  // TODO: insert hosted link
]

= What has already happened? <chapter-recap>

The project was started by the simple idea of "How much can I overengineer plagiarism detection?", an open ended task given to my class by the professor of the Python scripting course. The solution can be as simple as comparing different tree similarity metrics, finding optimal metric weights for best accuracy, and submitting that as results.

Or we apply a more complex machine learning approach, using a graph convolution network to learn the similarity of the source code's abstract syntax trees.

== Basic conditions <preconditions>

*Given*:
- Supported language: Either Python or #pin(1)*C++*#pin(2) #context pinit-point-from((2,), offset-dx: -20pt, offset-dy: -28pt, body-dx: -24pt, body-dy: -10pt, pin-dy: -text.size, pin-dx: -8pt, fill: theme.colors.info)[chosen language]
- GUI of some form
- Comparing two files #sym.arrow Plagiarism chance percentage ($p in [0, 1]$).

*Assumptions*:
- The programming language can reliably be inferred from the file extension
- Every assignment submission is a single file #sym.arrow multiple files per comparison side is not supported

== Used dataset <dataset-recap>

We require some ground truth for training, and turns out high quality coding assignment plagiarism datasets are a surprisingly rare occurrence in the wild. I settled on the #link("https://ieee-dataport.org/open-access/programming-homework-dataset-plagiarism-detection")[Programming Homework Dataset for Plagiarism Detection | IEEE DataPort], which is a C and C++ dataset with 328 authentic and 120 plagiarized assignment submission pairs.

== High-level approach <high-level-approach-recap>

@fig-high-level-approach shows the general idea behind comparing the different files. We employ a graph compression step, @fig-compress-graph, to extract most relevant features from the ASTs and then compare these feature maps with a distance gated exponential similarity output layer. As the graph is further compressed, nodes features are narrowed but deepened, until only a few or a single node with many aggregated features remains (similar to visual CNNs).

For simplicity, layer normalization and dropout are not shown in the figure.

#{
  show: figure.with(
    caption: [Initial high-level processing pipeline],
    kind: image,
  )
  show: depth-shadow-block.with(inner-border: theme.layout.borderWidth.small)
  show: pad.with(1em)

  import fl: *

  let border-node(
    ..args,
    tint: theme.colors.overlay,
  ) = {
    node(
      ..args,
      fill: tint.mix((theme.colors.base, 200%)),
      stroke: theme.layout.borderWidth.small + tint,
      corner-radius: theme.layout.radius.small,
    )
  }

  let blob = border-node

  fl.diagram(
    debug: in-preview-or(3, false),
    node-fill: theme.colors.base,
    node-stroke: theme.colors.border + theme.layout.borderWidth.small,
    edge-stroke: theme.colors.foreground + theme.layout.borderWidth.small,
    crossing-fill: theme.colors.base,
    crossing-thickness: 4,
    blob(
      (0, 0),
      shape: shapes.house.with(dir: bottom),
      tint: catppuccin-accents.teal,
    )[C++ File 1],
    edge("->"),
    blob(
      (0, 1),
      shape: shapes.parallelogram.with(),
      tint: catppuccin-accents.green,
    )[AST parsing],
    edge("->"),
    blob(
      (0, 2),
      shape: shapes.parallelogram.with(),
      tint: catppuccin-accents.rosewater,
      name: <lgr>,
    )[Graph\ Representation],
    edge("->", label-side: right)[nodes],
    edge(
      (),
      (0, 2.5),
      (0.45, 2.5),
      "d",
      (0, 3.5),
      <lgc>,
      "-->",
      label-side: right,
      label-pos: 65%,
    )[edges],
    blob(
      (0, 3),
      shape: shapes.trapezium.with(dir: top),
      tint: catppuccin-accents.pink,
      name: <lemb>,
      snap: 4,
    )[Embedding],
    edge("->"),
    blob(
      (0, 4),
      shape: shapes.trapezium.with(dir: bottom),
      tint: catppuccin-accents.sapphire,
      name: <lgc>,
    )[Graph\ Compression],
    edge("dd", "->"),
    edge((), (0, 4.75), (0.55, 4.75), (0.55, 6), (1, 6), "->"),

    blob(
      (1, 0),
      shape: shapes.house.with(dir: bottom),
      tint: catppuccin-accents.teal,
    )[C++ File 2],
    edge("->"),
    blob(
      (1, 1),
      shape: shapes.parallelogram.with(),
      tint: catppuccin-accents.green,
    )[AST parsing],
    edge("->"),
    blob(
      (1, 2),
      shape: shapes.parallelogram.with(),
      tint: catppuccin-accents.rosewater,
      name: <rgr>,
    )[Graph\ Representation],
    edge("->"),
    edge((), (1, 2.5), (0.55, 2.5), "d", (1, 3.5), <rgc>, "-->"),
    blob(
      (1, 3),
      shape: shapes.trapezium.with(dir: top),
      tint: catppuccin-accents.pink,
      snap: 4,
    )[Embedding],
    edge("->"),
    blob(
      (1, 4),
      shape: shapes.trapezium.with(dir: bottom),
      tint: catppuccin-accents.sapphire,
      name: <rgc>,
    )[Graph\ Compression],
    edge("dd", "->")[
      #set text(fill: theme.colors.muted)
      $RR^(1 times n)$
    ],
    edge(
      (),
      (1, 4.5),
      (0.45, 4.5),
      (0.45, 6),
      (0, 6),
      "->",
      crossing: true,
      crossing-fill: theme.colors.overlay,
    ),

    border-node((1, 6), inset: 2pt, tint: catppuccin-accents.mauve)[
      #set text(size: 1.5em)
      #sym.dot.o
    ],
    edge("->"),
    border-node((1, 7), tint: catppuccin-accents.peach)[
      Linear
    ],
    edge("->"),
    border-node(
      (1, 8),
      tint: catppuccin-accents.yellow,
      shape: shapes.hexagon,
    )[$sigma$],
    edge((), <gated-similarity>, "->"),

    border-node((0, 6), inset: 2pt, tint: catppuccin-accents.mauve)[
      #set text(size: 1.5em)
      #sym.minus
    ],
    edge("->"),
    border-node((0, 7), tint: catppuccin-accents.yellow, shape: shapes.hexagon)[
      abs
    ],
    edge("->"),
    border-node((0, 8), tint: catppuccin-accents.peach)[
      Linear
    ],
    edge("->"),

    border-node(
      (0.5, 8),
      inset: 2pt,
      tint: catppuccin-accents.mauve,
      name: <gated-similarity>,
    )[
      #set text(size: 1.5em)
      #sym.dot.o
    ],
    edge("->"),
    border-node(
      (0.5, 9),
      tint: catppuccin-accents.peach,
      name: <decider-linear>,
    )[
      Linear
    ],
    edge("->")[
      #set text(fill: theme.colors.muted)
      $RR^(1)$
    ],
    border-node(
      (0.5, 10),
      tint: catppuccin-accents.yellow,
      shape: shapes.hexagon,
    )[
      $bold(-)"ReLU"$
    ],
    edge("->"),
    border-node(
      (0.5, 11),
      tint: catppuccin-accents.yellow,
      shape: shapes.hexagon,
    )[
      $exp$
    ],
    edge("->"),
    border-node(
      (0.5, 12),
      tint: catppuccin-accents.blue,
      shape: shapes.house.with(dir: top),
      name: <similarity-score>,
    )[
      Similarity\ Score
    ],

    node(
      enclose: (<lemb>, <lgc>, <rgc>, <similarity-score>),
      shape: shapes.rect,
      inset: 10pt,
      corner-radius: theme.layout.radius.medium,
      fill: theme.colors.overlay,
      stroke: none,
    )[
      #show: align.with(top + right)
      #set text(fill: theme.colors.muted)
      #show: pad.with(right: -10pt - 0.5em, top: -10pt - 1em)
      AI Model
    ],
  )
} <fig-high-level-approach>

#{
  show: figure.with(caption: [Graph compression process], kind: image)
  show: depth-shadow-block.with(inner-border: theme.layout.borderWidth.small)
  show: pad.with(1em)

  import fl: *

  let blob(pos, label, tint: white, ..args) = node(
    pos,
    align(center, label),
    width: 28mm,
    fill: tint.mix((theme.colors.base, 200%)),
    stroke: theme.layout.borderWidth.small + tint,
    corner-radius: theme.layout.radius.small,
    ..args,
  )

  fl.diagram(
    debug: in-preview-or(3, false),
    node-fill: theme.colors.base,
    node-stroke: theme.colors.border + theme.layout.borderWidth.small,
    edge-stroke: theme.colors.foreground + theme.layout.borderWidth.small,
    blob(
      (0, 0),
      shape: shapes.house.with(dir: bottom),
      tint: catppuccin-accents.red,
    )[Input\ Graph],
    edge("->"),
    blob((0, 1), tint: catppuccin-accents.peach)[Convolution],
    edge("->"),
    blob((0, 2), tint: catppuccin-accents.peach)[Convolution],
    edge("->"),
    blob(
      (0, 3),
      tint: catppuccin-accents.lavender,
      shape: shapes.trapezium.with(dir: bottom),
    )[Diff Pooling],
    edge("d,r,uuuu,r,d", "-->"),
    node((1, 2), shape: shapes.rect)[...],
    blob((2, 1), tint: catppuccin-accents.peach)[Convolution],
    edge("->"),
    blob(
      (2, 2),
      tint: catppuccin-accents.lavender,
      shape: shapes.trapezium.with(dir: bottom),
    )[Diff Pooling],
    edge("->")[nodes],
    blob((2, 3), tint: catppuccin-accents.yellow, shape: shapes.hexagon)[Max],
  )
} <fig-compress-graph>

== Applied concepts

You can skip this chapter if you are not interested in the detailed workings of @high-level-approach-recap.

=== Abstract Syntax Trees <abstract-syntax-trees-recap>

With #link("https://github.com/tree-sitter/tree-sitter")[Tree-sitter] we can parse the source code into an abstract syntax tree (AST). Because it supports many different languages, we can easily extend the same approach to a suitable Python dataset#footnote[If found in the future].


#let sample-cpp = ```cpp
int main() {
  int a = 2;
  int b = a * 4;
  return b;
}
```

#let ast-labels = (
  "FDf": "FunctionDefinition",
  "T": "Type",
  "FDc": "FunctionDeclarator",
  "CSt": "CompoundStatement",
  "D": "Declaration",
  "InitD": "InitDeclarator",
  "Init": "Initialiser",
  "BE": "BinaryExpression",
  "N": "Number",
  "RSt": "ReturnStatement",
  "Id": "Identifier",
  "PL": "ParameterList",
)

#let sample-cpp-ast-brackets = ```
[FDf
  [T int]
  [FDc [Id main] [PL]]
  [CSt
    [D [T int] [InitD [Id a] [Init 2]]]
    [D [T int] [InitD [Id b] [Init [BE [Id a] [N 4]]]]]
    [RSt [Id b]]
  ]
]```.text


#let sample-cpp-ast(..args) = {
  show: no-codly
  synkit.tree(
    sample-cpp-ast-brackets,
    annotation: (
      (
        "FDf1",
        ```cpp
        int main() { ... }
        ```,
      ),
      (
        "FDc1",
        ```cpp
        main()
        ```,
      ),
      (
        "CSt1",
        ```cpp
        { ... }
        ```,
      ),
      (
        "D1",
        ```cpp
        int a = 2;
        ```,
      ),
      (
        "InitD1",
        ```cpp
        a = 2;
        ```,
      ),
      (
        "D2",
        ```cpp
        int b = a * 4;
        ```,
      ),
      (
        "InitD2",
        ```cpp
        b = a * 4;
        ```,
      ),
      (
        "BE1",
        ```cpp
        a * 4
        ```,
      ),
      (
        "RSt1",
        ```cpp
        return b;
        ```,
      ),
    ),
    ..args,
  )
}

#let sample-cpp-alternative = ```cpp
int main() {
  int c = 2;
  int d = 4 * c;
  return d;
}
```

#let sample-cpp-alternative-ast-brackets = ```
[FDf
  [T int]
  [FDc [Id main] [PL]]
  [CSt
    [D [T int] [InitD [Id c] [Init 2]]]
    [D [T int] [InitD [Id d] [Init [BE [N 4] [Id c]]]]]
    [RSt [Id d]]
  ]
]```.text

#let sample-cpp-alternative-ast(..args) = {
  show: no-codly
  synkit.tree(
    sample-cpp-alternative-ast-brackets,
    annotation: (
      (
        "FDf1",
        ```cpp
        int main() { ... }
        ```,
      ),
      (
        "FDc1",
        ```cpp
        main()
        ```,
      ),
      (
        "CSt1",
        ```cpp
        { ... }
        ```,
      ),
      (
        "D1",
        ```cpp
        int c = 2;
        ```,
      ),
      (
        "InitD1",
        ```cpp
        c = 2;
        ```,
      ),
      (
        "D2",
        ```cpp
        int d = 4 * c;
        ```,
      ),
      (
        "InitD2",
        ```cpp
        d = 4 * c;
        ```,
      ),
      (
        "BE1",
        ```cpp
        4 * c
        ```,
      ),
      (
        "RSt1",
        ```cpp
        return d;
        ```,
      ),
    ),
    ..args,
  )
}

By having a tree representation of the source code, we have a starting point for extracting features from the semantic relationships between the nodes. See the example in @fig-ast-example, with the corresponding node labels in @table-ast-labels.

#{
  show: figure.with(
    caption: [AST representation of a simple C++ program],
    kind: image,
  )
  show: depth-shadow-block.with(inner-border: theme.layout.borderWidth.small)
  show: pad.with(1em)
  grid(
    columns: broader-than(560pt, (1fr, auto, auto), 1),
    gutter: 1em,
    align: center + horizon,
    {
      sample-cpp
    },
    grid.cell(align: center + horizon, {
      set text(size: 2em)
      broader-than(560pt, sym.arrow, sym.arrow.b)
    }),
    sample-cpp-ast(scale: 0.7),
  )
} <fig-ast-example>

#{
  show: figure.with(caption: [abbreviated AST node labels], kind: table)
  table(
    columns: 2,
    table.header[*Abbreviation*][*Full*],
    ..for (key, value) in ast-labels.pairs() {
      (key, value)
    },
  )
} <table-ast-labels>

#context {
  show: block.with(breakable: false)
  info-callout(heading: [
    AST Advantages 🫦
  ])[
    AST representation is agnostic of symbolic names, it only cares about the structure of the code, which is harder to cover up when plagiarizing.

    #let right-content = synkit.garden(
      (
        input: sample-cpp-alternative-ast-brackets,
        bottom: false,
      ),
      (
        input: sample-cpp-ast-brackets,
        bottom: false,
        direction: "up",
      ),
      equivalence: (
        ("T1-1", "T1-2"),
        ("Id1-1", "Id1-2"),
        ("T2-1", "T2-2"),
        ("Id2-1", "Id2-2"),
        ("Init1-1", "Init1-2"),
        ("T3-1", "T3-2"),
        ("InitD3-1", "InitD3-2"),
        ("Id3-1", "Id3-2"),
        ("Id4-1", "Id4-2"),
        ("N1-1", "N1-2"),
        ("Id5-1", "Id5-2"),
      ),
      gap: 2.5,
      scale: broader-than(480pt, 0.8, 0.5),
    )

    #let (width: r-width, height: r-height) = measure(right-content)

    #{
      grid(
        columns: broader-than(560pt, (1fr, auto, auto), 2),
        rows: broader-than(560pt, (r-height * 0.5, r-height * 0.5), 3),
        gutter: 1em,
        align: center + horizon,
        sample-cpp,
        grid.cell(..broader-than(560pt, (:), (x: 0, y: 1)), {
          set text(size: 2em)
          broader-than(560pt, sym.arrow, sym.arrow.b)
        }),
        grid.cell(
          ..broader-than(560pt, (rowspan: 2), (colspan: 2, x: 0, y: 2)),
          {
            show: broader-than(
              560pt,
              it => it,
              it => {
                show: rotate.with(90deg, reflow: true)
                //show text: rect.with(inset: 0.5em, stroke: theme.colors.border + 1pt, fill: theme.colors.base)
                show text: box.with(
                  clip: true,
                  fill: theme.colors.base,
                  inset: 0.2em,
                )
                show text: rotate.with(-90deg, reflow: true)
                it
              },
            )
            right-content
          },
        ),
        sample-cpp-alternative,
        {
          set text(size: 2em)
          broader-than(560pt, sym.arrow, sym.arrow.b)
        },
      )
    }

    The above code samples lead to structurally equivalent ASTs, as indicated by the correspondents of the dashed lines.
  ]
}

=== Node embeddings <node-embeddings-recap>

Raw node labels and ids in the range of 0-65535 are barely useful as input features for the neural network. An embedding layer is used to transform the ids into 16-dimensional vectors.

#codly(
  highlights: (
    (
      line: 3,
      start: 48,
      end: 63,
      fill: theme.colors.overlay,
      tag: [
        #set text(fill: theme.colors.muted)
        \= 65536
      ],
    ),
    (
      line: 3,
      start: 66,
      end: 84,
      fill: theme.colors.overlay,
      tag: [
        #set text(fill: theme.colors.muted)
        \= 16
      ],
    ),
    (
      line: 2,
      start: 30,
      end: 52,
      fill: theme.colors.overlay,
      tag: {
        set text(fill: theme.colors.muted)
        "[n, 1]"
      },
    ),
    (
      line: 5,
      start: 22,
      end: 50,
      fill: theme.colors.overlay,
      tag: {
        set text(fill: theme.colors.muted)
        "[1, n]"
      },
    ),
    (
      line: 6,
      start: 15,
      end: 27,
      fill: theme.colors.base,
      tag: {
        set text(fill: theme.colors.muted)
        [\[#math.cancel[1,] n, 16\]]
      },
    ),
  ),
  header: [burn-rs node embedding implementation],
)
```rust
impl<B: Backend> PlagiarismDecider<B> {
  pub fn embed_nodes(&self, nodes: Tensor<B, 2, Int>) -> Tensor<B, 2> {
    let embedding_layer = EmbeddingConfig::new(self.num_classes, self.embedding_size).init(&self.device);
    embedding_layer
            .forward(nodes.clone().swap_dims(0, 1))
            .squeeze_dim(0)
  }
}
```

#success-callout(heading: [Stable Node IDs])[
  This only works because node types have stable associated ids across the same Tree-sitter and language spec version. A `Type` node will always have the same id and thus embedding vector.
]

#{
  let points = sj.haltonset-f(16, skip: 42, size: ast-labels.len()).map(it => it.map(x => x * 2 - 1))
  let abbrev-vec-map = array
    .zip(ast-labels.keys(), points.map(((x0, .., xlast)) => strfmt(
      ```typc
      math.vec([#calc.round({x0}, digits: 2)], sym.dots.v, [#calc.round({xlast}, digits: 2)], delim: none)
      ```.text,
      x0: x0,
      xlast: xlast,
    )))
    .to-dict()

  grid(
    columns: broader-than(560pt, (auto, 1fr, auto), 1),
    gutter: 1em,
    align: center + horizon,
    {
      sample-cpp-ast(scale: 0.6)
    },
    grid.cell(align: center + horizon, {
      set text(size: 2em)
      broader-than(560pt, sym.arrow, sym.arrow.b)
    }),
    {
      raw(
        lang: "show-tree-graph",
        block: true,
        strfmt(
          ```
          #min-space: 3cm;
          #ed-bd: 30deg;
          #scl: 0.55;
          Fdf1: {FDf};
          T1: {T};
          FDc1: {FDc};
          CSt1: {CSt};

          Id1: {Id};
          PL1: {PL};
          D1: {D};
          D2: {D};
          RSt1: {RSt};

          T2: {T};
          InitD1: {InitD};
          T3: {T};
          InitD2: {InitD};
          Id2: {Id};

          Id3: {Id};
          Init1: {Init};
          Id4: {Id};
          Init2: {Init};

          BE1: {BE};
          Id5: {Id};
          N1: {N};

          Fdf1 < T1;
          Fdf1 < FDc1;
          Fdf1 < CSt1;

          FDc1 < Id1;
          FDc1 < PL1;

          CSt1 < D1;
          CSt1 < D2;
          CSt1 < RSt1;

          D1 < T2;
          D1 < InitD1;

          InitD1 < Id3;
          InitD1 < Init1;

          D2 < T3;
          D2 < InitD2;

          InitD2 < Id4;
          InitD2 < Init2;

          Init2 < BE1;

          BE1 < Id5;
          BE1 < N1;

          RSt1 < Id2;
          ```.text,
          ..abbrev-vec-map,
        ),
      )
    }
  )
}

=== Graph Convolution Networks <gcn-recap>

Graphs are represented as a simple struct containg node features of size $n times d$ and adjacency matrix of size $n times n$ where $n$ is the number of nodes and $d$ is the number of features per node.

```rust
#[derive(Debug, Clone)]
pub struct Graph<B: Backend, D: TensorKind<B> = Float> {
    /// Shape: [num_nodes, num_features]
    pub nodes: Tensor<B, 2, D>,
    /// Shape: [num_nodes, num_nodes]
    /// Adjacency matrix, [target, src]
    pub edges: Tensor<B, 2, Float>,
}
```

A graph convolution layer basically performs a feedforward step for each node's neighbors and averages the result into said node.
#{
  show: figure.with(
    caption: [Principle of the graph convolution layer],
    kind: image,
  )
  show: depth-shadow-block.with(
    fill: themes.light.base,
    inner-border: theme.layout.borderWidth.medium,
    color: if theme.colors.neutral == themes.dark.neutral {
      theme.colors.neutral
    } else { theme.colors.shadow },
  )
  place(right + bottom, dx: -1em, dy: -1em)[
    #set text(fill: themes.light.foreground, size: theme.layout.fontSize.tiny)
    https://mbernste.github.io/posts/gcn/ \
    (MIT License) Copyright (c) Matthew N. Bernstein
  ]
  show: pad.with(bottom: 2em)
  layout(((width, height)) => {
    image("assets/gcn_principle.png", width: calc.max(
      width / 1.25,
      10cm,
    ))
  })
}
Mathematically, this is represented in @eq-gcn:
$
  N in R^(n times d) and A in R^(n times n) and D_i = 1 + sum_(j=1)^(n) A_(i j) =>\
  "GCN"(N, A) = "SwiGLU"(A dot.o 1/sqrt(D) dot.o (1/sqrt(D))^upright(T) dot N)
$ <eq-gcn>

We use the SwiGLU activation function due to its ability for faster convergence. $"GCN"$ are the new node features for the graph, with the feature size being dependant on SwiGLU's output size. The above equation closely mirrors the implementation in burn-rs.

#codly(
  highlights: (
    (
      line: 3,
      start: 25,
      end: 57,
      fill: theme.colors.overlay,
      tag: {
        set text(fill: theme.colors.muted)
        $1 + sum_(j=1)^(n) A_(i j) ->$
        "[n, 1]"
      },
    ),
    (
      line: 21,
      start: 17,
      end: 27,
      fill: theme.colors.overlay,
      tag: {
        set text(fill: theme.colors.muted)
        "[n, d]"
      },
    ),
    (
      line: 22,
      start: 29,
      end: 61,
      fill: theme.colors.overlay,
      tag: {
        set text(fill: theme.colors.muted)
        "[n, d']"
      },
    ),
  ),
  header: [burn-rs graph convolution layer implementation],
)
```rust
impl Graph {
  pub fn normalized_adjacency_matrix(&self) -> Tensor<B, 2, Float> {
    let degree_matrix = self.edges.clone().sum_dim(1) + 1;
    // Inverse square root of the degree matrix
    let degree_matrix_inv_sqrt = degree_matrix.powf_scalar(-0.5);

    self.edges.clone()
      // Normalize by deg(i) of the target node
      .mul(degree_matrix_inv_sqrt.clone())
      // Normalize by deg(j) of all the source nodes j in N_i
      .mul(degree_matrix_inv_sqrt.transpose())
  }
}

pub fn graph_convolution<B: Backend>(
    graph: Graph<B, Float>,
    swiglu: SwiGlu<B>,
) -> Graph<B> {
    let normalized_adjacency_matrix = graph.normalized_adjacency_matrix();
    let neighbor_features = normalized_adjacency_matrix
        .matmul(graph.nodes);
    let neighbor_features = swiglu.forward(neighbor_features);
    Graph {
        nodes: neighbor_features,
        edges: graph.edges,
    }
}
```

#warning-callout(heading: [Only one neighbor deep!], [
  If you are exceptionally meticulous (or have preknowledge) you notice that per convolution layer we can only aggregate features from the direct neighbors. We can aggregate features from more distant neighbors by stacking multiple convolution layers. That's why in @fig-compress-graph we require multiple convolutions before pooling in order to consider meaningful AST macro structures.
])

=== Graph Diff Pooling

Graph DiffPool is a technique to reduce the number of nodes in a graph by calculating an assignment matrix $S in R^(n times n')$ where $n$ is the number of nodes in the original graph and $m$ is the number of supernodes in the pooled graph. $N in R^(n times d)$ is the node features of the original graph and $F in R^(n times d')$ is the embeded node features of the graph. Then $N' in R^(n' times d')$ is the node features of the pooled graph. Formally expressed in @eq-diff-pool:

$
   S & = "softmax"("GNN"_"Assigment" (N)) \
   F & = "GNN"_"Embed" (N) \
  N' & = S^upright(T) dot F \
  A' & = S^upright(T) dot A dot S
$ <eq-diff-pool>

#{
  show: figure.with(caption: [Principle of the graph diff pooling], kind: image)
  show: depth-shadow-block.with(
    fill: themes.light.base,
    inner-border: theme.layout.borderWidth.medium,
    color: if theme.colors.neutral == themes.dark.neutral {
      theme.colors.neutral
    } else { theme.colors.shadow },
  )
  image("assets/graph-diff-principle.png")
  place(right + top, dx: -0.5em, dy: 0.5em)[
    #set text(fill: themes.light.foreground, size: theme.layout.fontSize.tiny)
    https://arxiv.org/pdf/1901.00596
  ]
}

In code, that is easy to implement with the GCN:

#codly(
  highlights: (
    (
      line: 3,
      start: 13,
      end: 28,
      fill: theme.colors.overlay,
      tag: {
        set text(fill: theme.colors.muted)
        "[n, n']"
      },
    ),
    (
      line: 7,
      start: 13,
      end: 27,
      fill: theme.colors.overlay,
      tag: {
        set text(fill: theme.colors.muted)
        "[n, d']"
      },
    ),
    (
      line: 8,
      start: 17,
      end: 27,
      fill: theme.colors.overlay,
      tag: {
        set text(fill: theme.colors.muted)
        "[n', d']"
      },
    ),
    (
      line: 9,
      start: 13,
      end: 23,
      fill: theme.colors.overlay,
      tag: {
        set text(fill: theme.colors.muted)
        "[n', n']"
      },
    ),
  ),
)
```rust
impl<B: Backend> GraphDiffPool<B> {
    pub fn forward(&self, input: Graph<B>) -> Graph<B> {
        let soft_assignments = softmax(
          self.assignments_layer.forward(input.clone()).nodes,
          0
        );
        let node_embeddings = self.embed_layer.forward(input.clone()).nodes;
        let mut super_nodes = soft_assignments.clone().transpose().matmul(node_embeddings);
        let super_edges = soft_assignments
            .clone()
            .transpose()
            .matmul(input.edges)
            .matmul(soft_assignments);
        Graph::new(super_nodes, super_edges)
    }
}
```
#danger-callout(heading: [Missing loss function 😭], [
  The technique is designed to
  - favor neighboring nodes to be assigned to the same supernode
  - and maximize heterogeneity of the assignment matrix.

  The loss functions for this were never implemented. I did not find out about them until researching for this blog post. Since I am transitioning away from GCN approach, there is no appeal in implementing them right now.
])

Now all the building blocks for the @fig-compress-graph are available. With that, the architecture is similar to @fig-stepwise-graph-feature-condensation.

#{
  show: figure.with(
    caption: [Stepwise graph feature condensation used for inspiration],
    kind: image,
  )
  show: depth-shadow-block.with(
    fill: themes.light.base,
    inner-border: theme.layout.borderWidth.medium,
    color: if theme.colors.neutral == themes.dark.neutral {
      theme.colors.neutral
    } else { theme.colors.shadow },
  )
  place(right + bottom, dx: -0.5em, dy: -0.5em)[
    #set text(fill: themes.light.foreground, size: theme.layout.fontSize.tiny)
    https://towardsdatascience.com/graph-convolutional-networks-deep-99d7fee5706f/\
    Francesco Casalegno
  ]
  show: pad.with(bottom: 4em, rest: 1em)
  image("assets/compression-ref.png")
} <fig-stepwise-graph-feature-condensation>

== Evaluation of GCN approach <evaluation-gcn-approach>

#pdf.attach(
  "assets/gcn_validation.json",
  mime-type: "application/json",
  relationship: "data",
  description: "Unprocessed validation data for the GCN approach",
)
#let gcn-validation-data = json("assets/gcn_validation.json")
#let gcn-roc-data = (
  (
    gcn-validation-data
      .classification_statistics
      .map(stat => (
        stat.false_positive / (stat.false_positive + stat.true_negative),
        stat.true_positive / (stat.true_positive + stat.false_negative),
      ))
      .sorted(key: it => (it.at(0), it.at(1)))
  )
    .rev()
    .dedup(key: it => it.at(0))
    .rev()
)
#let gcn-roc-auc = auc(gcn-roc-data.map(it => it.at(0)), gcn-roc-data.map(
  it => it.at(1),
))
#let gcn-pr-data = (
  (
    (
      ..gcn-validation-data.classification_statistics,
      (recall: 0.0, precision: 1.0),
    )
      .map(stat => (stat.recall, stat.precision))
      .sorted(key: it => (it.at(0), it.at(1)))
  )
    .rev()
    .dedup(key: it => it.at(0))
    .rev()
)
#let gcn-pr-auc = auc(gcn-pr-data.map(it => it.at(0)), gcn-pr-data.map(
  it => it.at(1),
))

@fig-roc-auc-gcn shows an AUC score of *#calc.round(digits: 2, gcn-roc-auc)*, which indicates very good classification performance of the GCN approach. @fig-pr-auc-gcn shows an AUC *#calc.round(digits: 2, gcn-pr-auc)*, which is not bad but nothing extraordinary.

#let gcn-roc-figure = {
  show: it => [#it <fig-roc-auc-gcn>]
  show: figure.with(caption: [ROC curve for the GCN approach], kind: image)
  show: depth-shadow-block.with(
    inner-border: theme.layout.borderWidth.small,
  )
  show: pad.with(1em)
  show: lq.set-tick(
    inset: 0pt,
    outset: 0pt,
  )

  lq.diagram(
    width: 6cm,
    height: 6cm,
    xlim: (0, 1),
    ylim: (0, 1),
    title: [*ROC curve*],
    xlabel: "False Positive Rate",
    ylabel: "True Positive Rate",
    grid: none,
    xaxis: (
      tick-args: (
        density: 50%,
      ),
    ),
    yaxis: (
      tick-args: (
        density: 25%,
      ),
    ),
    legend: (
      position: bottom + right,
    ),
    lq.fill-between(
      gcn-roc-data.map(it => it.at(0)),
      gcn-roc-data.map(it => it.at(1)),
      stroke: auto,
      fill: color-cycle.at(0).transparentize(95%),
      label: "GCN Approach",
    ),
    lq.plot(
      (0, 1),
      (0, 1),
      stroke: (paint: theme.colors.muted, dash: "dashed"),
      mark: none,
      label: "Baseline",
    ),
    lq.place(0.65, 0.3)[
      #set text(size: 5mm)
      AUC = #calc.round(digits: 2, gcn-roc-auc)
    ],
  )
}

#let gcn-pr-figure = {
  show: it => [#it <fig-pr-auc-gcn>]
  show: figure.with(
    caption: [Precision-Recall curve for the GCN approach],
    kind: image,
  )
  show: depth-shadow-block.with(
    inner-border: theme.layout.borderWidth.small,
  )
  show: pad.with(1em)
  show: lq.set-tick(
    inset: 0pt,
    outset: 0pt,
  )
  lq.diagram(
    width: 6cm,
    height: 6cm,
    xlim: (0, 1),
    ylim: (0, 1),
    title: [*PR curve*],
    xlabel: "Recall",
    ylabel: "Precision",
    grid: none,
    xaxis: (
      tick-args: (
        density: 50%,
      ),
    ),
    yaxis: (
      tick-args: (
        density: 25%,
      ),
    ),
    legend: (
      position: bottom + right,
    ),
    lq.fill-between(
      gcn-pr-data.map(it => it.at(0)),
      gcn-pr-data.map(it => it.at(1)),
      stroke: auto,
      fill: color-cycle.at(0).transparentize(95%),
      label: "GCN Approach",
    ),
    lq.place(0.65, 0.25)[
      #set text(size: 5mm)
      AUC = #calc.round(digits: 2, gcn-pr-auc)
    ],
  )
}

#{
  show: web-or(it => it, place.with(auto, float: true))
  set figure(placement: none)
  grid(
    columns: broader-than(560pt, 2, 1),
    gutter: 1em,
    align: top,
    gcn-roc-figure,
    gcn-pr-figure,
  )
}

With an F1-Score of *#calc.round(digits: 2, gcn-validation-data.unbiased_classification_statistic.f1_score)* at a threshold of #calc.round(digits: 2, gcn-validation-data.unbiased_classification_statistic.threshold), the GCN approach is not the best performing model. However, it is still a good baseline for the project and the next steps will focus on improving the accuracy of the model.

= GIN and Cosine Similarity <gin-and-cosine-similarity>

== Expanding the Data Variety

One huge problem with the approach from the #link(<chapter-recap>)[recap] is the lackluster data variance in the used datasets. The amount of plagiarized assignments is significantly lower than expected.

#let custom-ds-tasks = 20
#let custom-ds-auth-per-task = 8
#let custom-ds-plag-per-auth = 4
So with Cursor Composer 2.5, we generated more data to train the model on:
- $#calc.round(digits: 2, custom-ds-tasks * custom-ds-auth-per-task * custom-ds-plag-per-auth) "Plagiarized pairs" = #custom-ds-tasks "Tasks" times #custom-ds-auth-per-task "Authentic solutions" times #custom-ds-plag-per-auth "Plagiarized solutions"$
- $#calc.round(digits: 2, custom-ds-tasks * custom-ds-auth-per-task * (custom-ds-auth-per-task - 1) / 2) "Non-plagiarized pairs" = #custom-ds-tasks "Tasks" times (#custom-ds-auth-per-task "Authentic solutions" times #(custom-ds-auth-per-task - 1) "Other authentics") / 2$

The model was instructed to
+ Generate 20 task descriptions for C++ assignments, solvable in a single source code file of around \~100-ish lines of code.
+ Generate 8 authentic solutions for each task, writing them independently and without any knowledge of the other solutions.
+ For each authentic solution, generate 4 plagiarized solutions with different degrees of blatancy, employing same techniques as humans would.

#{
  table(
    columns: 2,
    table.header[*Variant*][*Typical edits*],
    [plag1],
    [
      Include reorder, member renames (`data_` #sym.arrow `cells_`), `i++` vs `++i`, `'\n'` $arrow.l.r$ `std::endl`
    ],

    [plag2],
    [
      Extract helpers (e.g. `dotRow()`), Allman braces, swap input loop order (column-major), accumulate into local before assign
    ],

    [plag3],
    [
      Heavy renames, casual comment, decrement loops `for (k = n; k-- > 0;)`
    ],

    [plag4],
    [
      Lightest touch — still not copy-paste: a few renames + main variable renames],
  )
}

#callout[
  #set heading(numbering: none, outlined: false)
  #raw(
    block: true,
    lang: "show-md",
    read("assets/custom-ds-task2-readme.md").split("\n").slice(0, 12).join("\n"),
  )
]

#{
  show: depth-shadow-block.with(
    color: theme.colors.success,
    inner-border: theme.layout.borderWidth.small,
  )
  show: pad.with(-theme.layout.borderWidth.small / 2)
  codly(
    ranges: ((51, 63),),
    header: [Authentic solution 1 for task 2],
  )
  raw(block: true, lang: "cpp", read("assets/auth1.cpp"))
}

#{
  show: depth-shadow-block.with(
    color: theme.colors.danger,
    inner-border: theme.layout.borderWidth.small,
  )
  show: pad.with(-theme.layout.borderWidth.small / 2)
  codly(
    ranges: ((53, 65),),
    header: [Plagiarized solution 1 for task 2],
  )
  raw(block: true, lang: "cpp", read("assets/auth1_plag1.cpp"))
}

#{
  show: depth-shadow-block.with(
    color: theme.colors.success,
    inner-border: theme.layout.borderWidth.small,
  )
  show: pad.with(-theme.layout.borderWidth.small / 2)
  codly(
    ranges: ((58, 70),),
    header: [Authentic solution 2 for task 2],
  )
  raw(block: true, lang: "cpp", read("assets/auth2.cpp"))
}

This synthetic dataset is available under the projects repository in @references.

== Graph Isomorphism Networks <graph-isomorphism-networks-trials>

Graph Isomorphism Networks (GINs) can be thought of pretty similar to GCNs, introduced in @gcn-recap, where the main difference is the aggregation function being a sum of the node's neighbors' embeddings instead of a mean. The single GIN passes are repeated in order to extend the aggregation reach to multiple hops. For further processing, the residuals (the individual passes) are summed up along all nodes in the graph and concatenated to form a final graph embedding in the shape of $"number of passes" times "embedding size"$.

#info-callout(heading: [GINs are injective])[
  Assuming all hidden layers also use injective activation functions, the GIN as a whole is also injective. Put differently, every different input graph will have a different output embedding. This makes it great for classification tasks where we want to be able to distinguish between different graphs.
]

#{
  show: figure.with(
    caption: [Illustration of the GIN principle. Source: #link("https://towardsdatascience.com/how-to-design-the-most-powerful-graph-neural-network-3d18b07a6e66/")[Towards Data Science, Maxime Labonne]],
    kind: image,
  )
  show: depth-shadow-block.with(inner-border: theme.layout.borderWidth.small)
  image("assets/gin-illustr.png")
}

#codly(
  ranges: ((9, 26), (34, none)),
  header: [GIN implementation],
  highlights: (
    (
      line: 11,
      start: 13,
      end: 21,
      fill: theme.colors.overlay,
      tag: {
        set text(fill: theme.colors.muted)
        "[n, d]"
      },
    ),
    (
      line: 23,
      start: 13,
      end: 21,
      fill: theme.colors.overlay,
      tag: {
        set text(fill: theme.colors.muted)
        "[n, d]"
      },
    ),
    (
      line: 36,
      start: 13,
      end: 26,
      fill: theme.colors.overlay,
      tag: {
        set text(fill: theme.colors.muted)
        $[l, 1, d]$
      },
    ),
    (
      line: 39,
      start: 45,
      end: 60,
      fill: theme.colors.overlay,
      tag: {
        set text(fill: theme.colors.muted)
        "[n, d]"
      },
    ),
    (
      line: 39,
      start: 21,
      end: 41,
      fill: theme.colors.overlay,
      tag: {
        set text(fill: theme.colors.muted)
        "[1, d]"
      },
    ),
    (
      line: 44,
      start: 17,
      end: 37,
      fill: theme.colors.overlay,
      tag: {
        set text(fill: theme.colors.muted)
        "[l, d]"
      },
    ),
  ),
)
```rust
#[derive(Module, Debug)]
pub struct GINMLP<B: Backend> {
    pub hidden_layers: Vec<Linear<B>>,
    pub output_layer: Linear<B>,
    pub layer_norm: Option<LayerNorm<B>>,
    pub epsilon: f32,
}

impl<B: Backend> GINMLP<B> {
    pub fn forward(&self, graph: Graph<B>) -> Graph<B> {
        let mlp_input =
            (1.0 + self.epsilon) * graph.nodes.clone() + graph.edges.clone().matmul(graph.nodes);

        // Pass through MLP
        let output = self.hidden_layers.iter().fold(mlp_input, |mut x, layer| {
            x = layer.forward(x);
            x = relu(x);
            if let Some(layer_norm) = &self.layer_norm {
                x = layer_norm.forward(x);
            }
            x
        });
        let new_nodes = self.output_layer.forward(output);
        Graph::new(new_nodes, graph.edges)
    }
}

#[derive(Module, Debug)]
pub struct GINConv<B: Backend> {
    layers: Vec<GINMLP<B>>,
    layer_norm: Option<LayerNorm<B>>,
}

impl<B: Backend> GINConv<B> {
    pub fn forward(&self, graph: Graph<B>) -> Tensor<B, 2> {
        let layer_features = std::iter::once(graph.nodes.clone().sum_dim(0)).chain(
            self.layers.iter().scan(graph, |prev_graph, mlp_layer| {
                let next_graph = mlp_layer.forward(prev_graph.clone());
                let next_nodes_aggregated = next_graph.nodes.clone().sum_dim(0);
                *prev_graph = next_graph;
                Some(next_nodes_aggregated)
            }),
        );
        let mut concatenated_features = Tensor::cat(layer_features.collect::<Vec<_>>(), 0);
        if let Some(layer_norm) = &self.layer_norm {
            concatenated_features = layer_norm.forward(concatenated_features);
        }
        concatenated_features
    }
}
```

With that, the new high level architecture becomes:

#{
  show: figure.with(
    caption: [High-level ML pipeline for the GIN approach],
    kind: image,
  )
  show: depth-shadow-block.with(inner-border: theme.layout.borderWidth.small)
  show: pad.with(1em)

  import fl: *

  let border-node(
    ..args,
    tint: theme.colors.overlay,
  ) = {
    node(
      ..args,
      fill: tint.mix((theme.colors.base, 200%)),
      stroke: theme.layout.borderWidth.small + tint,
      corner-radius: theme.layout.radius.small,
    )
  }

  let blob = border-node

  fl.diagram(
    debug: in-preview-or(3, false),
    node-fill: theme.colors.base,
    node-stroke: theme.colors.border + theme.layout.borderWidth.small,
    edge-stroke: theme.colors.foreground + theme.layout.borderWidth.small,
    crossing-fill: theme.colors.base,
    crossing-thickness: 4,
    blob(
      (0, 2),
      shape: shapes.parallelogram.with(),
      tint: catppuccin-accents.rosewater,
      name: <lgr>,
    )[Graph 1],
    edge("->", label-side: right)[nodes],
    edge(
      (),
      (0, 2.5),
      (0.45, 2.5),
      "d",
      (0, 3.5),
      //<lgc>,
      "--",
      label-side: right,
      label-pos: 70%,
    )[edges],
    blob(
      (0, 3),
      shape: shapes.trapezium.with(dir: top),
      tint: catppuccin-accents.pink,
      name: <lemb>,
      snap: 4,
    )[Embedding],
    edge("->"),
    blob(
      (0, 4),
      shape: shapes.trapezium.with(dir: bottom),
      tint: catppuccin-accents.sapphire,
      name: <lgc>,
    )[Isomorphism\ Network],
    edge("->"),
    blob(
      (0, 5),
      tint: catppuccin-accents.yellow,
      shape: shapes.hexagon,
      name: <lgc>,
    )[SwiGLU],
    edge("d", (0.5, 6), "->"),

    blob(
      (1, 2),
      shape: shapes.parallelogram.with(),
      tint: catppuccin-accents.rosewater,
      name: <rgr>,
    )[Graph 2],
    edge("->"),
    edge((), (1, 2.5), (0.55, 2.5), "d", (1, 3.5), <rgc>, "-->"),
    blob(
      (1, 3),
      shape: shapes.trapezium.with(dir: top),
      tint: catppuccin-accents.pink,
      snap: 4,
    )[Embedding],
    edge("->"),
    blob(
      (1, 4),
      shape: shapes.trapezium.with(dir: bottom),
      tint: catppuccin-accents.sapphire,
      name: <rgc>,
    )[Isomorphism\ Network],
    edge("->"),
    blob(
      (1, 5),
      tint: catppuccin-accents.yellow,
      shape: shapes.hexagon,
      name: <lgc>,
    )[SwiGLU],
    edge("d", (0.5, 6), "->"),

    blob(
      (0.5, 6),
      tint: catppuccin-accents.mauve,
      shape: shapes.pill,
    )[$cos(theta)$],

    edge("->"),
    border-node(
      (0.5, 7),
      tint: catppuccin-accents.blue,
      shape: shapes.house.with(dir: top),
      name: <similarity-score>,
    )[
      Similarity\ Score
    ],

    node(
      enclose: (<lemb>, <lgc>, <rgc>, <similarity-score>),
      shape: shapes.rect,
      inset: 10pt,
      corner-radius: theme.layout.radius.medium,
      fill: theme.colors.overlay,
      stroke: none,
    )[
      #show: align.with(top + right)
      #set text(fill: theme.colors.muted)
      #show: pad.with(right: -10pt - 0.5em, top: -10pt - 1em)
      AI Model
    ],
  )
} <fig-high-level-gin-approach>

== Cosine Similarity <cosine-similarity-chapter>

After embedding the source files into a high-dimensional vector space, we can compute the cosine similarity between the vectors. The cosine similarity is a measure of how similar two vectors are, and is calculated as the dot product of the two vectors divided by the product of the magnitudes of the two vectors, as shown in @eq-cosine-similarity.

$
  cos(theta) = (a dot b) / (||a|| times ||b||)
$ <eq-cosine-similarity>

#{
  show: block.with(breakable: false)
  success-callout(heading: [
    Advantages of cosine similarity 🤯
  ])[
    #{
      set figure(placement: none)
      show: figure.with(
        caption: [Cosine similarity visualization. Source: #link("https://medium.com/@milana.shxanukova15/cosine-distance-and-cosine-similarity-a5da0e4d9ded")[Medium, Milana Shkhanukova]],
      )
      show: box.with(inset: 0pt, stroke: theme.colors.border, clip: true)
      image("assets/cosine-similarity.png")
    }

    The GIN inherent property of being injective guarantees longer embedding vectors for bigger ASTs, which is not meaningful for similarity of the solution approach. Through cosine similarity, we can compare the "direction" of the encoded solutions independent of their length.
  ]
}

== Evaluation of GIN approach

#pdf.attach(
  "assets/val_f1_20260701_201949_unknown.csv",
  mime-type: "text/csv",
  relationship: "data",
  description: "Validation F1 score timeseries for the GIN approach",
)
#let val_f1_series = csv(
  "assets/val_f1_20260701_201949_unknown.csv",
  row-type: dictionary,
).map(it => {
  it.Step = eval(it.Step)
  it.Value = eval(it.Value)
  it
})
#let smoothed_val_f1_series = smooth_series(
  val_f1_series.map(it => it.Value),
  strength: 98%,
)

#pdf.attach(
  "assets/val_bestthres_20260701_201949_unknown.csv",
  mime-type: "text/csv",
  relationship: "data",
  description: "Validation best threshold timeseries for the GIN approach",
)
#let val_best_threshold_series = csv(
  "assets/val_bestthres_20260701_201949_unknown.csv",
  row-type: dictionary,
).map(
  it => {
    it.Step = eval(it.Step)
    it.Value = eval(it.Value)
    it
  },
)
#let smoothed_val_best_threshold_series = smooth_series(
  val_best_threshold_series.map(it => it.Value),
  strength: 98%,
)
#let gin_training_steps = val_f1_series.map(it => it.Step).sorted().last()
#let gin_best_training_checkpoint = 78000
#let gin_best_threshold = (
  val_best_threshold_series
    .zip(smoothed_val_best_threshold_series)
    .sorted(key: ((it, value)) => calc.abs(
      it.Step - gin_best_training_checkpoint,
    ))
    .at(0)
    .at(1)
)
#let gin_best_f1_score = (
  val_f1_series
    .zip(smoothed_val_f1_series)
    .sorted(key: ((it, value)) => calc.abs(
      it.Step - gin_best_training_checkpoint,
    ))
    .at(0)
    .at(1)
)

After training for #gin_training_steps steps, the best performing model was at #gin_best_training_checkpoint, with an ideal threshold of #calc.round(digits: 2, gin_best_threshold) and an F1-Score (assuming 0.5 threshold) of *#calc.round(digits: 2, gin_best_f1_score)* on the validation set. This is significantly higher than our baseline of #calc.round(digits: 2, gcn-validation-data.unbiased_classification_statistic.f1_score) in the GCN approach.

#{
  show: figure.with(
    caption: [F1 Score and Best Threshold over Training Time for the GIN approach],
  )
  show: depth-shadow-block.with(
    inner-border: theme.layout.borderWidth.small,
  )
  show: pad.with(1em)
  set text(size: theme.layout.fontSize.tiny)
  lq.diagram(
    width: 100%,
    height: 6cm,
    title: [Key Metrics over Training Time for the GIN approach],
    xlabel: [Steps],
    ylabel: [F1 Score],
    xlim: (0, auto),
    yaxis: (
      //format-ticks: lq.tick-format.fraction.with(),
      tick-args: (
        density: 75%,
      ),
    ),
    xaxis: (
      exponent: "inline",
      tick-args: (
        density: 50%,
      ),
      format-ticks: (ticks, ..args) => ticks.map(
        num_metric_suffix.with(round_digits: 2),
      ),
    ),
    legend: (
      position: bottom + left,
    ),
    lq.plot(
      val_f1_series.map(it => it.Step),
      val_f1_series.map(it => it.Value),
      color: color-cycle.at(1).mix((theme.colors.base, 100%)),
      mark: none,
    ),
    lq.plot(
      val_f1_series.map(it => it.Step),
      smoothed_val_f1_series,
      stroke: color-cycle.at(1) + 1pt,
      color: color-cycle.at(1),
      mark: none,
      label: "F1 Score",
    ),
    lq.yaxis(
      label: [Threshold],
      position: right,
      tick-args: (
        density: 75%,
      ),
      lq.plot(
        val_best_threshold_series.map(it => it.Step),
        val_best_threshold_series.map(it => it.Value),
        color: color-cycle.at(0).mix((theme.colors.base, 100%)),
        mark: none,
      ),
      lq.plot(
        val_best_threshold_series.map(it => it.Step),
        smoothed_val_best_threshold_series,
        stroke: color-cycle.at(0) + 1pt,
        color: color-cycle.at(0),
        mark: none,
        label: "Best Threshold",
      ),
    ),
    lq.line(
      (gin_best_training_checkpoint, 0%),
      (gin_best_training_checkpoint, 100%),
      stroke: (paint: theme.colors.border, dash: "dashed", thickness: 1pt),
      label: [Best Checkpoint],
    ),
  )
}


#pdf.attach(
  "assets/gin_validation.json",
  mime-type: "application/json",
  relationship: "data",
  description: "Unprocessed validation data for the GIN approach",
)
#let gin-validation-data = json("assets/gin_validation.json")
#let gin-roc-data = (
  (
    gin-validation-data
      .classification_statistics
      .map(stat => (
        stat.false_positive_rate,
        stat.recall,
      ))
      .sorted(key: it => (it.at(0), it.at(1)))
  )
    .rev()
    .dedup(key: it => it.at(0))
    .rev()
)
#let gin-roc-auc = gin-validation-data.roc_auc
#let gin-pr-data = (
  (
    gin-validation-data
      .classification_statistics
      .map(stat => (stat.recall, stat.precision))
      .sorted(key: it => (it.at(0), it.at(1)))
  )
    .rev()
    .dedup(key: it => it.at(0))
    .rev()
)
#let gin-pr-auc = gin-validation-data.pr_auc

@fig-roc-auc-gin shows an AUC score of *#calc.round(digits: 2, gin-roc-auc)*, which indicates very good classification performance of the GIN approach. However, @fig-pr-auc-gin shows a lower AUC of only *#calc.round(digits: 2, gin-pr-auc)*, indicating struggles with the precision in the minority cases (= plagiarism cases).

The sharp corner in these curves shows that the model is very good at differentiating between non-plagiarized and plagiarized solutions. Only a small change in the classification threshold is required in order to accurately predict all the cases. This indicates that nearly all positive cases are above a certain threshold and nearly all negative cases are below that same threshold.

#let gin-roc-figure = {
  show: it => [#it <fig-roc-auc-gin>]
  show: figure.with(
    caption: [ROC curve comparing GCN and GIN approaches],
    kind: image,
  )
  show: depth-shadow-block.with(
    inner-border: theme.layout.borderWidth.small,
  )
  show: pad.with(1em)
  show: lq.set-tick(
    inset: 0pt,
    outset: 0pt,
  )

  lq.diagram(
    width: 6cm,
    height: 6cm,
    xlim: (0, 1),
    ylim: (0, 1),
    title: [*ROC curve*],
    xlabel: "False Positive Rate",
    ylabel: "True Positive Rate",
    grid: none,
    xaxis: (
      tick-args: (
        density: 50%,
      ),
    ),
    yaxis: (
      tick-args: (
        density: 25%,
      ),
    ),
    legend: (
      position: bottom + right,
    ),
    lq.fill-between(
      gcn-roc-data.map(it => it.at(0)),
      gcn-roc-data.map(it => it.at(1)),
      stroke: (paint: color-cycle.at(0), dash: "dashed"),
      fill: theme.colors.base,
      label: [
        #set align(right)
        GCN (AUC = #calc.round(digits: 2, gcn-roc-auc))
      ],
      z-index: 2,
    ),
    lq.fill-between(
      gin-roc-data.map(it => it.at(0)),
      gin-roc-data.map(it => it.at(1)),
      stroke: (paint: color-cycle.at(1)),
      fill: theme.colors.success.transparentize(80%),
      label: [
        #set align(right)
        GIN (AUC = #calc.round(digits: 2, gin-roc-auc))
      ],
      z-index: 1,
    ),
    lq.plot(
      (0, 1),
      (0, 1),
      stroke: (paint: theme.colors.muted, dash: "dashed"),
      mark: none,
      label: "Baseline",
    ),
  )
}

#let gin-pr-figure = {
  show: it => [#it <fig-pr-auc-gin>]
  show: figure.with(
    caption: [Precision-Recall curve comparing GCN and GIN approaches],
    kind: image,
  )
  show: depth-shadow-block.with(
    inner-border: theme.layout.borderWidth.small,
  )
  show: pad.with(1em)
  show: lq.set-tick(
    inset: 0pt,
    outset: 0pt,
  )
  lq.diagram(
    width: 6cm,
    height: 6cm,
    xlim: (0, 1),
    ylim: (0, 1),
    title: [*PR curve*],
    xlabel: "Recall",
    ylabel: "Precision",
    grid: none,
    xaxis: (
      tick-args: (
        density: 50%,
      ),
    ),
    yaxis: (
      tick-args: (
        density: 25%,
      ),
    ),
    legend: (
      position: bottom + right,
    ),
    lq.fill-between(
      gcn-pr-data.map(it => it.at(0)),
      gcn-pr-data.map(it => it.at(1)),
      stroke: (paint: color-cycle.at(0), dash: "dashed"),
      fill: theme.colors.base,
      label: [
        #set align(right)
        GCN (AUC = #calc.round(digits: 2, gcn-pr-auc))
      ],
      z-index: 2,
    ),
    lq.fill-between(
      gin-pr-data.map(it => it.at(0)),
      gin-pr-data.map(it => it.at(1)),
      stroke: (paint: color-cycle.at(1)),
      fill: theme.colors.success.transparentize(80%),
      label: [
        #set align(right)
        GIN (AUC = #calc.round(digits: 2, gin-pr-auc))
      ],
      z-index: 1,
    ),
  )
}

#{
  show: web-or(it => it, place.with(auto, float: true))
  set figure(placement: none)
  grid(
    columns: broader-than(560pt, 2, 1),
    gutter: 1em,
    align: top,
    gin-roc-figure,
    gin-pr-figure,
  )
}

I love the idea of embeddings. There is something intriguing about encoding some object into a high-dimensional vector space and then being able to reason about it in that space. Naturally, I performed some dimensionality reduction on the embeddings to visualize the source file representations in 2D using #link("https://github.com/jean-pierreboth/annembed")[annembed], a crate inspired by t-SNE and UMAP.


#pdf.attach(
  "assets/annembed_dim_red.json",
  mime-type: "application/json",
  relationship: "data",
  description: "Reduced embedding space for the GIN approach",
)
#let gin-embedding-reduced = json("assets/annembed_dim_red.json")

#let hash-string(s) = {
  s.split("").filter(it => it != "").map(str.to-unicode).sum()
}

#let highest-plag-embedding = (
  gin-embedding-reduced.sorted(key: it => it.plag_paths.len()).rev().at(0)
)

#let other-gin-embeddings = gin-embedding-reduced.filter(it => (
  it.self_path != highest-plag-embedding.self_path and it.self_path not in highest-plag-embedding.plag_paths
))
#let grouped-gin-embeddings = gin-embedding-reduced.filter(it => (
  it.self_path not in other-gin-embeddings.map(it => it.self_path)
))

#{
  show: it => [#it <fig-embedding-gin>]
  show: figure.with(
    caption: [2D source code embedding space for the GIN approach],
    kind: image,
  )
  show: depth-shadow-block.with(
    inner-border: theme.layout.borderWidth.small,
  )
  show: pad.with(1em)

  let color-from-path(path) = {
    let exercise = path.split("/").at(-2).split(".").at(0).split("_").at(0)
    let hash = hash-string(exercise)
    color-cycle.at(calc.rem(hash, color-cycle.len()))
  }

  let zoom = (
    x: (-1.8, -1.2),
    y: (0.6, 1.1),
  )

  let data = (
    lq.scatter(
      other-gin-embeddings.map(it => it.component1),
      other-gin-embeddings.map(it => it.component2),
      color: other-gin-embeddings.map(it => color-from-path(it.self_path)).map(it => it.transparentize(25%)),
      stroke: none,
      size: 5pt,
    ),
    lq.scatter(
      grouped-gin-embeddings.map(it => it.component1),
      grouped-gin-embeddings.map(it => it.component2),
      color: catppuccin-accents.green,
      mark: "x",
      size: 4pt,
      z-index: 5,
    ),
  )

  layout(((width, height)) => {
    let size = calc.min(width, 10cm)

    lq.diagram(
      width: size,
      height: size,
      xlim: (-4, 4),
      ylim: (-4, 4),
      xaxis: (
        //format-ticks: none,
        ticks: (0,),
      ),
      yaxis: (
        //format-ticks: none,
        ticks: (0,),
      ),
      ..data,
      lq.rect(
        zoom.x.at(0),
        zoom.y.at(0),
        width: zoom.x.at(1) - zoom.x.at(0),
        height: zoom.y.at(1) - zoom.y.at(0),
        stroke: (paint: theme.colors.muted, thickness: 0.5pt),
      ),
      lq.place(75%, 25%)[
        #show: scale.with(200%, reflow: true)
        #lq.diagram(
          width: 1.5cm,
          height: 1.5cm / (zoom.x.at(1) - zoom.x.at(0)) * (zoom.y.at(1) - zoom.y.at(0)),
          fill: theme.colors.base,
          xlim: zoom.x,
          ylim: zoom.y,
          xaxis: (ticks: (0,), format-ticks: none),
          yaxis: (ticks: (0,), format-ticks: none),
          ..data,
        )
      ],
    )
  })
}

@fig-embedding-gin colorizes every dot according the exercise the source file should solve. The green crosses mark a plagiarized group of source files. The embedding space clearly captures the similarity between high level task and low level implementation details, as evident by similarly colored clusters.

= Shipping

Making this whole thing ready as web application.

#info-callout(heading: [burn-rs makes this easy])[
  With burn and Rust's wasm32 target, we can easily compile the model to a self contained binary executable by the browser.
  #{
    show: box
    no-codly(```rust
    include_bytes!("resources/production.bpk")
    ```)
  } bundles all model weights and the model itself into a single file.
]

== Mass plagiarism detection

The separation between heavy embedding computation and performant similarity calculation allows for efficient mass cross-file plagiarism detection. This becomes a two step process:

+ Compute the embeddings for all source files in the dataset
+ Compute the similarity of every embedding with every other embedding

@fig-mass-time-behavior illustrates the exponential savings in compute power with increasing number of source files.

#{
  show: it => [#it <fig-mass-time-behavior>]
  show: figure.with(
    caption: [Time behavior comparison between full pipeline and stage separation],
    kind: image,
  )
  show: depth-shadow-block.with(
    inner-border: theme.layout.borderWidth.small,
  )
  show: pad.with(1em)

  let embedding-time = 5
  let similarity-time = 1
  lq.diagram(
    width: 100%,
    height: 6cm,
    title: [Compute required for mass plagiarism detection],
    xlim: (1, auto),
    legend: (
      position: left + top,
    ),
    yaxis: (
      format-ticks: none,
    ),
    xlabel: [Number of source files],
    ylabel: [Time required],
    lq.plot(
      label: [Full pipeline for every comparison],
      range(1, 100),
      x => {
        // x * (x - 1) / 2 * 2 heavy embeddings
        x * embedding-time * (x - 1)
      },
      mark: none,
    ),
    lq.plot(
      label: [Separation of stages],
      range(1, 100),
      x => {
        // x heavy embeddings, x * (x - 1) / 2 fast similarity calculations
        x * embedding-time + x * (x - 1) / 2 * similarity-time
      },
      mark: none,
    ),
  )
}

== Node decision importance

Backpropagation is great! Using the gradients for a single forward pass, we get a lot of nice information. Mainly, the importance of each node in the graph for the final decision. Every embedded AST node has a gradient vector $G in R^"embedding_size"$. The node importance is simply the magnitude of the gradient vector $||G||$.

#callout()[
  #strike[You can try this out yourself in the interactive demo just down below.]
  #set text(fill: theme.colors.danger)
  Currently, you can't, because burn-rs has problems with autodifferentiation on web.
]

== Try it out yourself <try-it-out-yourself>

#web-or[
  #layout(((width, height)) => {
    let height = width / 16 * 9

    xhtml(
      strfmt(
        ```html
        <iframe data-testid="embed-iframe" src="https://timerertim.github.io/plagiarinator/" width="{width}" height="{height}" frameBorder="0" allowfullscreen="true" allow="encrypted-media; fullscreen;" loading="lazy"></iframe>
        ```.text,
        width: width.pt(),
        height: height.pt(),
      ),
      inner-width: width,
      inner-height: height,
      outer-width: width,
      outer-height: height,
    )
  })
][
  #link("https://timerertim.github.io/plagiarinator/")[GitHub Pages Deployment]
]


= References <references>

Project Repository: #link("https://github.com/TimerErTim/plagiarinator")[TimerErTim/plagiarinator]

C++ Dataset: #link("https://ieee-dataport.org/open-access/programming-homework-dataset-plagiarism-detection")[Programming Homework Dataset for Plagiarism Detection | IEEE DataPort]

Dimensionality Reduction: #link("https://github.com/jean-pierreboth/annembed")[annembed]
