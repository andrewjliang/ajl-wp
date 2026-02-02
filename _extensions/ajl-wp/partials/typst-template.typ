#let orcid_svg = str(
  "<?xml version=\"1.0\" encoding=\"utf-8\"?>
  <!-- Generator: Adobe Illustrator 19.1.0, SVG Export Plug-In . SVG Version: 6.00 Build 0)  -->
  <svg version=\"1.1\" id=\"Layer_1\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" x=\"0px\" y=\"0px\"
    viewBox=\"0 0 256 256\" style=\"enable-background:new 0 0 256 256;\" xml:space=\"preserve\">
  <style type=\"text/css\">
    .st0{fill:#A6CE39;}
    .st1{fill:#FFFFFF;}
  </style>
  <path class=\"st0\" d=\"M256,128c0,70.7-57.3,128-128,128C57.3,256,0,198.7,0,128C0,57.3,57.3,0,128,0C198.7,0,256,57.3,256,128z\"/>
  <g>
    <path class=\"st1\" d=\"M86.3,186.2H70.9V79.1h15.4v48.4V186.2z\"/>
    <path class=\"st1\" d=\"M108.9,79.1h41.6c39.6,0,57,28.3,57,53.6c0,27.5-21.5,53.6-56.8,53.6h-41.8V79.1z M124.3,172.4h24.5
      c34.9,0,42.9-26.5,42.9-39.7c0-21.5-13.7-39.7-43.7-39.7h-23.7V172.4z\"/>
    <path class=\"st1\" d=\"M88.7,56.8c0,5.5-4.5,10.1-10.1,10.1c-5.6,0-10.1-4.6-10.1-10.1c0-5.6,4.5-10.1,10.1-10.1
      C84.2,46.7,88.7,51.3,88.7,56.8z\"/>
  </g>
  </svg>"
)

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
            #if "orcid" in author and str(author.at("orcid")).len() > 0 [
  #link("https://orcid.org/" + author.at("orcid"))[
    #box(height: 9pt, image(bytes(orcid_svg)))
  ]
]
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
    box(text(weight: 700, font: heading-family)[#skew(ax: 0deg)[Keywords]])
    h(1em)
    keywords.join(" " + sym.bullet + " ")
    v(0.5em)
  }
  
  if type(jelcodes) == array and jelcodes.len() > 0 [
  #v(0em)
  #box(text(weight: 700, font: heading-family)[#skew(ax: 0deg)[JEL]])
  #h(1em)
  #jelcodes.join(" " + sym.bullet + " ")
  #v(0em)
]

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

