---
name: smart-goals
description: Transforms vague Notion tasks into SMART goals using your Notion token. Database IDs: Daily=278b13b5..., Weekly=2ffb13b5..., Backlog=278b13b5..., 2Week=1ddb13b5..., LongTerm=1ddb13b5...
---

# Smart Goals Skill

## Overview
Transforms vague task items from your Notion tables into clear, deliverable SMART goals. Uses your Notion Integration Token to query databases and includes reference IDs for easy navigation back to original pages.

## Prerequisites
- **Notion Integration Token** must be configured in project settings
- Valid database IDs for your goal/task databases

## How to Use
```
/smart-goals [source]
```

**Parameters:**
- `weekly` - Weekly goals table (default)
- `daily` - Daily items table
- `backlog` - Backlog items
- `longterm` - Long-term goals
- `twoweek` - 2-week goals
- `past` - Past goal databases (for analysis)
- `notion:<DB_ID>` - Any Notion database by ID
- Leave blank for weekly goals

**Examples:**
```
/smart-goals weekly
/smart-goals daily
/smart-goals notion:278b13b5-a41c-8037-a8c3-ce0a1d5e6a7c
```

## SMART Goal Framework
Each task is transformed using:
- **Specific**: What exactly needs to be done
- **Measurable**: How you'll know it's done
- **Achievable**: Realistic scope
- **Relevant**: Why it matters
- **Time-bound**: When it's due

## Your Configured Databases
The skill uses these Notion database IDs:
- **Daily Tasks:** `278b13b5-a41c-8037-a8c3-ce0a1d5e6a7c`
- **Weekly Tasks:** `2ffb13b5-a41c-8081-ac04-f52d3eddeb9d`
- **Backlog:** `278b13b5-a41c-809a-9de6-c73bee00e484`
- **2-Week Goals:** `1ddb13b5-a41c-80be-af9e-ce49b302487d`
- **Long-Term Goals:** `1ddb13b5-a41c-80f7-bf08-d0f287740b84`
- **Past Major Goals:** `2a1b13b5-a41c-80ad-8e33-ec1e51f483d6`
- **Past 2-Week Goals:** `2a1b13b5-a41c-80eb-beff-e8db7cf4abb4`
- **Past 1-Week Goals:** `2fcb13b5-a41c-80ae-9bee-d8f5b1dc57d3`
- **Past Daily Tasks:** `336b13b5-a41c-8097-bb09-c0ce73ccc5bc`

## Examples

### Example 1: Weekly Goal
**Input:** "80/20 of the finance accountability application"
**Output:** "Create prioritized backlog for finance accountability app - identify top 20% features that drive 80% of user value by Friday 5pm"
**Reference ID:** `278b13b5-a41c-8037-a8c3-ce0a1d5e6a7c`

### Example 2: Daily Item
**Input:** "Work on mobile optimization"
**Output:** "Redesign dashboard for mobile - create wireframes for 3 key screens and implement responsive layout by next Monday"
**Reference ID:** `2ffb13b5-a41c-8081-ac04-f52d3eddeb9d`

### Example 3: Long-Term Goal
**Input:** "Improve fitness"
**Output:** "Increase weekly gym sessions from 2 to 4 times per week with tracked progress, maintaining <20% body fat by December 31"
**Reference ID:** `1ddb13b5-a41c-80be-af9e-ce49b302487d`

### Example 4: Custom Notion Database
**Input:** `/smart-goals notion:278b13b5-a41c-8037-a8c3-ce0a1d5e6a7c`
**Process:** Queries the specified Notion database and transforms all items

## Read-Only Behavior
This skill is **read-only** - it only shows transformed goals. Your Notion data is never modified. Reference IDs are provided so you can easily navigate back to the original pages.

## Output Format
```
┌───────────────────────────────────────────────────────────────────┐
│ Source: Weekly Goals (Database: 2ffb13b5-a41c-8081...)            │
├───────────────────────────────────────────────────────────────────┤
│ Task 1: [Original]                                                │
│ Transformed: [SMART goal]                                         │
│ Reference ID: 2ffb13b5-a41c-8081-ac04-f52d3eddeb9d               │
├───────────────────────────────────────────────────────────────────┤
│ Task 2: [Original]                                                │
│ Transformed: [SMART goal]                                         │
│ Reference ID: 1ddb13b5-a41c-80be-af9e-ce49b302487d               │
└───────────────────────────────────────────────────────────────────┘
```

## Common Vague Terms to Replace
| Vague | SMART Pattern |
|-------|---------------|
| "work on" | "Complete [deliverable] by [date]" |
| "improve" | "Increase [metric] from X to Y by [date]" |
| "optimize" | "Reduce [pain point] by X%" |
| "finish" | "Deliver [item] with [criteria]" |
| "look into" | "Research [topic] and present by [date]" |
| "update" | "Update [specific component] to [new state] by [date]" |

## Getting Notion Database IDs

To use a specific Notion database:
1. Open your Notion database in a browser
2. The URL will look like: `https://www.notion.so/workspace/database-name?v=...`
3. Copy the 32-character ID from the URL or the "Share" menu
4. Use it with the skill: `/smart-goals notion:YOUR-DATABASE-ID`

The skill can work with ANY Notion database that contains task items, not just the pre-configured ones.
