/-
Copyright (c) 2026 Oscar Chiew.
Released under Apache 2.0 license as described in the file LICENSE.

JSP-000399: recovery of a finite set from its fixed-order subset-sum multiset.

The original yes/no question has a negative answer.  This file proves a
three-parameter family of four-element counterexamples for the case k = 2.
For 0 < a < b < c, set

  L(a,b,c) = {0, a+b, a+c, b+c}
  R(a,b,c) = {a, b, c, a+b+c}.

Their pair-sum multisets agree, while the underlying sets are distinct.
-/

import Lean.Elab.Tactic.Omega

namespace JSP000399

/-- All sums of two distinct positions in a list, retaining multiplicity. -/
def pairSums : List Nat → List Nat
  | [] => []
  | x :: xs => xs.map (x + ·) ++ pairSums xs

/-- The left member of the parametric homometric pair. -/
def leftFamily (a b c : Nat) : List Nat :=
  [0, a + b, a + c, b + c]

/-- The right member of the parametric homometric pair. -/
def rightFamily (a b c : Nat) : List Nat :=
  [a, b, c, a + b + c]

/-- The pair-sum multisets agree for every choice of parameters.

The six sums on the two sides differ only by swapping the third and fourth
entries after associativity and commutativity of natural-number addition are
normalized. -/
theorem pairSums_perm_parametric (a b c : Nat) :
    (pairSums (leftFamily a b c)).Perm
      (pairSums (rightFamily a b c)) := by
  have h₁ : (a + b) + (a + c) = a + (a + b + c) := by omega
  have h₂ : (a + b) + (b + c) = b + (a + b + c) := by omega
  have h₃ : (a + c) + (b + c) = c + (a + b + c) := by omega
  have hperm :
      [a + b, a + c, b + c, a + (a + b + c),
          b + (a + b + c), c + (a + b + c)].Perm
        [a + b, a + c, a + (a + b + c), b + c,
          b + (a + b + c), c + (a + b + c)] := by
    apply List.Perm.cons
    apply List.Perm.cons
    exact
      (List.Perm.swap (b + c) (a + (a + b + c))
        [b + (a + b + c), c + (a + b + c)]).symm
  simpa [pairSums, leftFamily, rightFamily, h₁, h₂, h₃] using hperm

/-- Under `0 < a < b < c`, the left list represents a four-element set. -/
theorem leftFamily_nodup {a b c : Nat}
    (ha : 0 < a) (hab : a < b) (hbc : b < c) :
    (leftFamily a b c).Nodup := by
  simp [leftFamily] <;> omega

/-- Under `0 < a < b < c`, the right list represents a four-element set. -/
theorem rightFamily_nodup {a b c : Nat}
    (ha : 0 < a) (hab : a < b) (hbc : b < c) :
    (rightFamily a b c).Nodup := by
  simp [rightFamily] <;> omega

/-- The two represented sets are different: zero lies only on the left. -/
theorem leftFamily_not_same_elements {a b c : Nat}
    (ha : 0 < a) (hab : a < b) (hbc : b < c) :
    ¬ (∀ x : Nat, x ∈ leftFamily a b c ↔ x ∈ rightFamily a b c) := by
  intro hsame
  have hzeroLeft : 0 ∈ leftFamily a b c := by simp [leftFamily]
  have hzeroRight : 0 ∈ rightFamily a b c := (hsame 0).mp hzeroLeft
  simp [rightFamily] at hzeroRight
  omega

/-- A three-parameter family of genuine counterexamples to unique recovery
from the multiset of two-element subset sums. -/
theorem parametric_counterexample {a b c : Nat}
    (ha : 0 < a) (hab : a < b) (hbc : b < c) :
    ∃ (A B : List Nat),
      A.Nodup ∧
      B.Nodup ∧
      (¬ ∀ x : Nat, x ∈ A ↔ x ∈ B) ∧
      (pairSums A).Perm (pairSums B) := by
  exact ⟨leftFamily a b c, rightFamily a b c,
    leftFamily_nodup ha hab hbc,
    rightFamily_nodup ha hab hbc,
    leftFamily_not_same_elements ha hab hbc,
    pairSums_perm_parametric a b c⟩

/-- The classical four-element witness used as the catalog-level disproof:
`{0,3,4,5}` and `{1,2,3,6}`. -/
theorem concrete_counterexample :
    ∃ (A B : List Nat),
      A.Nodup ∧
      B.Nodup ∧
      (¬ ∀ x : Nat, x ∈ A ↔ x ∈ B) ∧
      (pairSums A).Perm (pairSums B) := by
  exact parametric_counterexample (a := 1) (b := 2) (c := 3)
    (by omega) (by omega) (by omega)

/-- Public endpoint corresponding to the negative answer recorded as
JSP-000399. -/
theorem jsp_000399 :
    ∃ (A B : List Nat),
      A.Nodup ∧
      B.Nodup ∧
      (¬ ∀ x : Nat, x ∈ A ↔ x ∈ B) ∧
      (pairSums A).Perm (pairSums B) :=
  concrete_counterexample

end JSP000399
