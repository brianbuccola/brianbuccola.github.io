---
layout: post
title: "The semantics of \"unless\""
date: 2012-11-30 17:48
redirect_from: /blog/2012-11-30-the-semantics-of-unless.html
---

Grading some assignments the other day on the syntax and semantics of "unless",
I was pretty astounded by the range of intuitions students had about what the
truth table for "$$\alpha$$ unless $$\beta$$" should be. I got nearly every one
of the 16 possibilities. OK, maybe not that many. But there was one common
"mistake" among the range of answers, which I'd like to discuss.

Take, for example, the following sentence.

    Floyd will go buy beer unless it's snowing outside.

Suppose I uttered this sentence several hours ago, and now we want to evaluate
the truth of the utterance. There are four cases to consider.

1.  Floyd went and bought beer, and it was snowing outside.
2.  Floyd did not go and buy beer, and it was snowing outside.
3.  Floyd went and bought beer, and it was not snowing outside.
4.  Floyd did not go and buy beer, and it was not snowing outside.

The received wisdom is that the only case in which my utterance was false is
case 4, in which both subclauses of my utterance are false. In every other
case, what I uttered has held true.

While most students got cases 2-4 correct, case 1 really tripped up a lot of
students. They said my utterance would be false in such a case. That's because
when I say that Floyd will go buy beer unless it's snowing outside, it's
natural to infer that he'll go *only unless* it's snowing, which is just an
ungrammatical way of saying that he'll go *only if* it's *not* snowing. That
is, if it *is* snowing, he *won't* go.

But this inference---that if it's snowing outside, Floyd won't go buy
beer---seems really to just be a very strong implicature, as it can be
cancelled.

    Floyd will go buy beer unless it's snowing outside... in which case, I'm
    not sure if he'll go or not.

    Floyd will go buy beer unless it's snowing outside. And even then/in that
    case, he'll still probably go!

With these continuations added, it's no longer natural to infer that if it's
snowing, Floyd won't go, unless of course the listener has some special
knowledge that I/the speaker lacks.

If we consider this inference to be just an implicature and not part of the
truth-conditional content of "unless", then case 1 results in my utterance
being true, and the truth table for "$$\alpha$$ unless $$\beta$$" turns out, in
fact, to be exactly the same as that of $$\alpha \lor \beta$$, which is also
the same as $$\lnot\beta \to \alpha$$.[^xor]

[^xor]: If the implication is taken to be part of the truth conditions of
        "unless", i.e., not as an implicature, then the truth table is the same
        as that of exclusive "or".

What's interesting is that, several days later, the students were very
reluctant to buy my implicature story.[^pts] It was only after I really fleshed
out the scenario that some of them relented; and even then, others still found
the "...in which case" follow-ups unnatural.

[^pts]: And no, it's not because they were arguing for points.  At least, I
        don't think so.

But this strong inference associated with "unless" is not unique to "unless".
We see it with "if", too---which is expected, I suppose, if "$$\alpha$$ unless
$$\beta$$" is semantically equivalent to "if it's not the case that $$\beta$$,
then $$\alpha$$". Suppose, for example, that I utter the following sentence.

    Floyd will go buy beer if it's not snowing.

Even here, it's natural to infer that Floyd will go buy beer *only* if it's not
snowing. That is, if it *is* snowing, then he *won't* go (which is precisely
what I wrote above for the "unless" utterance).

Again, though, this inference can be cancelled.

    Floyd will go buy beer if it's not snowing. And even if it is snowing,
    he'll still probably go!

The additional inference associated with "if" has been called *conditional
perfection* because it completes (or perfects) the conditional by making it a
biconditional: Floyd will go buy beer if and only if it's not snowing
outside.[^gz] In symbols: $$b \leftrightarrow \lnot s$$ (mnemonic: $$b =$$
"beer", $$s =$$ "snow").

[^gz]: Geis, Michael L. and Arnold M.  Zwicky. 1971. On Invited Inferences.
*Linguistic Inquiry* **2**: 561-6. The term was suggested to the authors by
Lauri Karttunen.

The same could be said of the "unless" utterance, if "only unless" were
grammatical: Floyd will go buy beer unless and only unless it's snowing. In
symbols (assuming that "$$\alpha$$ unless $$\beta$$" means $$\lnot\beta \to
\alpha$$): $$\lnot s \leftrightarrow b$$.

They are identical. My experience, however, is that students don't have *that*
much trouble with "if", so why is "unless" so confusing? Is it the added
negation? I have to admit that before I started grading, it took me a good
several minutes to remind myself what "unless" is, or is supposed to, mean.

Bonus question: If "unless" is semantically equivalent to logical "or", then is
the added inference associated with "unless", which turns it into exclusive
"or", derived in the same way as the inference that, under normal
circumstances, makes "or" be interpreted exclusively? Or is it just a
coincidence that these two expressions, which both share a truth table with
$$\lor$$ but differ in that one is a subordinator and the other a coordinator,
both happen to be regularly strengthened into an exclusive interpretation?
