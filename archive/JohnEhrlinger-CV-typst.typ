// Simple numbering for non-book documents
#let equation-numbering = "(1)"
#let callout-numbering = "1"
#let subfloat-numbering(n-super, subfloat-idx) = {
  numbering("1a", n-super, subfloat-idx)
}

// Theorem configuration for theorion
// Simple numbering for non-book documents (no heading inheritance)
#let theorem-inherited-levels = 0

// Theorem numbering format (can be overridden by extensions for appendix support)
// This function returns the numbering pattern to use
#let theorem-numbering(loc) = "1.1"

// Default theorem render function
#let theorem-render(prefix: none, title: "", full-title: auto, body) = {
  if full-title != "" and full-title != auto and full-title != none {
    strong[#full-title.]
    h(0.5em)
  }
  body
}
// Some definitions presupposed by pandoc's typst output.
#let content-to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(content-to-string).join("")
  } else if content.has("body") {
    content-to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms.item: it => block(breakable: false)[
  #text(weight: "bold")[#it.term]
  #block(inset: (left: 1.5em, top: -0.4em))[#it.description]
]

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let fields = old_block.fields()
  let _ = fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  block.with(..fields)(new_content)
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
        show figure.where(kind: kind): set figure(numbering: _ => {
          let subfloat-idx = quartosubfloatcounter.get().first() + 1
          subfloat-numbering(n-super, subfloat-idx)
        })
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => block({
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          })

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
  let children = old_title_block.body.body.children
  let old_title = if children.len() == 1 {
    children.at(0)  // no icon: title at index 0
  } else {
    children.at(1)  // with icon: title at index 1
  }

  // TODO use custom separator if available
  // Use the figure's counter display which handles chapter-based numbering
  // (when numbering is a function that includes the heading counter)
  let callout_num = it.counter.display(it.numbering)
  let new_title = if empty(old_title) {
    [#kind #callout_num]
  } else {
    [#kind #callout_num: #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block,
    block_with_new_content(
      old_title_block.body,
      if children.len() == 1 {
        new_title  // no icon: just the title
      } else {
        children.at(0) + new_title  // with icon: preserve icon block + new title
      }))

  align(left, block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1)))
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
        inset: 8pt)[#if icon != none [#text(icon_color, weight: 900)[#icon] ]#title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}



#import "@preview/fontawesome:0.6.0": *

//------------------------------------------------------------------------------
// Style
//------------------------------------------------------------------------------

// const color
#let color-darknight = rgb("#131A28")
#let color-darkgray = rgb("#333333")
#let color-middledarkgray = rgb("#414141")
#let color-gray = rgb("#5d5d5d")
#let color-lightgray = rgb("#999999")

// Default style
#let state-font-header = state("font-header", (:))
#let state-font-text = state("font-text", (:))
#let state-color-accent = state("color-accent", color-darknight)
#let state-color-link = state("color-link", color-darknight)

//------------------------------------------------------------------------------
// Helper functions
//------------------------------------------------------------------------------

// icon string parser

#let parse_icon_string(icon_string) = {
  if icon_string.starts-with("fa ") [
    #let parts = icon_string.split(" ")
    #if parts.len() == 2 {
      fa-icon(parts.at(1), fill: color-darknight)
    } else if parts.len() == 3 and parts.at(1) == "brands" {
      fa-icon(parts.at(2), font: "Font Awesome 6 Brands", fill: color-darknight)
    } else {
      assert(false, "Invalid fontawesome icon string")
    }
  ] else if icon_string.ends-with(".svg") [
    #box(image(icon_string))
  ] else {
    assert(false, "Invalid icon string")
  }
}

// contaxt text parser
#let unescape_text(text) = {
  // This is not a perfect solution
  text.replace("\\", "").replace(".~", ". ")
}

// layout utility
#let __justify_align(left_body, right_body) = {
  block[
    #box(width: 4fr)[#left_body]
    #box(width: 1fr)[
      #align(right)[
        #right_body
      ]
    ]
  ]
}

#let __justify_align_3(left_body, mid_body, right_body) = {
  block[
    #box(width: 1fr)[
      #align(left)[
        #left_body
      ]
    ]
    #box(width: 1fr)[
      #align(center)[
        #mid_body
      ]
    ]
    #box(width: 1fr)[
      #align(right)[
        #right_body
      ]
    ]
  ]
}

/// Right section for the justified headers
/// - body (content): The body of the right header
#let secondary-right-header(body) = {
  context {
    set text(
      size: 10pt,
      weight: "thin",
      style: "italic",
      fill: state-color-accent.get(),
    )
    body
  }
}

