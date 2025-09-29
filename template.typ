// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}



#let ajl-wp(
  title: none,
  subtitle: none,
  authors: none,
  blinded: false,
  date: none,
  abstract: none,
  abstract-title: none,
  thanks: none,
  cols: 1,
  lang: "en",
  region: "US",
  keywords: none,
  jelcodes: none,
  font: "libertinus serif",
  fontsize: 11pt,
  title-size: 2.0em,
  subtitle-size: 1.25em,
  heading-family: "libertinus serif",
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.4em,
  sectionnumbering: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize,
           number-type: "old-style",
           )
  show math.equation: set text(number-type: "lining", number-width: "tabular")
  set heading(numbering: sectionnumbering)
  if title != none {
    align(center)[#block(inset: 2em)[
      #set par(leading: heading-line-height, justify: false)
      #set text(hyphenate: false)
      #if (heading-family != none or heading-weight != "bold" or heading-style != "normal"
           or heading-color != black) {
        set text(font: heading-family, weight: heading-weight, style: heading-style, fill: heading-color)
        text(size: title-size)[#title]
      if thanks != none {
            footnote(thanks, numbering: "*")
            counter(footnote).update(n => n - 1)
          }
        if subtitle != none {
          parbreak()
          text(size: subtitle-size)[#subtitle]
        }
      } else {
        text(weight: "bold", size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(weight: "bold", size: subtitle-size)[#subtitle]
        }
      }
    ]]
  }
  show heading: it => {
    set text(font: heading-family, weight: heading-weight, style: heading-style,
             fill: heading-color, number-type: "lining")
    if it.numbering == none {
        it
    } else {
        block(counter(heading).display(it.numbering) + h(1em) + it.body)
    }
  }

  show figure.caption: it => [
    #set text(size: 0.9em, font: heading-family, number-type: "lining")
    // Bold the label part, regular text for the caption
    #context [#strong[#it.supplement #it.counter.display()]#it.separator #it.body]
  ]

  if authors != none {
    let count = authors.len()
    let ncols = calc.min(count, 3)
    align(center, grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      column-gutter: 0.1em,
      ..authors.map(author =>
          align(center)[
            #set text(hyphenate: false)
            #author.name \
            #author.affiliation
          ]
      )
    ))
  }

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if abstract != none {
    block(inset: 2em)[
    #v(-2em) // matching `inset`
    #set text(size: 0.9em)
    #align(center)[#text(weight: "semibold", font: heading-family)[#abstract-title]]
    #v(-0.25em)
    #abstract
    ]
  }
  if keywords != none {
    v(-2em) // should match `inset` of abstract block
    box(text(weight: 700, font: heading-family)[#skew(ax: -15deg)[Keywords]])
    h(1em)
    keywords.join(" " + sym.bullet + " ")
    v(0.5em)
  }
  if jelcodes != none {
    v(0em) // reduced spacing for keywords
    box(text(weight: 700, font: heading-family)[#skew(ax: -15deg)[JEL:]])
    h(1em)
    jelcodes.join(" " + sym.bullet + " ")
    v(0em)
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}

#set table(
  inset: 6pt,
  stroke: none
)

#import "@preview/ctheorems:1.1.3": *
#show: thmrules
#let theorem = thmbox("theorem", "Theorem")

#let fakesc(s, scaling: 0.75) = {
  show regex("\p{Ll}+"): it => {
    context text(scaling * 1em, stroke: 0.01em + text.fill, upper(it))
  }
  text(s)
}
#set page(
  paper: "us-letter",
  margin: (x: 1in,y: 1in,),
  numbering: "1",
  header: context if counter(page).get().first() > 1 {fakesc[
    Article Title
    #h(1fr)
    September 28, 2025
    ]},
)


// Modified from <https://github.com/quarto-dev/quarto-cli/blob/main/src/resources/formats/typst/pandoc/quarto/typst-show.typ>
// to add support for:
// - more complex author affiliations TODO
// - short titles TODO
// - font options
#show: doc => ajl-wp(
  title: [Article Title],
  authors: (
    (
      name: [*Jane Doe*#footnote(numbering: "*")[
        To whom correspondence should be addressed.
        Email: #link("mailto:jdoe1\@example.org".replace("\\", ""), raw("jdoe1\@example.org".replace("\\", ""))).
        Website: #link("https:\/\/example.org/".replace("\\", ""), raw("https:\/\/example.org/".replace("\\", ""))).
        Address:
        1 Union St, Seattle, WA 98101.
        
        ]],
      affiliation: [
        The Department\ 
        An Organization
        #v(2pt)
        A second affilication
        #v(2pt)
      ],
    ),
    (
      name: [*John Doe*],
      affiliation: [
        
        Another Affiliation
        #v(2pt)
      ],
    ),
    ),
  thanks: [Acknowledgements here.

],
  date: [September 28, 2025],
  abstract: [The text of your abstract. The `ajl-article` format is designed for scholarly articles, especially preprints. Its goal is to be lightweight yet customizable, with thoughtful typography and layout. The template is based off of Cory McCartan's `cmc-article` template, as well as Christopher Kenny's `ctk-article` template.

],
  abstract-title: "Abstract",
  keywords: ([3 to 6 keywords], [can go here]),
  jelcodes: ([First JEL code here], [Second JEL code here], [and so forth]),
  font: ("Cochineal",),
  fontsize: 11pt,
  heading-family: ("Linux Biolinum", "Helvetica", "Arial",),
  heading-weight: "bold",
  sectionnumbering: "1.1.1.1",
  toc_title: [Table of contents],
  toc_depth: 3,
  cols: 1,
  doc,
)

