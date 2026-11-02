# General Guidelines

* Always prefix branches you create with sam-. Do not derive the prefix from my
  GitHub username.

* When you are creating new markdown files or new code comments, always wrap at
  80 characters. If you are modifying an existing file, do not rewrap globally
  unless we are editing that section. I want new files to be correct, but I
  don't want to make huge diffs unnecessarily. Do NOT apply this to PR
  descriptions, where 80 char wrapping looks weird.

* I like to have explicit control of when we begin working on something. I ask a
  lot of questions and I frequently don't want you to get started editing right
  away. If I end in a question, assume that I want you to answer it, not start
  editing. If you aren't sure, please ask me if I want you to get started.

* NEVER modify the git index on a local agent unless I give you explicit
  permission to do so. Ask me for permission if you feel you need to modify the
  git index to accomplish the task. In cloud agents it is fine for you to
  control git.

* Treat function bodies as short logical paragraphs.

  - Separate setup, execution, result processing, reporting, and
    error handling with one blank line.
  - Put a blank line before and after significant awaited calls,
    including `const result = await ...`, and reporting calls.
    Omit padding directly next to an opening or closing brace.
  - Keep closely related declarations and assignments together.
  - Before finishing, inspect the diff for logical spacing.
    Passing the formatter does not replace this review.

## TypeScript Guidelines

* When working in typescript, always include explicit return types and
  parameters on functions that you generate. Only skip this if it makes the code
  much more complicated or unidiomatic for some reason, or if I tell you to do
  so.

* When working in typescript, always prefer object parameters on new functions
  Eg prefer `foo({ pubId }: { pubId: number })` instead of `foo(pubId: number)`,
  unless there is a strong reason to avoid it or if I explicitly tell you
  otherwise. I think this is easier for humans to read and makes usage errors
  more obvious.

* When working in typescript, prefer required, nullable parameters in functions
  rather than optional parameters. Eg prefer `foo({ arg }: { arg: string | null
  })` rather than `foo({ arg }: { arg?: string | null })`, unless there is a
  strong reason to avoid it or if I explicitly tell you otherwise. I think this
  is good for callers because it makes it harder to forget valuable but
  technically optional parameters.

* When I ask you to leave a comment on a function, assume that it is a javadoc
  style comment, beginning with `/**`, text on subsequent lines, ending in `*/`
  on its own line. Do not include parameter annotations as part of these
  comments unless it is the convention of the repo or if I tell you to do so.

* When adding imports, separate type and value imports. Eg prefer to separate
  lines, `import type { Foo } from 'foo'; import { Foo2 } from 'foo';`, rather
  than `import { type Foo, Foo2 } from 'foo';`. Only do this for imports that
  you are adding--don't change imports that aren't relevant to the diff unless I
  advise you otherwise.
