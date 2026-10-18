---
name: explore
description: >-
  Explore an area before deciding what to change. Use when the user wants
  to understand current flows, existing primitives, or abstraction boundaries
  before implementation, or explicitly requests exploration mode. Remain
  read-only until the user explicitly authorizes leaving this mode.
---

# Explore

Help the user understand the space and decide how to get started.
Understanding is the deliverable. Implementation is a separate decision.

## Read-only boundary

While this mode is active, do not intentionally change any local or external
state. This includes small fixes, temporary experiments, and preparation for
implementation.

- Do not edit, create, delete, or format files, including notes and plans.
- Do not create branches or worktrees, or change Git state.
- Do not install dependencies, start services, or change configuration.
- Do not mutate databases, create tickets, post comments, or send messages.
- Do not run builds, tests, generators, or other commands unless you have
  verified that they will not write files or otherwise change state.
- Do not use a temporary file, scratch directory, or automatic cleanup as an
  exception to these rules.

Read existing code, documentation, tests, history, and available evidence.
Use inspection commands and tools whose relevant operations are read-only.
When an operation's side effects are uncertain, inspect how it works or
choose a safer way to answer the question.

Keep findings, proposed changes, and diagrams in the conversation. If an
investigation would require a mutation, explain the limitation and continue
with any useful read-only investigation.

## How to investigate

Start from the user's question and follow the evidence. Keep the scope
proportional to what they are trying to understand.

Understand the current flows:
- Trace representative paths from entry point to outcome.
- Explain the relevant actors, state transitions, data movement, and
  ownership.
- Identify meaningful alternate paths, failure cases, and constraints.

Understand the existing primitives:
- Find the concepts, interfaces, helpers, components, and contracts that
  already serve this area.
- Explain their responsibilities, callers, assumptions, and limitations.
- Look for existing extension points before proposing new mechanisms.

Evaluate abstraction boundaries:
- Compare the intended responsibilities with how the code is actually used.
- Look for misplaced policy, duplicated concepts, hidden coupling, and
  callers that must know too much about underlying details.
- Explain whether existing abstractions fit the problem, need a focused
  refinement, or would benefit from a different boundary.
- Support these judgments with concrete examples. Do not assume that a new
  abstraction or a refactor is necessary.

Separate observed behavior from inference and open questions. Cite relevant
files and symbols. Treat comments and documentation as evidence to check
against the implementation, not proof of current behavior.

## How to collaborate

Work toward a shared understanding rather than rushing to a solution.

Explain what exists before recommending what should change. Surface
assumptions and tradeoffs, and ask focused questions when the user's intent
would materially affect the investigation.

When useful, offer a small set of approaches, including using the current
primitives unchanged. Explain what each approach buys, what it costs, and
what evidence would help choose between them.

Do not turn every answer into an implementation plan. Match the response to
the question. A useful stopping point may be a flow explanation, a map of
existing primitives, an abstraction assessment, or the next question to
investigate.

## Leaving exploration mode

Exploration mode persists across follow-up messages and context compaction
until the user explicitly authorizes a switch.

Agreement with findings or a proposed design is not permission to implement.
Neither are discovering an obvious fix, completing an investigation, or
loading another skill.

Explicit authorization can be:

- "Exit exploration mode and implement option B."
- "Switch to implementation and make the changes we just discussed."
- An affirmative answer to a question that clearly names both the mode
  switch and the proposed implementation scope.

If the next request is ambiguous, ask whether the user wants to remain in
exploration or switch to implementation. Continue useful read-only work
while awaiting the answer.

Once the user explicitly authorizes the switch, acknowledge it and state
the agreed scope before taking action. Do not ask for redundant confirmation.
The switch does not override separate permission requirements, such as
explicit permission to modify the Git index on a local agent.

When summarizing or handing off this work, preserve the active mode, its
read-only boundary, the findings, and any unresolved questions.
