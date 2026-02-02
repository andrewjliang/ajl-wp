<!-- Example header file for Typst documents -->
<!-- Copy custom commands from `header.tex` here. -->
<!-- The lines with \qty...\vbg aid compatibility with the `physics` TeX package -->
::: {.content-visible when-format="typst"}

\providecommand{\qty}{}
\providecommand{\vb}[1]{\mathbf{#1}}
\providecommand{\vbg}[1]{\boldsymbol{#1}}

\DeclareMathOperator{\E}{\mathbb{E}}
\DeclareMathOperator{\Pr}{\mathbb{P}}
\providecommand{\cvp}{\xrightarrow{\:p\,}}
\providecommand{\Norm}{\mathcal{N}\qty}
\usepackage{amsmath}
\usepackage{bm}
\newcommand{\indep}{\!\perp\!\!\!\perp}
\newcommand{\argmin}{\mathop{\text{arg~min}}\limits}
\usepackage[mathscr]{euscript}
\newtheorem{theorem}{Theorem}[section]
\newtheorem{corollary}{Corollary}[theorem]
\newtheorem{lemma}[theorem]{Lemma}
\newtheorem{assumption}[theorem]{Assumption}
:::