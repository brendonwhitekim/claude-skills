---
name: search-first
description: Use when a task depends on external docs, APIs, SDKs, libraries, services, product behavior, or current facts and you should verify the important details before coding or making a recommendation.
---

# Search First

Use this skill when guessing would be risky and the task depends on outside facts.

## Goals

- Verify the important facts before coding
- Prefer official docs and primary sources
- Keep research focused so tools do not crowd the context window

## Workflow

1. List the exact facts that need verification.
2. Start with the most trusted source, usually official docs or the primary API reference.
3. Use only the MCPs or web tools needed for this task.
4. Pull back the exact setup, option, behavior, limit, or version detail that matters.
5. Separate source-backed facts from your own inference.
6. Summarize the verified facts in plain language before coding or recommending a change.

## Good Triggers

- API details are unclear
- SDK behavior may have changed
- Library or framework setup is version-sensitive
- The user asked for the latest or current behavior
- A wrong guess could waste time or break the build
