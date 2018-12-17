---
title: "Implementing lists in the simply typed lambda calculus"
date: 2013-04-22 11:09
redirect_from: /blog/2013-04-22-implementing-lists-in-the-simply-typed-lambda-calculus.html
tags: [semantics, logic, mathematics]
---

One of my goals this summer is to re-read Bob Carpenter's *Type-Logical
Grammar* and to actually do (at least some of) the exercises. If I manage to
follow through with that goal, I'll write up my solutions (or attempts at
solutions) to some of the more interesting or difficult exercises. I'll start
that off with the last exercise from Chapter 2, which says to add to the simply
typed lambda calculus the type $\sigma^*$ for lists of objects of type
$\sigma$. First, let me review Chapter 2 to set the stage.

Review
------

Chapter 2 deals with the syntax, semantics, and proof theory of the simply
typed lambda calculus. I'll review here the syntax and semantics, but not the
proof theory.

### Syntax

Carpenter builds up the set $\mathbf{Typ}$ of types inductively from a set
$\mathbf{BasTyp}$ of *basic types*, using just one type constructor: $\to$.

**Definition (types).** The set of *types* is the smallest set $\mathbf{Typ}$
such that

1. $\mathbf{BasTyp} \subseteq \mathbf{Typ}$.
2. If $\sigma, \tau \in \mathbf{Typ}$, then $(\sigma \to \tau) \in
   \mathbf{Typ}$.

A type of the form $(\sigma \to \tau)$ is called a *functional type*.

For each type $\tau$, there is a set $\mathbf{Var}_\tau$ of variables of
type $\tau$ and a set $\mathbf{Con}_\tau$ of constants of type $\tau$.
The set of lambda terms of type $\tau$ is defined as follows.

**Definition (terms).** The set of *(lambda) terms* of type $\tau$ is the
smallest set $\mathbf{Term}_\tau$ such that

1. $\mathbf{Var}_\tau \subseteq \mathbf{Term}_\tau$.
2. $\mathbf{Con_\tau} \subseteq \mathbf{Term}_\tau$.
3. If $\alpha \in \mathbf{Term}_{\sigma \to \tau}$ and $\beta \in
   \mathbf{Term}_\sigma$, then $(\alpha(\beta)) \in \mathbf{Term}_\tau$.
4. If $\tau = \sigma \to \rho$ and $x \in \mathbf{Var}_\sigma$ and $\alpha
   \in \mathbf{Term}_\rho$, then $\lambda x . (\alpha) \in
   \mathbf{Term}_\tau$.

A term of the form $(\alpha(\beta))$, usually abbreviated $\alpha(\beta)$
or $\alpha\ \beta$, is a *functional application* of $\alpha$ to $\beta$.
However, a term $\alpha$ with a functional type $(\sigma \to \tau)$ is not
a function per se---$\alpha(\beta)$ is (the result of) a *syntactic*
operation more akin to term concatenation than functional application.
Nevertheless, $\alpha$ is called functional (it has a functional type)
because of how it is *interpreted semantically* (model theoretically).

### Semantics

In the model theory, functional terms denote functions in the normal
mathematical sense. Before defining denotations, I need to define frames and
models.

**Definition (frame).** A *frame* for the set $\mathbf{BasTyp}$ is a
collection $\mathbf{Dom} = \bigcup\mathbf{Dom}_\tau$ ($\tau \in
\mathbf{BasTyp}$) of *basic domains*.

**Definition (model).** A *model* is a pair $\langle \mathbf{Dom},I \rangle$
in which $\mathbf{Dom}$ is a frame, and $I$ is the *interpretation
function* mapping constants to the appropriate domain, i.e. $I(\alpha) \in
\mathbf{Dom}_\tau$ if $\alpha \in \textbf{Con}_\tau$.

**Definition (denotation).** Given a model $\mathcal{M} = \langle
\textbf{Dom}, I \rangle$ and a variable assignment $\theta$, the
*denotation* $[\![\alpha]\!]^\theta_\mathcal{M}$ of a term $\alpha$ with
respect to $\mathcal{M}$ and $\theta$ is given by:

1. If $\alpha \in \mathbf{Var}_\tau$, then
   $[\![\alpha]\!]^\theta_\mathcal{M} = \theta(\alpha)$.
2. If $\alpha \in \mathbf{Con}_\tau$, then
   $[\![\alpha]\!]^\theta_\mathcal{M} = I(\alpha)$.
3. $[\![\alpha(\beta)]\!]^\theta_\mathcal{M} =
   [\![\alpha]\!]^\theta_\mathcal{M} ([\![\beta]\!]^\theta_\mathcal{M}]\!])$,
   assuming $\alpha$ and $\beta$ are appropriately typed.