/// Right section of a tertiaty headers.
/// - body (content): The body of the right header
#let tertiary-right-header(body) = {
  set text(
    weight: "light",
    size: 9pt,
    style: "italic",
    fill: color-gray,
  )
  body
}

/// Justified header that takes a primary section and a secondary section. The primary section is on the left and the secondary section is on the right.
/// - primary (content): The primary section of the header
/// - secondary (content): The secondary section of the header
#let justified-header(primary, secondary) = {
  set block(
    above: 0.7em,
    below: 0.7em,
  )
  pad[
    #__justify_align[
      #set text(
        size: 12pt,
        weight: "bold",
        fill: color-darkgray,
      )
      #primary
    ][
      #secondary-right-header[#secondary]
    ]
  ]
}

/// Justified header that takes a primary section and a secondary section. The primary section is on the left and the secondary section is on the right. This is a smaller header compared to the `justified-header`.
/// - primary (content): The primary section of the header
/// - secondary (content): The secondary section of the header
#let secondary-justified-header(primary, secondary) = {
  __justify_align[
    #set text(
      size: 10pt,
      weight: "regular",
      fill: color-gray,
    )
    #primary
  ][
    #tertiary-right-header[#secondary]
  ]
}

//------------------------------------------------------------------------------
// Header
//------------------------------------------------------------------------------

#let create-header-name(
  firstname: "",
  lastname: "",
) = {
  context {
    pad(bottom: 5pt)[
      #block[
        #set text(
          size: 32pt,
          style: "normal",
          font: state-font-header.get(),
        )
        #text(fill: color-gray, weight: "thin")[#firstname]
        #text(weight: "bold")[#lastname]
      ]
    ]
  }
}

#let create-header-position(
  position: "",
) = {
  set block(
    above: 0.75em,
    below: 0.75em,
  )

  context {
    set text(
      state-color-accent.get(),
      size: 9pt,
      weight: "regular",
    )

    smallcaps[
      #position
    ]
  }
}

#let create-header-address(
  address: "",
) = {
  set block(
    above: 0.75em,
    below: 0.75em,
  )
  set text(
    color-lightgray,
    size: 9pt,
    style: "italic",
  )

  block[#address]
}

#let create-header-contacts(
  contacts: (),
) = {
  let separator = box(width: 2pt)
  if (contacts.len() > 1) {
    block[
      #set text(
        size: 9pt,
        weight: "regular",
        style: "normal",
      )
      #align(horizon)[
        #for contact in contacts [
          #set box(height: 9pt)
          #box[#parse_icon_string(contact.icon) #link(contact.url)[#contact.text]]
          #separator
        ]
      ]
    ]
  }
}

#let create-header-info(
  firstname: "",
  lastname: "",
  position: "",
  address: "",
  contacts: (),
  align-header: center,
) = {
  align(align-header)[
    #create-header-name(firstname: firstname, lastname: lastname)
    #create-header-position(position: position)
    #create-header-address(address: address)
    #create-header-contacts(contacts: contacts)
  ]
}

#let create-header-image(
  profile-photo: "",
) = {
  if profile-photo.len() > 0 {
    block(
      above: 15pt,
      stroke: none,
      radius: 9999pt,
      clip: true,
      image(
        fit: "contain",
        profile-photo,
      ),
    )
  }
}

#let create-header(
  firstname: "",
  lastname: "",
  position: "",
  address: "",
  contacts: (),
  profile-photo: "",
) = {
  if profile-photo.len() > 0 {
    block[
      #box(width: 5fr)[
        #create-header-info(
          firstname: firstname,
          lastname: lastname,
          position: position,
          address: address,
          contacts: contacts,
          align-header: left,
        )
      ]
      #box(width: 1fr)[
        #create-header-image(profile-photo: profile-photo)
      ]
    ]
  } else {
    create-header-info(
      firstname: firstname,
      lastname: lastname,
      position: position,
      address: address,
      contacts: contacts,
      align-header: center,
    )
  }
}

//------------------------------------------------------------------------------
// Resume Entries
//------------------------------------------------------------------------------

#let resume-item(body) = {
  set text(
    size: 10pt,
    style: "normal",
    weight: "light",
    fill: color-darknight,
  )
  set par(leading: 0.65em)
  set list(indent: 1em)
  body
}

#let resume-entry(
  title: none,
  location: "",
  date: "",
  description: "",
) = {
  pad[
    #justified-header(title, location)
    #secondary-justified-header(description, date)
  ]
}

