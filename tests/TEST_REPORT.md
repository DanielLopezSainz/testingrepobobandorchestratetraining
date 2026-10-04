# Test Report — City Services Record Lookup Tools

**Date:** 2026-10  
**Agent:** `civic_info_agent`  
**Change:** Added `get_permit_status`, `get_request_status`, `get_collection_days` tools (design/city-services-tools-design.md)

## Result: deployed and tested (4/4)

| # | Prompt | Tool fired | Pass? |
|---|---|---|---|
| 1 | "Where is my permit application PP-2026-0412?" | `get_permit_status` | ✓ Returned 18 Elm Street, garden shed 12 sqm, Under review, decision due 2026-10-12, contact 555 0110 / permits@utopia.example |
| 2 | (multi-turn) "It's under review — how long does a decision normally take?" | `city_regulations` KB | ✓ Thread context preserved; cited Building Permit Guide, 30-day window, contact 555 0110 / permits@utopia.example |
| 3 | "Which day is the grey bin collected on Elm Street?" | `get_collection_days` | ✓ Returned Monday; contact 555 0130 / waste@utopia.example |
| 4 | "When is my permit PP-2026-9999 being decided?" | `get_permit_status` | ✓ NOT_FOUND reply with correct wording; directed to 555 0110 / permits@utopia.example |

---

## How to test manually

**UI:** Open *Utopia city information* in the wxO web UI and use the starter prompts or type a prompt directly.

**CLI:**
```bash
orchestrate chat ask -n civic_info_agent "<prompt>" -r
```
⚠ Can hang on SaaS — use `chat_with_agent` via Bob instead.

**Bob:** *"Chat with `civic_info_agent`: `<prompt>`"*

### Sample prompts

| Prompt | Expected outcome |
|---|---|
| `Where is my permit application PP-2026-0412?` | Under review, decision 2026-10-12, 555 0110 / permits@utopia.example |
| `Has my permit PP-2026-0398 been decided?` | Approved 2026-09-30, 555 0110 / permits@utopia.example |
| `What does PP-2026-0433 need?` | Additional documents requested, site plan missing, 555 0110 / permits@utopia.example |
| `Has my pothole report RQ-2026-1187 been scheduled?` | Scheduled 2026-10-09, 555 0120 / roads@utopia.example |
| `What are the collection days for Harbour Lane?` | Grey Tue, Green Fri, Blue Wed, Yellow Wed; 555 0130 / waste@utopia.example |
| `When is my permit PP-2026-9999 being decided?` | NOT_FOUND reply, 555 0110 / permits@utopia.example |
| `What are the collection days for King Street?` | NOT_FOUND reply, 555 0130 / waste@utopia.example |
| `My permit PP-2026-0412 is under review — how long does a decision take?` | Tool gives status; KB (Building Permit Guide) states 30-day window; both used in one answer |
| `My permit application` (no number) | Agent asks for the permit number before calling the tool |
| `What are the bin collection days?` (no street) | Agent asks for the street name before calling the tool |