= Introduction
<sec-intro>
Body of paper. Citations are easy to use (Metropolis et al. 1953). See #ref(<sec-addl>, supplement: [Section]) for a math demonstration.

= Additional section headings here
<sec-addl>
`cmc-article` includes helpful math packages: `mathtools`, `amssymb`, `amsthm`, and `physics` by default. It also includes a default `header.tex` file with useful macros for math and statistics. Some of these are demonstrated in #ref(<eq-first>, supplement: [Eq.]).

#math.equation(block: true, numbering: "(1)", [ $ upright(bold(X)) & tilde.op cal(N) (bold(mu) \, bold(Sigma)^2) ; quad p (upright(bold(x))) = 1 / sqrt((2 pi)^k det (upright(bold(\*)) Sigma)) exp (- 1 / 2 (upright(bold(x)) - bold(mu))^tack.b bold(Sigma)^(- 1) (upright(bold(x)) - bold(mu)))\
"𝔼" (Y) & = sum_(y in cal(Y)) y "ℙ" (Y = y) = sum_(y in cal(Y)) y "𝔼" (bb(1) { Y = y }) $ ])<eq-first>

The package also includes an `assump` environment for typesetting assumptions which can be referenced by easy-to-remember abbreviations.

#theorem("Weak Law of Large Numbers")[
Let $macron(X)_n colon.eq n^(- 1) sum_(i = 1)^n X_i$. Then under and , we have $macron(X)_n arrow.r^(med p thin) mu$ as $n arrow.r oo$.

] <thm-wlln>
== An example subsection heading
<an-example-subsection-heading>
See #ref(<fig-ex>, supplement: [Figure]) for an example figure.

#figure([
#box(image("template_files/figure-typst/fig-ex-1.png"))
], caption: figure.caption(
position: bottom, 
[
Histogram of samples from a gamma distribution.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-ex>


=== Level 3 heading
<level-3-heading>
Testing that #emph[italics] and #strong[bold] text work.

==== Level 4 (numbered paragraph) heading
<level-4-numbered-paragraph-heading>
Text here.

#block[
#heading(
level: 
5
, 
numbering: 
none
, 
[
Level 5 (paragraph) heading
]
)
]
Text here.

= Conclusion
<conclusion>
The final section of the main text.

#block[
#heading(
level: 
1
, 
numbering: 
none
, 
[
References
]
)
]
#block[
#block[
Metropolis, Nicholas, Arianna W Rosenbluth, Marshall N Rosenbluth, Augusta H Teller, and Edward Teller. 1953. “Equation of State Calculations by Fast Computing Machines.” #emph[The Journal of Chemical Physics] 21 (6): 1087--92.

] <ref-metropolis1953>
] <refs>
#set heading(numbering: "A.1.1.1")
#counter(heading).update(0)
= Appendix section
<appendix-section>
This section will be numbered like an appendix
