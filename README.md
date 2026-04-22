# Claude Global Skills

A collection of **4 reusable Claude AI skills** for automation, research, goal setting, and productivity.

## What's Inside

### 🔍 search-first
Research external facts before coding on APIs, libraries, or current information. Verifies details from official sources.

### 📊 smart-goals
Transform vague tasks into SMART goals (Specific, Measurable, Achievable, Relevant, Time-bound). Includes Notion integration.

### 🗂️ notion-cleaner
Bulk clean Notion backlogs using parallel agents to rewrite vague titles into SMART goals. Preserves original values.

### 🛠️ skill-creator
Build new Claude skills, run evaluations, measure performance, and optimize skill instructions iteratively.

---

## How to Use

1. **Copy a skill** into your `.claude/skills/` directory
2. **Invoke it** with `/skill-name` in Claude Code
3. **Read the SKILL.md** for detailed instructions

## Structure

Each skill includes:
- `SKILL.md` — Complete instructions and behavior
- `references/` — Supporting docs, playbooks, examples
- `evals/` — Evaluation criteria (where applicable)

## Quick Reference

| Skill | Use Case | Key File |
|-------|----------|----------|
| search-first | Verify external facts before implementation | search-first/SKILL.md |
| smart-goals | Turn rough tasks into measurable goals | smart-goals/SKILL.md |
| notion-cleaner | Bulk rewrite Notion backlogs | notion-cleaner/SKILL.md |
| skill-creator | Build and optimize custom skills | skill-creator/SKILL.md |

---

**Author:** Brendon Kim  
**Updated:** 2026-04-22