//------------------------------------------------------------------------------
// Resume Template
//------------------------------------------------------------------------------

#let resume(
  title: "CV",
  author: (:),
  date: datetime.today().display("[month repr:long] [day], [year]"),
  profile-photo: "",
  font-header: "Roboto",
  font-text: "Source Sans 3",
  color-accent: rgb("#dc3522"),
  color-link: color-darknight,
  title-meta: none,
  author-meta: none,
  body,
) = {
  // Set states ----------------------------------------------------------------
  state-font-header.update(font-header)
  state-font-text.update(font-text)
  state-color-accent.update(color-accent)
  state-color-link.update(color-link)

  // Set document metadata -----------------------------------------------------
  set document(
    title: title-meta,
    author: author-meta,
  )

  set text(
    font: (font-text),
    size: 11pt,
    fill: color-darkgray,
    fallback: true,
  )

  set page(
    paper: "a4",
    margin: (left: 15mm, right: 15mm, top: 10mm, bottom: 10mm),
    footer: context [
      #set text(
        fill: gray,
        size: 8pt,
      )
      #__justify_align_3[
        #smallcaps[#date]
      ][
        #smallcaps[
          #author.firstname
          #author.lastname
          #sym.dot.c
          CV
        ]
      ][
        #counter(page).display()
      ]
    ],
  )

  // set paragraph spacing

  set heading(
    numbering: none,
    outlined: false,
  )

  show heading.where(level: 1): it => [
    #set block(
      above: 1.5em,
      below: 1em,
    )
    
    #set text(
        size: 16pt,
        weight: "regular",
    )

    #context {
      // Safely extract plain text — it.body may be a sequence (not text) when
      // the heading contains special chars or compound content
      let raw = if it.body.has("text") {
        it.body.text
      } else {
        // flatten sequence children to a plain string
        it.body.children.map(c => if c.has("text") { c.text } else { "" }).join()
      }
      align(left)[
        #text[#strong[#text(state-color-accent.get())[#raw.slice(0, 3)]#text(
            color-darkgray,
          )[#raw.slice(3)]]]
        #box(width: 1fr, line(length: 100%))
      ]
    }
  ]

  show heading.where(level: 2): it => {
    set text(
      color-middledarkgray,
      size: 12pt,
      weight: "thin",
    )
    it.body
  }

  show heading.where(level: 3): it => {
    set text(
      size: 10pt,
      weight: "regular",
      fill: color-gray,
    )
    smallcaps[#it.body]
  }

  // Other settings
  show link: set text(fill: color-link)

  // Contents
  create-header(
    firstname: author.firstname,
    lastname: author.lastname,
    position: author.position,
    address: author.address,
    contacts: author.contacts,
    profile-photo: profile-photo,
  )
  body
}

#let brand-color = (
  primary: rgb("#1a3a5c")
)
#let brand-color-background = (
  primary: brand-color.primary.lighten(85%)
)
#let brand-logo = (:)
#show link: set text(fill: rgb("#1a3a5c"), )

#set page(
  paper: "us-letter",
  margin: (x: 1.25in, y: 1.25in),
  numbering: "1",
  columns: 1,
)

#show: resume.with(
  author: (
    firstname: unescape_text("John"),
    lastname: unescape_text("Ehrlinger, PhD"),
    address: unescape_text("Hiram, Ohio"),
    position: unescape_text("Assistant Staff, Lead Data Scientist"),
    contacts: ((
      text: unescape_text("ehrlinj\@ccf.org"),
      url: unescape_text("mailto:ehrlinj\@ccf.org"),
      icon: unescape_text("fa envelope"),
    ), (
      text: unescape_text("github.com/ehrlinger"),
      url: unescape_text("https:\/\/github.com/ehrlinger"),
      icon: unescape_text("fa brands github"),
    ), (
      text: unescape_text("linkedin.com/in/ehrlinger"),
      url: unescape_text("https:\/\/linkedin.com/in/ehrlinger"),
      icon: unescape_text("fa brands linkedin"),
    ), (
      text: unescape_text("ehrlinger.github.io"),
      url: unescape_text("https:\/\/ehrlinger.github.io"),
      icon: unescape_text("fa globe"),
    )),
  ),
  author-meta: "John" + " " + "Ehrlinger, PhD",
  color-accent: brand-color.primary,
)

