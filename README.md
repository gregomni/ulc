# ulc
An Untyped Lambda Calculus lexer/parser/evaluator/REPL in Swift, implemented as I work through 'Types and Programming Languages', by Pierce.

Definitions are defined with “:”, e.g.:

plus: λn. λm. λs.λz. m s (n s z)

Output is annotated with subscripted De Bruijn indices, e.g.:

plus := λn. λm. λs. λz. m₂ s₁ (n₃ s₁ z₀)

By default, tracing is turned on, to show all the intermediate evaluation steps. For example, with:
```
zero: λs.λz. z
inc: λn. (λs.λz. s (n s z))
one: inc zero
two: inc one
```

The output of `plus two two x y` is this big mess of stuff:

```
(λn. λm. λs. λz. m₂ s₁ (n₃ s₁ z₀)) (λs. λz. s₁ ((λs. λz. s₁ ((λs. λz. z₀) s₁ z₀)) s₁ z₀)) (λs. λz. s₁ ((λs. λz. s₁ ((λs. λz. z₀) s₁ z₀)) s₁ z₀)) x y
(λm. λs. λz. m₂ s₁ ((λs. λz. s₁ ((λs. λz. s₁ ((λs. λz. z₀) s₁ z₀)) s₁ z₀)) s₁ z₀)) (λs. λz. s₁ ((λs. λz. s₁ ((λs. λz. z₀) s₁ z₀)) s₁ z₀)) x y
(λs. λz. (λs. λz. s₁ ((λs. λz. s₁ ((λs. λz. z₀) s₁ z₀)) s₁ z₀)) s₁ ((λs. λz. s₁ ((λs. λz. s₁ ((λs. λz. z₀) s₁ z₀)) s₁ z₀)) s₁ z₀)) x y
(λz. (λs. λz. s₁ ((λs. λz. s₁ ((λs. λz. z₀) s₁ z₀)) s₁ z₀)) x ((λs. λz. s₁ ((λs. λz. s₁ ((λs. λz. z₀) s₁ z₀)) s₁ z₀)) x z₀)) y
(λs. λz. s₁ ((λs. λz. s₁ ((λs. λz. z₀) s₁ z₀)) s₁ z₀)) x ((λs. λz. s₁ ((λs. λz. s₁ ((λs. λz. z₀) s₁ z₀)) s₁ z₀)) x y)
(λz. x ((λs. λz. s₁ ((λs. λz. z₀) s₁ z₀)) x z₀)) ((λs. λz. s₁ ((λs. λz. s₁ ((λs. λz. z₀) s₁ z₀)) s₁ z₀)) x y)
x ((λs. λz. s₁ ((λs. λz. z₀) s₁ z₀)) x ((λs. λz. s₁ ((λs. λz. s₁ ((λs. λz. z₀) s₁ z₀)) s₁ z₀)) x y))
x ((λz. x ((λs. λz. z₀) x z₀)) ((λs. λz. s₁ ((λs. λz. s₁ ((λs. λz. z₀) s₁ z₀)) s₁ z₀)) x y))
x (x ((λs. λz. z₀) x ((λs. λz. s₁ ((λs. λz. s₁ ((λs. λz. z₀) s₁ z₀)) s₁ z₀)) x y)))
x (x ((λz. z₀) ((λs. λz. s₁ ((λs. λz. s₁ ((λs. λz. z₀) s₁ z₀)) s₁ z₀)) x y)))
x (x ((λs. λz. s₁ ((λs. λz. s₁ ((λs. λz. z₀) s₁ z₀)) s₁ z₀)) x y))
x (x ((λz. x ((λs. λz. s₁ ((λs. λz. z₀) s₁ z₀)) x z₀)) y))
x (x (x ((λs. λz. s₁ ((λs. λz. z₀) s₁ z₀)) x y)))
x (x (x ((λz. x ((λs. λz. z₀) x z₀)) y)))
x (x (x (x ((λs. λz. z₀) x y))))
x (x (x (x ((λz. z₀) y))))
x (x (x (x y)))
x (x (x (x y)))
```