4. $[\![\lambda x . \alpha]\!]^\theta_\mathcal{M} = f$ such that $f(a) =
   [\![\alpha]\!]^{\theta[x:=a]}_\mathcal{M}$, where $\theta[x:=a]$ is that
   variable assignment $\theta'$ such that $\theta'(x) = a$ and
   $\theta'(y) = \theta(y)$ for each $y \neq x$.

Note that the left-hand side of the equality statement in (3) involves term
concatenation (function*al* application), whereas the right-hand side involves
real function application in the strict sense.

In other words, $\alpha$ of type $(\sigma \to \tau)$ is a lambda term whose
denotation is a function that maps (elements of the domain of) $\sigma$-type
things to (elements of the domain of) $\tau$-type things.

Carpenter goes on to give the usual axioms for the simply typed lamda calculus
($\alpha$-, $\beta$-, and $\eta$-reduction schemata) and the usual rules
of inference (reflexivity, transitivity, congruence, and equivalence) and to
prove that the resulting system is both sound and complete.

### Product and Sum Types

The latter part of the chapter adds product and sum types to the system.
Product types allow functional terms to take multiple arguments at one time (in
a certain sense), while sum types introduce functional terms that can act
polymorphically.

Exercise: List Types
--------------------

Let me now turn to the actual exercise.

> Consider adding $\sigma^*$ for lists of objects of type $\sigma$. What
> would the terms look like in this scheme and how are they interpreted and
> treated proof-theoretically? Is there any gain in expressive power by
> admitting arbitrary lists? What might we do to interpret infinite sequences?

In this post, I'll only address the first two questions: what do list terms
look like, and how are they interpreted. For my answer, I'll be borrowing from
the functional programming language Haskell.

### Lists in Haskell

