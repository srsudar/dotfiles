---
name: cr
description: Launch an independent agent to do a comprehensive code review of the top commit
argument-hint: [optional context about what the change does]
---
# Code Review
Launch a fresh agent with no prior context to independently review the HEAD commit.
## How it works
1. Determine context for the review:
   - If the user provided an argument, use it as the description of what the change does
   - If no argument, infer the purpose from the commit message and diff
2. Launch an Agent with `subagent_type: general-purpose`. The agent prompt must include:
   - The description of the goal (but NOT how it's implemented or any issues you know about)
   - Instructions to run `git show HEAD` to see the full diff
   - Instructions to read any changed files in full for context
   - A thorough review covering correctness, bugs, edge cases, security, test coverage, code quality, and anything else that stands out
   - Instructions to number each issue clearly with file path and line number
   - Instructions to tag each issue with a severity: `critical`, `high`,
     `medium`, `low`, or `nit`. Use the tag inline at the start of the issue
     (e.g. `1. [high] api/foo.ts:42 — ...`).
   - Instructions to order issues by severity, most critical first
     (`critical` → `high` → `medium` → `low` → `nit`). Numbering follows that
     order, so issue 1 is the highest-severity item.
   - Instructions to be honest and rigorous, reporting every actionable issue
     found no matter how small
   - **Report only actionable issues.** An actionable issue is one where the
     reviewer wants something to change: a fix, a follow-up investigation, a
     clarifying question, a missing test, a renamed identifier, etc. Vague
     actions like "investigate whether Y still holds" count. If the reviewer
     can't state any concrete action they want, it's not actionable — drop it.
   - **No non-issues.** Do NOT include reassurances, confirmations, or "things
     I checked that were OK". Phrases like "this is fine", "this still
     works", "no concerns", "looks correct", "considered X and it's not a
     problem", "verified that Y", or "good use of Z" indicate a non-issue —
     omit those entries entirely. No "things I checked" appendix, no
     "positive observations" section, no overall verdict. Every numbered
     entry in the output must be something the user is expected to act on.
   - A nudge to prefer the simplest shell command that gets the job done. If a
     plain command works, use it instead of chaining, piping, or wrapping it in
     extra flags — chained/complex invocations sometimes trigger fresh
     permission prompts even when each individual command is already allowed.
3. When the agent returns, first print a brief summary in your own text
   output (the reviewer's full report is not visible in the Claude Code UI,
   so the user needs this overview). The summary must include:
   - Total issue count
   - Counts grouped by severity (e.g. `2 critical, 3 high, 5 medium, 1 low, 4 nit`)
   - Keep it to 1-2 lines — no per-issue details, no preamble
4. Then present each issue one by one. For each issue:
   - State the issue as the agent reported it
   - Give your own analysis of whether the issue is real or not, with reasoning
   - If real, suggest a fix (with an Edit if appropriate)
   - IMPORTANT: Wait for the user to confirm before moving to the next issue
