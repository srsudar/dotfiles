---
name: cr
description: Launch an independent agent to do a comprehensive code review of
this branch compared to the most recent parent commit on master.
argument-hint: [optional context about what the change does]
---
# Code Review

Launch a fresh agent with no prior context to independently review the HEAD
commit.

## How it works
1. Determine context for the review:
   - Try to see if a pull request exists for this PR, and consider the
   description using this command: `gh pr view --json body --jq '.body'`. If
   `gh` isn't installed, offer to install it first.
   - If the user provided an argument, use it as the description of what the
   change does
   - If no argument, infer the purpose from the commit message and diff
2. Launch an Agent with `subagent_type: general-purpose`. The agent prompt must
   include:
   - The description of the goal (but NOT how it's implemented or any issues you
   know about)
   - Instructions to run `git diff master...HEAD` to see the full diff
   - Instructions to read any changed files in full for context
   - A thorough review covering correctness, bugs, edge cases, security, test
   coverage, code quality, and anything else that stands out
   - Instructions to number each issue clearly, with a relative priority, and to
   include file path and line number
   - Instructions to be honest and rigorous, reporting every issue found no
   matter how small
3. When the agent returns, provide an overall summary of the PR. Then present
   each issue one by one. For each issue:
   - State the total number of issues with their priority
   - State the issue as the agent reported it
   - Give your own analysis of whether the issue is real or not, with reasoning
   - If real, suggest a fix (with an Edit if appropriate)
   - Wait for the user to confirm before moving to the next issue
