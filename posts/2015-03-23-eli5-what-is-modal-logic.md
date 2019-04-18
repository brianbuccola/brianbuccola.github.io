---
title: "ELI5: What is modal logic?"
date: 2015-03-23 16:55
redirect_from: /blog/2015-03-23-eli5-what-is-modal-logic.html
tags: [eli5, logic, semantics, linguistics]
---

Someone recently asked me what sort of background knowledge is required to study
modal logic. I thought I'd share my reply here, in case it might be of use to
people.

My first taste of modal logic was [Richard Montague][rm]'s intensional logic
(IL), as applied to natural language. IL is a complex combination of
higher-order typed logic (with typed λ-terms) and two types of modal logic (see
the end of this post). Needless to say, I struggled long and hard to disentangle
the pieces and understand them individually. In fact, for a while, I thought
that modal logic *was* IL. It was only later that I discovered that, actually,
even basic propositional logic can be modalized.

I strongly believe now that the study of modal logic (be it in a logic course or
in a natural language semantics course) should begin with modal propositional
logic, not modal predicate (quantificational) logic. Modality and quantification
can much more easily be combined once they are each individually well
understood.

If you're new to modal logic and have, up to now, felt a little intimidated or
confused by it, then hopefully the preceding paragraphs have eased your mind. If
not, then hopefully the rest of this post will.

## Explain it like I'm 5: What is modal logic?

Modal logic is an extension of other, more basic types of logic, primarily
classical *propositional logic* and *predicate logic*. You can learn modal logic
once you've learned propositional logic. You do *not* need to know predicate
logic to learn modal logic, although in practice many modal logics are
extensions of predicate logic, which itself is an extension of propositional
logic.

Here are some types of logic, in order (more or less) of increasing complexity.

- **Propositional logic** is the simplest logic. It contains *propositional
  variables* (p, q, r, ...) and *logical connectives* (¬, ∧, ∨, →, ...). You can
  create formulas like p, p ∧ q, (p ∨ ¬q) → r, etc. The truth value of a complex
  formula ϕ (one containing logical connectives) is a function of the truth
  values of the immediate subformulas of ϕ, based on the [*truth tables*][tt]
  for the logical connectives.

- **Non-quantificational predicate logic** extends propositional logic by
  creating atomic formulas out of *n*-place *predicate symbols* (P, R, S, ...),
  i.e. symbols that take *n* *individual symbols* (a, b, c, ...) to create a
  formula, such as Pa, Rab, Sabc, etc. The individual symbols are taken from a
  *domain (or universe) of individuals*, D (or U). This logic still contains the
  logical connectives, so you can create complex formulas like Pa ∧ (Rab →
  ¬Sabc). As in propositional logic, the truth value of a complex formula ϕ is a
  function of the truth values of the immediate subformulas of ϕ, based on the
  truth tables for the logical connectives.

- **Quantificational (first-order) predicate logic** extends
  non-quantificational predicate logic by adding *individual variables* (x, y,
  z, ...) and *quantifier symbobls* (∃, ∀) that operate over individual
  variables. You can create formulas like ∀xPx, ∃x∃yRxy, Pa ∧ ∀x(Sxbc → Px),
  etc. The truth value of a formula ϕ with a quantifier depends on whether the
  formula in the immediate scope of the quantifier is true of some (in the case
  of ∃) or all (in the case of ∀) individuals in the domain (roughly speaking).
  For example, ∃xPx is true iff P is holds of *some* individual in the domain,
  and ∀xPx is true iff P holds of *every* individual in the domain (roughly
  speaking). (**Second-** and other **higher-order predicate logics** are
  extensions of first-order predicate logic, which allow quantification not only
  over individuals, but also over sets (of sets (...(of sets)...)) of
  individuals.)

- **Modal propositional logic** extends propositional logic by adding
  *intensional operators* (e.g. ◇, □) and a *domain of possible worlds* and by
  making truth value assignments world-dependent, meaning that a formula ϕ only
  has a truth value relative to (or "in") a possible world. This means that it
  no longer makes sense to say that ϕ is true or that ϕ is false; rather, we say
  that ϕ is true in (relative to) w1, false in w2, and so on. (A formula
  generally has different truth values in different possible worlds.) You can
  make formulas like p, p ∧ q, □p, □p → ◇q, etc. The truth value of a formula ϕ
  with an intensional operator depends on whether the formula in the immediate
  scope of the operator is true in some (in the case of ◇) or all (in the case
  of □) worlds accessible from the world relative to which ϕ is evaluated. For
  example, ◇p is true in w iff p is true in *some* world v which is accessible
  from w, and □p is true in w iff p is true in *every* world v which is
  accessible from w. Which worlds are accessible from which other worlds is
  determined by an *accessibility relation*. Accessibility relations play a huge
  role in modal logic.

- **Modal predicate logic** extends modal propositional logic in the same way
  that non-modal predicate logic extends non-modal propositional logic. It thus
  contains both intensional operators and quantifier symbols, so you can create
  complicated formulas like ◇(Rab → ∃x∀y(¬□Px ∧ □Sxy)).

Different intensional operators and different accessibility relations give rise
to different modal logics, some of which have been used to model various
real-world phenomena. Some examples:

- possibility and necessity (**alethic logic**)
- permission and obligation (**deontic logic**)
- knowledge (**epistemic logic**)
- belief (**doxastic logic**)
- time (**temporal logic**)

In the case of time, possible "worlds" model points in time and are ordered by
an "earlier than" relation, e.g. "t1 < t2" means t1 is earlier in time than t2.
Thus, the domain of possible worlds/times/states can have quite a rich
structure; that is, it need not be a simple set, but can in addition have
structure (relations, etc.) defined on it.

Montague's intensional logic actually includes both worlds and times, so that a
formula ϕ is said to be true (or false) in a particular world, at a particular
time. Thus, ϕ can be true in w at time t1, but false in w at time t2; and ϕ can
be true in w1 at time t, but false in w2 at time t; and so forth.

[rm]: https://en.wikipedia.org/wiki/Richard_Montague
[tt]: https://en.wikipedia.org/wiki/Truth_table
