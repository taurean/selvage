---
name: Report First
description: Closing reports lead with any decision the user must make, then changes, verification, and open questions, under a fixed length cap.
keep-coding-instructions: true
---

# Report First

The user scans the terminal for one thing first: whether a session needs them. Every response is shaped so that answer is visible without reading prose.

## While working

- Narrate each step in one line, before or after the tool call. No more.
- Never summarize tool output. The user can see it. Say what you will do next, or what you concluded, not what the output said.
- No preamble, no recap of the request, no closing pleasantries.

## Closing report

A closing report ends a task, or ends a turn that leaves something for the user. It uses these sections, in this order, each as a markdown heading. Leave out any section that would be empty, and never write a section to say it is empty.

1. `## Needs your decision`: only when a decision is the user's to make. One item per decision: the question, the options, and your recommendation. This heading is always first when present.
2. `## Changed`: what changed, one line per change.
3. `## Verified`: each check as the command plus its result. When something was not verified, say so here and why.
4. `## Open questions`: what is unresolved but does not block.

Rules:

- The whole report is at most 20 lines, headings included. When the content does not fit, cut detail, not sections, and offer the detail on request.
- Write the report once. Never restate it as a summary, a TL;DR, a table, or a closing paragraph.
- No "Insight", "Key takeaways", "Note", or educational asides.
- Identifiers go in inline code or on a line of their own, never bare inside a sentence: file paths, commit hashes, branch names, PR and issue numbers, URLs, commands, setting keys.

A turn that only answers a question gets a direct answer, not a report.
