---
name: notion-cleaner
description: Cleans Notion backlog tasks by rewriting vague titles into SMART goals, preserving originals in Previous Title/Previous Notes, and filling all required fields. Uses parallel Haiku sub-agents for speed. Requires Notion API token and Backlog DB ID.
---

# Notion Cleaner Skill

## What This Skill Actually Does

You will **execute real Notion API calls** to clean tasks. This is NOT documentation — you must run curl commands against the Notion API and verify the results. Do not just describe what the skill would do.

## Credentials

Set these environment variables or pass them as arguments:
- **Token**: `YOUR_NOTION_API_TOKEN` (generate at https://www.notion.so/my-integrations)
- **Backlog DB**: `YOUR_NOTION_DATABASE_ID`
- **API version header**: `Notion-Version: 2022-06-28`

## Execution Flow (Follow Exactly)

### Step 1: Query the view
```bash
curl -s -X POST 'https://api.notion.com/v1/databases/YOUR_NOTION_DATABASE_ID/query' \
  -H 'Authorization: Bearer YOUR_NOTION_API_TOKEN' \
  -H 'Notion-Version: 2022-06-28' \
  -H 'Content-Type: application/json' \
  -d '{"page_size": 100}' > /tmp/backlog.json
```

### Step 2: Identify tasks needing cleaning

A task needs cleaning if ANY of these are true:
- **Previous Title is empty** (never been SMART-cleaned)
- **Category is empty**
- **1 week category is empty**
- **1 week goal Category is empty**

Skip tasks where `Completed Date` is set.

Capture for each task that needs cleaning: `id`, current `title`, current `notes` (both needed to back up originals).

### Step 3: Split into batches and run parallel Haiku sub-agents

For speed, split into batches of 6–10 tasks and spawn parallel sub-agents (use `model: "haiku"` and `run_in_background: true`). Each sub-agent handles one batch of tasks sequentially.

Save each batch as `/tmp/batch_N.json` so sub-agents can read their assigned slice.

### Step 4: For EACH task, PATCH these fields

**CRITICAL ORDERING** — the Previous fields must be set to the CURRENT value BEFORE the main field is rewritten. Do both writes in the same PATCH call.

| Field | Value |
|-------|-------|
| `Title` (title) | NEW SMART title with deadline (e.g., "by 2026-04-25") |
| `Previous Title` (rich_text) | EXACT original title |
| `Notes` (rich_text) | NEW SMART summary with measurable steps |
| `Previous Notes` (rich_text) | EXACT original notes (empty string if original was empty) |
| `Category` (multi_select) | ONE existing option — see schema below |
| `Urgency` (multi_select) | ONE of "1","2","3","4","5" |
| `Impact` (multi_select) | ONE of "1","2","3","4","5" |
| `1 week goal Category` (multi_select) | ONE existing option |
| `1 week category` (multi_select) | ONE existing option (SEPARATE from goal Category) |
| `Kitchen timer` (rich_text) | Time estimate like "90 minutes" |
| `Deadline` (date) | Near-term date like "2026-04-25" |
| `Added Date` (date) | Today's date |

**NEVER MODIFY**: `Actual Time`, `Completed Date`, `Created Date`.

### Step 5: PATCH command template

```bash
curl -s -X PATCH "https://api.notion.com/v1/pages/{PAGE_ID}" \
  -H "Authorization: Bearer YOUR_NOTION_API_TOKEN" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  -d '{
    "properties": {
      "Title": {"title":[{"type":"text","text":{"content":"NEW SMART TITLE"}}]},
      "Previous Title": {"rich_text":[{"type":"text","text":{"content":"ORIGINAL TITLE"}}]},
      "Notes": {"rich_text":[{"type":"text","text":{"content":"SMART NOTES"}}]},
      "Previous Notes": {"rich_text":[{"type":"text","text":{"content":"ORIGINAL NOTES"}}]},
      "Category": {"multi_select":[{"name":"Learning"}]},
      "Urgency": {"multi_select":[{"name":"3"}]},
      "Impact": {"multi_select":[{"name":"4"}]},
      "1 week goal Category": {"multi_select":[{"name":"N/A"}]},
      "1 week category": {"multi_select":[{"name":"N/A"}]},
      "Kitchen timer": {"rich_text":[{"type":"text","text":{"content":"90 minutes"}}]},
      "Deadline": {"date":{"start":"2026-04-25"}},
      "Added Date": {"date":{"start":"2026-04-18"}}
    }
  }'
```

After each PATCH, check response for `"object": "error"`. If found, report the message.

### Step 6: Final audit (MANDATORY)

After all batches complete, re-query the database and verify every active task has:
- Non-empty Previous Title
- Non-empty Category
- Non-empty 1 week category AND 1 week goal Category

Fix any stragglers directly (no sub-agent needed for <5 tasks).

Also check for **duplicate SMART titles** across pages — sub-agents occasionally reuse the same title for different tasks. If found, rewrite one of them based on its actual Previous Title.

## Valid Field Values (Existing Only — Never Invent New)

### Category (multi_select)
- Learning
- Whitekim (Side Hustle 10k)
- Job 120k Remote
- School Straight A's
- Personal Admin
- Fitness (6 pack and trainer)
- BNSF Work
- Health & Fitness

### Urgency / Impact (multi_select)
- "1", "2", "3", "4", "5"

### 1 week goal Category (multi_select)
- Minor Work Items Completed
- Cold email OS finished
- N/A
- Gen Ai UI
- Move into house seamlessly
- Have Advanced Claude Code set up in each project (For Learning and Up to date)
- Sign 5 Clients Automated from Cold Email OS

### 1 week category (multi_select)
- Accoutnability OS In place
- Move into house seamlessly
- N/A
- Have Advanced Claude Code set up in each project (For Learning and Up to date)
- Cold email OS finished
- Sign 5 Clients Automated from Cold Email OS

## Category Matching Rules

| Task keyword | Category | 1 week goal | 1 week category |
|--------------|----------|-------------|-----------------|
| cold email / clients / Whitekim / Instantly | Whitekim (Side Hustle 10k) | Sign 5 Clients... or Cold email OS finished | Sign 5 Clients... or Cold email OS finished |
| Claude Code / agent / MCP / AI dev | Learning | Have Advanced Claude Code... or Gen Ai UI | Have Advanced Claude Code... |
| BNSF / work tasks | BNSF Work | Minor Work Items Completed | N/A |
| room / house / move / organize | Personal Admin | Move into house seamlessly | Move into house seamlessly |
| routine / schedule / habit / accountability | Personal Admin | Minor Work Items Completed | Accoutnability OS In place |
| workout / gym / diet / calories | Health & Fitness | Minor Work Items Completed | N/A |
| small admin / groceries / haircut | Personal Admin | Minor Work Items Completed | N/A |
| Doesn't fit | (best guess) | N/A | N/A |

## Sub-Agent Prompt Template

When spawning Haiku sub-agents for a batch, give them this exact structure:

```
You are cleaning Notion backlog tasks. Today is {TODAY}.

Token: YOUR_NOTION_API_TOKEN
Batch file: /tmp/batch_{N}.json (JSON array with id, title, notes per task)

For EACH task, PATCH https://api.notion.com/v1/pages/{id} with these properties:
1. Title — SMART rewrite with deadline
2. Previous Title — EXACT original title from JSON
3. Notes — SMART version (transform original if non-empty, else summary from title)
4. Previous Notes — EXACT original notes from JSON (empty string if original was empty)
5. Category — one of [list]
6. Urgency — "1"–"5"
7. Impact — "1"–"5"
8. 1 week goal Category — one of [list]
9. 1 week category — one of [list]
10. Kitchen timer — "60 minutes" etc.
11. Deadline — near-term date
12. Added Date — today

CRITICAL: Previous Notes MUST be set even when original notes had content — otherwise the original is lost when Notes is overwritten. Use EXISTING option values only. Do not reuse the same SMART title across different tasks. Check each response for "object": "error".

Report succeeded/failed count under 150 words.
```

## Common Failure Modes (Watch For)

1. **Notes lost**: Sub-agent writes SMART Notes but forgets to copy original to Previous Notes. Audit: any task where `Notes` is non-empty and `Previous Notes` is empty AND `Previous Title` shows the original had real notes.
2. **Weekly fields missed**: Only `1 week goal Category` filled, not `1 week category` (or vice versa). They are TWO separate fields.
3. **Duplicate titles**: Two different tasks end up with identical SMART titles because sub-agent reused a template. Always tie the SMART title to the specific Previous Title content.
4. **Skipped tasks**: Task has a Category but empty Previous Title — it wasn't actually cleaned, just manually categorized by the user. Still needs full cleanup.
5. **Invented options**: Sub-agent uses "Accountability OS In place" instead of the actual (misspelled) `Accoutnability OS In place`. Typos in the schema must be preserved exactly.

## Final Verification Script

```python
python3 -c "
import json
data = json.load(open('/tmp/audit.json'))
for r in data.get('results', []):
    p = r['properties']
    if p.get('Completed Date',{}).get('date'): continue
    prev_title = ''.join(x.get('plain_text','') for x in p.get('Previous Title',{}).get('rich_text',[]))
    cat = p.get('Category',{}).get('multi_select',[])
    wk = p.get('1 week category',{}).get('multi_select',[])
    wg = p.get('1 week goal Category',{}).get('multi_select',[])
    if not (prev_title and cat and wk and wg):
        title = ''.join(x.get('plain_text','') for x in p.get('Title',{}).get('title',[]))
        print(f'INCOMPLETE: {r[\"id\"]} | {title[:60]}')
"
```

Run this after cleanup. Zero output = success.
