# GLOSSARY.md format

`GLOSSARY.md` is the project's canonical language, so human and agent can be
precise with terms. Once a term is here, use it everywhere — code, docs,
conversation — and treat departures from it as bugs.

## Structure

```md
# {Project} Glossary

{One or two sentences on the domain this glossary covers.}

**Order**:
A customer's request to purchase one or more items. Produces one or more
**Invoices**.
_Avoid_: purchase, transaction

**Invoice**:
A request for payment, generated when a **Fulfillment** is confirmed — its
lifecycle is tied to fulfillment, not to the **Order**.
_Avoid_: bill, payment request
```

## Rules

- **Be opinionated.** When several words exist for one concept, pick the best
  and list the rest under `_Avoid_`. This is how language compresses.
- **Definitions are one or two sentences** and say what the term IS, not what
  it does or how to use it.
- **Domain terms only.** General programming concepts (array, endpoint,
  timeout) stay out unless they carry project-specific meaning.
- **Use glossary terms inside other definitions**, bolded. Relationships and
  cardinality live there too ("belongs to exactly one **Customer**") — no
  separate relationships section unless the web of terms genuinely needs one.
- **Resolve ambiguity in place.** When a term is used loosely in the field or
  the codebase, the definition states the resolution: "In this project, 'set'
  always means a working set — warm-ups are tracked separately."
- **Group under subheadings when clusters emerge**; a flat list is fine when
  terms cohere.
- **Revise in place as understanding deepens.** A wrong definition is worse
  than a missing one.
