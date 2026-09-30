# CONTEXT.md format

`CONTEXT.md` holds what a competent newcomer would get wrong: non-obvious
constraints, caveats, and decisions unique to the project. Anything derivable
from reading the code stays out.

## Structure

```md
# {Project} — Context

Non-obvious constraints, caveats, and decisions. Anything derivable from
reading the code is not repeated here.

---

## {System or concern, e.g. "Deployment", "Secrets"}

**The load-bearing fact, bolded, as the first sentence.** Then why it is
true, and what to do about it. A few sentences; code blocks for exact
commands.

**Symptom:** the observable failure, as the person hitting it would describe
it. Then the fix — the check to run or the command to paste.
```

## Rules

- **Project-unique only.** How git works in general doesn't belong; how _this
  project_ uses git in a way that bites does.
- **Lead with the fact, follow with the why.** The why is what stops a future
  reader from "fixing" something deliberate.
- **Use the Symptom / Fix pattern for recurring traps.** A reader arrives here
  holding an error, not a concept — let them match on the error.
- **Group by system or concern**, one `##` per group. No fixed section list;
  sections exist because entries do.
- **Delete entries that go stale or become derivable.** A context doc that
  contains one wrong fact loses trust for all of them.
