# bookshelf

A collection on the study of the books listed below. I aim to use [Lean](https://leanprover.github.io/)
when possible (with respect to my current level of ability) and fallback to
LaTeX when not.

- [ ] Apostol, Tom M. Calculus, Vol. 1: One-Variable Calculus, with an Introduction to Linear Algebra. 2nd ed. Vol. 1. 2 vols. Wiley, 1991.
- [x] Avigad, Jeremy. ‘Theorem Proving in Lean’, n.d.
- [ ] Axler, Sheldon. Linear Algebra Done Right. Undergraduate Texts in Mathematics. Cham: Springer International Publishing, 2015.
- [ ] Cormen, Thomas H., Charles E. Leiserson, Ronald L. Rivest, and Clifford Stein. Introduction to Algorithms. 3rd ed. Cambridge, Mass: MIT Press, 2009.
- [ ] Enderton, Herbert B. A Mathematical Introduction to Logic. 2nd ed. San Diego: Harcourt/Academic Press, 2001.
- [ ] Gries, David. The Science of Programming. Texts and Monographs in Computer Science. New York: Springer-Verlag, 1981.
- [ ] Gustedt, Jens. Modern C. Shelter Island, NY: Manning Publications Co, 2020.
- [ ] Ross, Sheldon. A First Course in Probability Theory. 8th ed. Pearson Prentice Hall, n.d.
- [ ] Smullyan, Raymond M. To Mock a Mockingbird: And Other Logic Puzzles Including an Amazing Adventure in Combinatory Logic. Oxford: Oxford university press, 2000.

## Documentation

To generate Lean documentation, we use [doc-gen4](https://github.com/leanprover/doc-gen4).
Run the following to build and serve this:

```bash
> lake build Bookshelf:docs
> lake run doc-server
```

This assumes you have `python3` available in your `$PATH`. To change how the
server behaves, refer to the `.env` file located in the root directory of this
project. To also serve the corresponding LaTeX files scattered throughout this
project, first install the following:

- `tex4ht`
- `make4ht`
- `luaxml`

Afterward, you can generate the necessary HTML via:

```bash
> find . -name '*.tex' | grep -v preamble | xargs -n 1 make4ht -e build.mk4
```
