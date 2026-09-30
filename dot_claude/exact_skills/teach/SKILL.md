---
name: teach
description: >
  Run a multi-session teaching workspace: lessons grounded in the user's
  mission, progress tracked in learning records, knowledge taught through cited
  interactive HTML explainers and feedback-loop exercises. User-invoked when
  they want to learn a topic over time.
disable-model-invocation: true
---

# Teach

Treat the current directory as a teaching workspace for one topic, learned over
multiple sessions. Its state lives in four places:

- `MISSION.md` — _why_ the user wants to learn this; grounds every session.
  Format: [MISSION-FORMAT.md](MISSION-FORMAT.md).
- `GLOSSARY.md` — the workspace's terminology; every other file adheres to it.
  Format: [GLOSSARY-FORMAT.md](GLOSSARY-FORMAT.md).
- `RESOURCES.md` — vetted sources that ground the teaching. Format:
  [RESOURCES-FORMAT.md](RESOURCES-FORMAT.md).
- `learning-records/*.md` — the ADRs of learning: non-obvious lessons and key
  insights that may be revised later and drive future sessions. Titled
  `0001-<dash-case-name>.md`, number incrementing. Format:
  [LEARNING-RECORD-FORMAT.md](LEARNING-RECORD-FORMAT.md).

## Mission first

Tie every session to the mission. If `MISSION.md` is unpopulated or the user
seems unclear on why they're learning this, interview them before teaching
anything: without the mission, knowledge has no real-world ground, exercises
drift abstract, and there is no basis for judging what comes next.

## Pick what to teach

Aim for the zone of proximal development — challenged just enough, scope tight,
directly tied to the mission. When the user names the thing, teach that.
Otherwise derive it: read the learning records, and pick the most
mission-relevant thing just beyond what they've recorded. When the user says
they already know a topic, capture that in a learning record and move on.

## Teaching moves

Deep learning runs on three inputs. Lead with whichever the topic demands —
theoretical physics is knowledge-heavy, yoga is skills-heavy — and use
knowledge-then-skills as the usual one-two: teach the material, then have them
practice it.

**Knowledge** comes from high-quality, high-trust resources — never from
parametric memory. Search for and read the actual sources; what you remember
about a topic is not grounding, and the difference matters most exactly where
you feel most confident. Until `RESOURCES.md` is well populated, finding those
sources _is_ the session.

Teach knowledge through HTML explainers: grounded in the resources and littered
with citations, adhering to the glossary, interactive where possible ("try
this" callouts), beautiful, saved to the workspace for later review, and
openable with a single command handed to the user. Answer follow-up questions
directly, and amend the explainer — or write another — when a question exposes a
gap.

**Skills** come from exercises devised from the knowledge: quizzes and light
in-browser exercises inside explainers, guided real-world step lists (yoga
poses, say), or in-agent scenario quizzes. Every exercise needs a feedback loop,
as tight as possible — immediate beats end-of-session.

**Wisdom** comes from practicing outside the learning environment. When a
question needs wisdom, attempt an answer, then delegate to a community — a
high-reputation forum, subreddit, real-world class (budget permitting), or local
interest group where the user can test their skills against practitioners. If
the user has said they don't want a community, respect it.

## Glossary promotion

Promote a term into `GLOSSARY.md` only once the user can use it correctly. The
glossary records compressed understanding — it is not a dictionary the user
reads to learn. Compressing a concept into a tight definition is itself evidence
they've got it, and once a term is in, use it everywhere, including inside later
definitions.