In Haskell, lists are things like `[3, 5, 0]`, `["hello", "world"]`, etc. The
order of list elements is important, and list elements can repeat. In that
sense, lists are more like tuples (sequences) than sets, except that whereas a
tuple (both in Haskell and in Carpenter's section on product types) can contain
objects of all different types, list elements must all be of the *same* type.
For example, in Haskell, `(3, "hello")` is a possible pair, consisting of an
integer and a string, but `[3, "hello"]` is not a possible list.

In Haskell, the list type is written as `[a]`, where `a` is any type. For
example, `[3, 5, 0]` has type `[Int]`, while `["hello", "world"]` has type
`[String]`. (NB: In Haskell a string is itself a list of characters, i.e.
`String` is just a type synonym for `[Char]`.)

Note that Haskell overloads the symbols `[]`: they are used to construct both
terms (Haskell expressions) and types.

I'll follow Haskell's lead by writing $[\sigma]$ instead of Carpenter's
$\sigma^*$ for the type of lists containing $\sigma$-type objects, and I'll
similarly overload the symbols $[\ ]$.

### Syntax

I begin by adding $[\sigma]$ to $\mathbf{Typ}$. I do so by adding the
following clause to the definition of types:

3. If $\sigma \in \mathbf{Typ}$, then $[\sigma] \in \mathbf{Typ}$.

So $[\ ]$ is a unary type constructor (it takes a single type and returns a
new type), whereas $\to$ is a binary type constructor (it takes two types and
returns a new type).

As for terms, I assume that for each list type $\tau = [\sigma]$ there is a
set $\mathbf{Var}_\tau$ of variables of type $\tau$ and a set
$\mathbf{Con}_\tau$ of constants of type $\tau$. We now need a way to
construct arbitrary list terms (similar to how abstraction lets us construct
functional terms).

#### Haskell Detour

In Haskell, there are two list constructors: `[]`, or *nil* (the empty list),
and `(:)`, or *cons*. The cons operator has the following type signature:

```haskell
(:) :: a -> [a] -> [a]
```

This means it takes something of type `a` and something of type `[a]` and
returns something of type `[a]`. More precisely, it takes an `a`-type
object---call it `x`--- and a list of `a`-type objects---call it `list`---and
it returns a new list, `list'`, whose elements are `x` followed by the elements
of `list`. In other words, cons prepends its first argument (an object of type
`a`) to the beginning of its second argument (a list of objects of type `a`).
(Of course, in Haskell a pure function always returns a new object; it doesn't
modify objects given as arguments, so cons does not *literally* prepend
anything to a given list, unlike, say, `list.insert(0, x)` in Python.)

For example, to construct a list of integers (objects of type `Int`), we start
with `[]` of type `[Int]`, and using `(:)` we add to the front of `[]` an
integer like `0` to obtain `(:) 0 []`, or using infix notation, `0 : []`. The
result is of type `[Int]` and is normally written as `[0]`, which hides the
cons operator. From `[0]` we can obtain `5 : [0]`, written `[5, 0]`, and from
that we can obtain `3 : [5, 0]`, or `[3, 5, 0]`, and so on.

More generally, `[x1, x2, ..., xN]` is syntactic sugar for `x1 : ( x2 : ( ... (
xN : [] ) ... ) )`.

#### Back to Terms

Returning to our lambda terms, we want, for each type $\sigma$, a nil term
$[\ ]$ of type $[\sigma]$, and a term constructor for adding an object of
type $\sigma$ to a list of type $[\sigma]$ to produce a new such list. I do
so by adding the following clauses to the definition of the set
$\mathbf{Term}_\tau$ of terms of type $\tau$.

5. If $\tau = [\sigma]$, then $[\ ] \in \mathbf{Term}_\tau$.
6. If $\tau = [\sigma]$ and $\alpha \in \mathbf{Term}_\sigma$ and $\beta
   \in \mathbf{Term}_\tau$, then $(\alpha : \beta) \in \mathbf{Term}_\tau$.

Like functional application, $:$ is a binary term contructor: it takes two
terms to produce a new term.

Following Haskell, I make the following conventions:

- $[\alpha] =_\mbox{def} (\alpha : [\ ])$.
- $[\alpha, \beta, \dots] =_\mbox{def} (\alpha : [\beta, \dots])$.

The latter schema can be applied recursively for any list of arbitrary length.
For example

$$
\begin{align}
[3, 5, 0] &= (3 : [5, 0])           \\
          &= (3 : (5 : [0]))        \\
          &= (3 : (5 : (0 : [\ ])))
\end{align}
$$

Since there is a one-to-one correspondence between $[\alpha, \beta, \dots,
\gamma]$-looking things and $(\alpha : (\beta : (\dots (\gamma : [\ ])
\dots)))$-looking things, one might wonder if we can instead reformulate (6)
as follows (in two steps).

6. If $\tau = [\sigma]$ and $\alpha \in \mathbf{Term}_\sigma$, then
   $[\alpha] \in \mathbf{Term}_\tau$.
7. If $\tau = [\sigma]$ and $\alpha \in \mathbf{Term}_\sigma$ and $[\beta]
   \in \mathbf{Term}_\tau$, then $[\alpha, \beta] \in \mathbf{Term}_\tau$.

(In other words, we can construct a singleton list from a single object, and a
2-element list from two objects.)

The problem is that (7) cannot be applied recursively. For example, from $0$
we can obtain $[0]$ by appyling (6), and from $5$ and $[0]$ we can obtain
$[5,0]$ by applying (7). But we cannot apply (7) to, say, $3$ and $[5,0]$
to obtain $[3,5,0]$ because, although $[5,0]$ is of type $[\sigma]$,
$5,0$ is not a term of any kind, let alone one of type $\sigma$.

For this reason, and for the sake of making cons explicit, I'll stick with the
first formulation of (6) above.

### Semantics

Now that I've added list types and list terms to the syntax, I need to add
their denotations to the model theory, and this is where I'm a bit stuck,
primarily because there are several options and I don't know which is
best/normal, or which one Carpenter has in mind.

If $\alpha$ is of a list type, say $[\sigma]$, then the denotation of
$\alpha$ is in $\mathbf{Dom}_{[\sigma]}$, but what precisely is the
structure of $\mathbf{Dom}_{[\sigma]}$?

For example, functional terms denote functions, so the denotation of $\alpha$
of type $(\sigma \to \tau)$ is a member of
$\mathbf{Dom}_{\tau}^{\mathbf{Dom}_\sigma}$, i.e.  a function from
$\mathbf{Dom}_\sigma$ to $\mathbf{Dom}_\tau$. Product terms denote pairs
(and more generally, tuples), so the denotation of $\langle \alpha, \beta
\rangle$ of type $\sigma \times \tau$ is a member of $\mathbf{Dom}_\sigma
\times \mathbf{Dom}_\tau$. But what does/should a list $\alpha$ of type
$[\sigma]$ denote, set theoretically? A flat set, i.e. a member of the power
set of $\mathbf{Dom}_\sigma$?  Probably not, because sets don't care about
order or repetition, whereas lists (as I've defined them) do. What about
tuples, i.e. members of $\mathbf{Dom}_\sigma \times \dots \times
\mathbf{Dom}_\sigma$? Maybe, but product terms already do that. Something
else?  I'm not sure.

A concrete example might help decide. Suppose we have the type $\mathbf{Ind}$
for individuals and that $\mathbf{john}, \mathbf{bill}, \mathbf{sue} \in
\mathbf{Term}_\mathbf{Ind}$. Then we can create a list of these individuals,
$[\mathbf{john}, \mathbf{bill}, \mathbf{sue}]$, which is of type
$[\mathbf{Ind}]$. Suppose also that in some model $\mathcal{M}$,
$\mathbf{john}$ denotes $j$, $\mathbf{bill}$ denotes $b$, and
$\mathbf{sue}$ denotes $s$, where $j,b,s \in \mathbf{Dom}_\mathbf{Ind}$.
Then what should the list of these three individuals denote? Probably *not* the
flat set $\{j,b,s\} \in \mbox{Pow}(\mathbf{Dom}_\mathbf{Ind})$, because then
$[\mathbf{john}, \mathbf{bill}, \mathbf{sue}]$ and $[\mathbf{bill},
\mathbf{john}, \mathbf{sue}]$ and $[\mathbf{john}, \mathbf{bill},
\mathbf{bill}, \mathbf{sue}]$ would all denote the same set (at least if we
apply the most obvious denotation mapping), which is probably undesirable. One
reason for introducing lists in the first place is, I assume, so they can serve
as meaning representations for natural language expressions that care about
order and repetition.

Assuming, then, that we want these three lists to denote different things, the
only reasonable possibility I can think of is to map lists to tuples. For
example, $[\mathbf{john}, \mathbf{bill}, \mathbf{sue}]$ will denote $\langle
j,b,s \rangle$, which is an element of $\mathbf{Ind} \times \mathbf{Ind}
\times \mathbf{Ind}$. In this way, list terms are essentially like product
terms, but with two main differences: (i) both products and lists denote
tuples, but lists are composed of objects of the *same* type, meaning that the
tuples they denote will contain objects from the *same* domain; and (ii) empty
and singleton lists are possible, whereas empty and singleton tuples are in
general (at least for Carpenter) not, as far as I can tell.

The following clauses get added to the definition of denotation.

5. If $\tau = [\sigma]$ and $\alpha = [\ ] \in \mathbf{Term}_\tau$, then
   $[\![\alpha]\!]^\theta_\mathcal{M} = \emptyset$.
6. $[\![(\alpha : \beta)]\!]^\theta_\mathcal{M} = \langle
   [\![\alpha]\!]^\theta_\mathcal{M}, [\![\beta]\!]^\theta_\beta \rangle$,
   assuming $\alpha$ and $\beta$ are appropriately typed.

Continuing the example above, $[\mathbf{john}] = (\mathbf{john} : [\ ])$
denotes $\langle j, \emptyset \rangle \in \mathbf{Dom}_\mathbf{[Ind]}$. And
$[\mathbf{john}, \mathbf{bill}, \mathbf{sue}]$ denotes $\langle j, \langle
b, \langle s,\emptyset \rangle \rangle \rangle \in
\mathbf{Dom}_\mathbf{[Ind]}$. Rewriting tuples in the usual way (analogous to
lists above), where $\langle a,b,c, \dots \rangle =_\mbox{def} \langle a,
\langle b,c, \dots \rangle \rangle$, the latter denotation becomes $\langle
j,b,s,\emptyset \rangle$.

So what is the structure of $\mathbf{Dom}_\mathbf{[Ind]}$? It's a set whose
members are tuples, of varying size, consisting of individuals (except the last
tuple member, which is always $\emptyset$ except in the case of the empty
tuple).

More generally, $\mathbf{Dom}_{[\sigma]}$ is a set whose members are tuples,
of varying size, consisting of elements from $\mathbf{Dom}_\sigma$.

This is different from the case of products: the domain of intepretation for,
say, a pair of terms $\langle \alpha,\beta \rangle$ is $\mathbf{Dom}_\sigma
\times \mathbf{Dom}_\tau$, which contains only pairs, not tuples of any other
size; and the domain of interpretation for, say, a triple of terms $\langle
\alpha,\beta,\gamma \rangle$ is $\mathbf{Dom}_\sigma \times \mathbf{Dom}_\tau
\times \mathbf{Dom}_\rho$, which contains only triples, not tuples of any
other size. Hence, whereas, say, $[\alpha, \beta]$ and $[\alpha, \beta,
\gamma]$ have denotations in the same domain, $\langle \alpha,\beta \rangle$
and $\langle \alpha,\beta,\gamma \rangle$ do not.

I'll conclude by mentioning that it's kind of weird to use $\emptyset$ in the
denotation of lists, but this is necessary because the denotation function is a
total function, and since the empty list, $[\ ]$, is a term, it requires a
denotation. If $[\ ]$ is of type $[\sigma]$, it doesn't make sense for its
denotation to include anything from $\mathbf{Dom}_\sigma$, so we're stuck
with having it denote something like $\emptyset$.

One way to avoid this would be to redefine lists: empty lists are simply not
possible terms (objects). The smallest list would then be a singleton list,
which would denote a $1$-tuple, so $[\mathbf{john}]$ would denote $\langle
j \rangle$ rather than $\langle j,\emptyset \rangle$, and $[\mathbf{john},
\mathbf{bill}, \mathbf{sue}]$ would denote $\langle j,b,s \rangle$ rather
than $\langle j,b,s,\emptyset \rangle$.
