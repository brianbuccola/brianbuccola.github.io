---
layout: post
title: "Mapping letters to the natural numbers"
date: 2012-12-09 16:01
redirect_from: /blog/2012-12-09-mapping-letters-to-the-natural-numbers.html
tags: semantics mathematics
---

It's the end of the fall semester, and I have one last final exam problem to
grade for the semantics class I'm TAing for. Actually, it's the first problem
on the exam, but I saved it till last because nearly every student seems to
have gotten it totally wrong. Which is surprising, given that the problem
revolves around one of the first concepts the students learned, a concept that
is central to formal semantics: generating and interpreting expressions in some
suitable way. What's more, they even saw the converse (so to speak) of this
problem on the midterm.

The problem says to use the symbols $$a$$, $$b$$, $$c$$, $$d$$, and $$e$$ to
generate a set of expressions that denote all and only the natural numbers
(i.e., the set of non-negative integers) and to do so without any natural
number being named more than once. In other words, provide syntactic formation
rules for generating infinitely many expressions from just those five letters,
and provide semantic valuation rules for mapping those expressions onto the
natural numbers, such that each expression corresponds to exactly one natural
number, and each natural number is the correspondent of exactly one expression,
i.e., an isomorphism between the set of $$abcde$$-expressions and the set of
natural numbers. (The problem on the midterm was the converse: to decide
whether the set of expressions formed, in some given way, from the four letters
$$a$$, $$b$$, $$c$$, and $$d$$ were, under some given valuation rules,
isomorphic to the natural numbers.)

The spirit of the problem, I think, is to use all and only the (mutually
distinct) letters $$a$$, $$b$$, $$c$$, $$d$$, and $$e$$. However, in principle
the problem can be solved using just one letter.

For example, let $$L = \{a\}$$. Then we can generate an infinite set $$E$$ of
expressions with the following recursive formation rules.

1. $$a \in E$$.
2. If $$x \in E$$, then $$xa \in E$$.
3. Nothing else is a member of $$E$$.

Rule 2 is essentially a suffixation rule. Thus, $$E$$ contains the expressions
$$a$$, $$aa$$, $$aaa$$, etc., where we suffix a single $$a$$ to any already
well-formed expression to generate a new well-formed expression. We can
interpret these expressions with the following valuation rules.

1. $$v(a) = 0$$.
2. If $$x \in E$$, then $$xa = v(x) + 1$$.

Thus, for example, we have the following valuations.

$$
\begin{align}
v(a)   &= 0 \\
v(aa)  &= v(a) + 1 = 0 + 1 = 1 \\
v(aaa) &= v(aa) + 1 = 1 + 1 = 2 \\
       &\ldots
\end{align}
$$

And in general, $$v(a^n) = n-1$$, where $$a^n$$ is shorthand for the expression
consisting of exactly $$n$$ occurrences of $$a$$. Clearly, these valuation
rules make the set $$E$$ isomorphic to the set of natural numbers: each
expression in $$E$$ correpsonds to exactly one natural number, and each natural
number is in turn the correspondent of (is expressible by) exactly one
expression in $$E$$.

But this language isn't all that interesting. More interesting are the
languages formed from two or more letters. For example, let $$L = \{a, b\}$$
and consider the following formation rules.

1. If $$x \in L$$, then $$x \in E$$.
2. If $$x \in E$$, $$x \neq a$$, $$y \in L$$, then $$xy \in E$$.
3. Nothing else is a member of $$E$$.

Again, rule 2 is a suffixation rule, with the stipulation that nothing can be
suffixed to $$a$$. (We'll see why in a moment.) Thus, $$E$$ contains the
expressions $$a$$, $$b$$, $$ba$$, $$bb$$, $$baa$$, $$bab$$, etc., but $$E$$
does not contain the expressions $$aa$$, $$ab$$, $$aba$$, etc. The reason for
excluding these latter expressions should become clear from the following
valuation rules.

1. $$v(a) = 0$$ and $$v(b) = 1$$.
2. If $$x \in E$$, $$x \neq a$$, $$y \in L$$, then $$v(xy) = 2 \cdot v(x) +
   v(y)$$.

Since $$v(a) = 0$$, if $$aa$$ were a well-formed expression, i.e., if the
condition "$$x \neq a$$" were removed, then the valuation of $$aa$$ would be
the same as that of $$a$$. That is, the valuation rules would fail to make
$$E$$ isomorphic to the set of natural numbers because there would be at least
one natural number, namely $$0$$, that has more than one correspondent in
$$E$$. ($$0$$ would be expressible by more than one $$abcde$$-expression.)

Continuing on, we have the following valuations.

$$
\begin{align}
v(a)    &= 0 \\
v(b)    &= 1 \\
v(ba)   &= 2 \cdot v(b) + v(a) = 2 \cdot 1 + 0 = 2 \\
v(bb)   &= 2 \cdot v(b) + v(b) = 2 \cdot 1 + 1 = 3 \\
v(baa)  &= 2 \cdot v(ba) + v(a) = 2 \cdot 2 + 0 = 4 \\
v(bab)  &= 2 \cdot v(ba) + v(b) = 2 \cdot 2 + 1 = 5 \\
        &\ldots
\end{align}
$$

This language, and its interpretation, should look familiar: it's binary,
except we've replaced $$0$$ with $$a$$ and $$1$$ with $$b$$. The following
table shows the expressions of $$E$$, the corresponding expressions in binary,
and the corresponding expressions in decimal; and of course by "corresponding"
expressions we mean expressions whose valuations are the same natural number.

$$
\begin{align}
L=\{a,b\} && \text{Binary} && \text{Decimal} \\
a         && 0             && 0 \\
b         && 1             && 1 \\
ba        && 10            && 2 \\
bb        && 11            && 3 \\
baa       && 100           && 4 \\
bab       && 101           && 5 \\
bba       && 110           && 6 \\
bbb       && 111           && 7 \\
baaa      && 1000          && 8 \\
\ldots    && \ldots        && \ldots
\end{align}
$$

From here it's easy to see that the solution to the problem, with $$L =
\{a,b,c,d,e\}$$, amounts to devising a base-5 language. I won't write down the
answer here, just in case some student stumbles on this post, but extending the
binary, or two-letter, case is pretty straightforward.
