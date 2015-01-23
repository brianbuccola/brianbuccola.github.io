<!-- begin metadata
title: Vim and unicode keybindings: math, IPA, and more
date: 2013-11-14 08:54
end metadata -->

I recently stumbled on the
[.vimrc](https://github.com/connermcd/dotfiles/blob/github/.vimrc) of
[connermcd](https://github.com/connermcd) and noticed that he has an extensive
list of keybindings for inputting Greek and math unicode characters. For
example, given the mapping

    map! <C-v>!= ≠

then to input "≠", just type `<C-v>!=`. This is incredibly useful for
anyone who uses vim to take notes involving mathy things.  Compare:

    a >= b & b >= c -> a >= c     # ascii only

    a ≥ b ∧ b ≥ c → a ≥ c         # nice unicode

The second line is, I think, much cleaner looking and more legible than the
first, and only takes a couple extra keystrokes to type out, once you've set up
the appropriate mappings.

For example, I'm currently writing this post in vim, and if I have the
following mappings

    map! <C-v>fa ∀
    map! <C-v>ex ∃
    map! <C-v>!= ≠
    map! <C-v>-> →
    map! <C-v>& ∧

then I can easily type out a formula of predicate logic in unicode, which comes
out like this:

∀x∃y[x ≠ y → Px ∧ Ry]

Of course, on this blog I could also write such a formula in $\LaTeX{}$, which
comes out like this:

$\forall x \exists y [x \neq y \to Px \land Ry]$

I think in general the $\LaTeX{}$ version probably looks nicer than the unicode
version on websites like this, but there are some benefits to using unicode:

1. Unicode doesn't need to be rendered by a conversion engine such as Mathjax;
it just works.
1. Unicode is much more legible in source code (e.g., the markdown version of
this blog post) than $\LaTeX{}$. Compare:

    `∀x∃y[x ≠ y → Px ∧ Ry]`

    `$\forall x \exists y [x \neq y \to Px \land Ry]$`

1. If you use vim to write emails (e.g. with mutt), or forum posts (e.g. with
vimperator for Firefox), etc., then you'll usually want to use unicode, since
most email clients and forums cannot render $\LaTeX{}$.
1. There are lots of unicode characters which you can't write in $\LaTeX{}$
and/or which Mathjax and other engines can't handle, such as IPA symbols, which
I find myself needing to type relatively often.

For example, if I'm emailing a student or writing a forum post about the
transcription of the word "ring", I would usually go a site like
[this](http://westonruter.github.io/ipa-chart/keyboard/), click-type the
transcription, copy it, then paste it---sort of time-consuming. Plus, if I'm
not connected to the internet, then I can't use this method at all. But if I
have the following mappings in my `.vimrc`

    map! <C-v>I ɪ
    map! <C-v>N ŋ
    map! <C-v>r ɹ

then all I do is type

    "Ring" is transcribed: [<C-v>r<C-v>I<C-v>N].

which becomes

    "Ring" is transcribed: [ɹɪŋ].

By the way, you don't *need* the `<C-v>` prefix, but that's useful to group
these bindings together, and to not override other keys. For example, you could
do

    map! N ŋ

but then any time you pressed `N`, `ŋ` would appear, making it very difficult
to ever type `N`.

`<C-v>` makes sense as a prefix because it's what you press to type a unicode
character manually: for example, `<C-v>u2203` comes out as ∃, because the
unicode encoding for that character is U+2203.

Anyway, to close this out, I've put some useful mappings below. If you want
more ideas about what to map, check out the Wikipedia page [Unicode/List of
Useful Symbols](https://en.wikibooks.org/wiki/Unicode/List_of_useful_symbols),
which has a ton of math, science, music, etc. characters, all of which could be
handily mapped to in your `.vimrc`. ♫♫ cool! ♪♩♪

    " Greek {{{
    " (thanks to connermcd for these)
    map! <C-v>GA Γ
    map! <C-v>DE Δ
    map! <C-v>TH Θ
    map! <C-v>LA Λ
    map! <C-v>XI Ξ
    map! <C-v>PI Π
    map! <C-v>SI Σ
    map! <C-v>PH Φ
    map! <C-v>PS Ψ
    map! <C-v>OM Ω
    map! <C-v>al α
    map! <C-v>be β
    map! <C-v>ga γ
    map! <C-v>de δ
    map! <C-v>ep ε
    map! <C-v>ze ζ
    map! <C-v>et η
    map! <C-v>th θ
    map! <C-v>io ι
    map! <C-v>ka κ
    map! <C-v>la λ
    map! <C-v>mu μ
    map! <C-v>xi ξ
    map! <C-v>pi π
    map! <C-v>rh ρ
    map! <C-v>si σ
    map! <C-v>ta τ
    map! <C-v>ps ψ
    map! <C-v>om ω
    map! <C-v>ph ϕ
    " }}}
    " Math {{{
    map! <C-v>-> →
    map! <C-v>< ⇌
    map! <C-v>n ↑
    map! <C-v>v ↓
    map! <C-v>= ∝
    map! <C-v>~ ≈
    map! <C-v>!= ≠
    map! <C-v>!> ⇸
    map! <C-v>~> ↝
    map! <C-v>>= ≥
    map! <C-v><= ≤
    map! <C-v>0 °
    map! <C-v>ce ¢
    map! <C-v>* •
    map! <C-v>co ⌘
    map! <C-v>fa ∀
    map! <C-v>ex ∃
    map! <C-v>& ∧
    map! <C-v>or ∨
    " }}}
    " IPA {{{
    " vowels
    map! <C-v>-i ɨ
    map! <C-v>-u ʉ
    map! <C-v>m ɯ
    map! <C-v>I ɪ
    map! <C-v>Y ʏ
    map! <C-v>U ʊ
    map! <C-v>/o ø
    map! <C-v>@ ə
    map! <C-v>E ɛ
    map! <C-v>oe œ
    map! <C-v>^ ʌ
    map! <C-v>O ɔ
    map! <C-v>ae æ
    map! <C-v>A ɑ
    " consonants
    map! <C-v>N ŋ
    map! <C-v>r ɹ
    map! <C-v>mf ɱ
    map! <C-v>eth ð
    " }}}
