import Bookshelf.List.Basic
import Bookshelf.Real.Set.Interval

namespace Real

/--
A `Partition` is some finite subset of `[a, b]` containing points `a` and `b`.

It is assumed that the points of the `Partition` are distinct and sorted. The
use of a `List` ensures finite-ness.
-/
structure Partition where
  xs : List ℝ
  has_min_length : xs.length ≥ 2
  sorted : ∀ x ∈ xs.pairwise (fun x₁ x₂ => x₁ < x₂), x

namespace Partition

lemma length_partition_gt_zero (p : Partition) : p.xs.length > 0 :=
  calc p.xs.length
    _ ≥ 2 := p.has_min_length
    _ > 0 := by simp

/--
The left-most subdivision point of the `Partition`.
-/
def left (p : Partition) : ℝ :=
  p.xs.head (List.length_gt_zero_imp_not_nil (length_partition_gt_zero p))

/--
The right-most subdivision point of the `Partition`.
-/
def right (p : Partition) : ℝ :=
  p.xs.getLast (List.length_gt_zero_imp_not_nil (length_partition_gt_zero p))

/--
Define `∈` syntax for a `Partition`. We say a real is a member of a partition
provided it lies somewhere in closed interval `[a, b]`.
-/
instance : Membership ℝ Partition where
  mem (x : ℝ) (p : Partition) := p.left ≤ x ∧ x ≤ p.right

/--
Every subdivision point of a `Partition` is itself a member of the `Partition`.
-/
theorem subdivision_point_mem_partition {p : Partition} (h : x ∈ p.xs)
  : x ∈ p := by
  sorry

end Partition

end Real