= Research Interests
<research-interests>
Applied statistical machine learning research conducted in close collaboration with cardiovascular surgeons and clinicians. Methodological focus spans random forest and ensemble methods, clustering, deep learning, and time series analysis, with emphasis on time-to-event and longitudinal data in cardiovascular outcomes. A sustained focus is the translation of methodological advances into clinical practice through open-source software development and reproducible analytical workflows, with current work centered on open-source implementations of multi-phase hazard analysis methods.

#horizontalrule

= Professional Experience
<professional-experience>
== Cleveland Clinic
<cleveland-clinic>
Assistant Staff, Lead Data Scientist --- Cardiovascular Outcomes, Registries and Research (CORR), Heart, Vascular & Thoracic Institute {.position}

December 2024 -- Present {.date}

Lead a team of data engineers and data scientists supporting cardiovascular outcomes research. Drive statistical methods research as applied to observational clinical research, advancing rigorous analytic approaches for cardiovascular outcomes data. Champion software engineering best practices and implement process improvements to optimize the departmental research pipeline from data collection through publication.

== Altamira Technologies
<altamira-technologies>
Senior Data Scientist -- Technical Lead {.position}

March 2023 -- October 2024 {.date}

Technical lead of the data science team supporting USAF customers on secure networks. Built a reusable Plotly-based dashboard framework; developed predictive traffic flow models and a computer vision pipeline for vehicle volume estimation at base entry points.

== Microsoft --- Azure Global Commercial Industry
<microsoft-azure-global-commercial-industry>
Senior Data and Applied Scientist -- Technical Lead {.position}

July 2015 -- April 2023 {.date}

Technical lead for customer-facing ML/AI engagements across oil & gas (Chevron), aerospace (Rolls Royce), and medical devices (Stryker). Developed Azure ML solution accelerators for predictive maintenance. Presented at Microsoft MLADS conference four times (2016--2020).

== Cleveland Clinic --- Quantitative Health Sciences
<cleveland-clinic-quantitative-health-sciences>
Assistant Staff / Assistant Professor of Medicine {.position}

August 2012 -- July 2015 {.date}

Applied random survival forests to cardiovascular outcomes research. Initiated development of the ggRandomForests R package. Began migration of institutional SAS-based hazard analysis to open-source implementations.

== Cleveland Clinic --- Thoracic and Cardiovascular Surgery
<cleveland-clinic-thoracic-and-cardiovascular-surgery>
Lead Systems Analyst: Scientific Programmer {.position}

August 1999 -- August 2012 {.date}

Supported research computing infrastructure, statistical software development, and HPC operations. Completed doctoral research in Statistics at Case Western Reserve University during this period.

#horizontalrule

= Education
<education>
== Case Western Reserve University
<case-western-reserve-university>
Doctor of Philosophy (PhD) --- Statistics {.position}

2011 {.date}

#emph[Dissertation: Regularization: Stagewise Regression and Bagging] Advisor: Hemant Ishwaran

== Case Western Reserve University
<case-western-reserve-university-1>
Master of Science (MS) --- Mechanical Engineering / Aerospace Engineering {.position}

1994 {.date}

== Case Western Reserve University
<case-western-reserve-university-2>
Bachelor of Science (BS) --- Mechanical Engineering {.position}

1993 {.date}

#horizontalrule

= Publications
<publications>
#set bibliography(style: "cv-year-desc.csl")
#bibliography("typst-all.bib", title: none, full: true)

#horizontalrule

= Software
<software>
#strong[R Packages]

- #emph[ggRandomForests] --- Visual exploration of random forest models. #link("https://github.com/ehrlinger/ggRandomForests")
- #emph[boostmtree] --- Boosted multivariate trees for longitudinal data. #link("https://github.com/ehrlinger/boostmtree")
- #emph[mixhazard] --- R port of the C code underlying the Cleveland Clinic Hazard SAS module. #link("https://github.com/ehrlinger/mixhazard")
- #emph[hvtiPlotR] --- Publication-quality HVTI graphics. #link("https://github.com/ehrlinger/hvtiPlotR")
- #emph[hvtiRutilities] --- Reproducible research utilities. #link("https://github.com/ehrlinger/hvtiRutilities")

#strong[SAS/C Software]

- #emph[hazard] --- SAS and C implementation of multi-phase hazard analysis for time-to-event decomposition. Includes C source code, SAS macros and modules. (Maintainer) #link("https://github.com/ehrlinger/hazard")

#horizontalrule

= Honors & Awards
<honors-awards>
- NASA Graduate Research Fellowship · 1992--1994
- Cleveland Clinic Innovations Award · 2003
