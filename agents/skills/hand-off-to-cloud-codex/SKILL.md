---
name: hand-off-to-cloud-codex
description: >-
  Prepare a self-contained handoff and launch a new Codex Cloud coding task
  when the user asks to hand work to a cloud agent.
---

Turn the current discussion into an actionable prompt and submit it as a
new, independent Codex Cloud task.

If the user asks only for a prompt, provide the prompt without launching
anything. An explicit request to hand off or launch authorizes task
creation; do not ask for redundant confirmation.

## Prepare the handoff

Use the conversation and relevant read-only inspection to identify:

- The objective and what completion means.
- The repository, PR URL, and target branch.
- Findings, supporting evidence, and relevant files.
- Decisions already made and constraints to preserve.
- Appropriate validation.
- Whether the agent should investigate, implement, commit, push, or open
  a PR.

Write a self-contained prompt. The receiving agent does not inherit this
conversation. Distinguish verified findings from hypotheses and include
useful source links.

Carry forward existing authorization without expanding it. For example,
investigation does not imply permission to push. Do not authorize merging
unless the user requested it.

For an existing PR, use its current head branch. If a new branch is needed,
instruct the cloud agent to use the user's `sam-` prefix.

## Resolve the cloud destination

Use Codex Cloud for coding tasks. Do not substitute a local task, local
worktree, subagent, or ChatGPT Work chat.

Identify the cloud environment associated with the repository through
available tooling or a previously confirmed environment ID. Never invent
an environment ID. Ask for the missing environment only if it cannot be
determined.

Verify the installed CLI supports the required flags with
`codex cloud exec --help`.

## Launch

Submit the prepared prompt using:

`codex cloud exec --env ENV_ID --branch BRANCH PROMPT`

Pass the full prompt as one argument. Prefer a subprocess argument array
to constructing shell commands containing multiline prompts.

Preserve the local checkout. Do not switch branches, edit files, apply
cloud diffs, or commit and push local work as part of this handoff.
Temporary files, if needed, belong outside the repository.

Cloud work starts from remote repository state. If essential work exists
only locally, explain what is missing and obtain direction before
publishing it or launching an incomplete handoff.

Submit one task. If submission has an ambiguous outcome, inspect recent
cloud tasks before retrying to avoid duplicates. If submission fails,
report the error and provide the prepared prompt as a fallback.

## Report

Return the task URL or identifier, repository and branch, and a concise
summary of the assignment. Report success only after the CLI confirms
creation.

Do not wait for completion or set up monitoring unless requested.
