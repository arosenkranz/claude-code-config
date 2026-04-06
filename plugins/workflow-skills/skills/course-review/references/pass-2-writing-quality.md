# Pass 2: Writing Quality

Close reading at the sentence and paragraph level. Apply Google Technical Writing One and Two principles. Read each sentence carefully rather than scanning for patterns.

---

## Words and Terminology

* **Consistent terms.** Use one term per concept throughout. Flag synonym alternation (e.g., using "dashboard" and "board" interchangeably for the same UI element).
* **Acronyms spelled out on first use.** Format: full term followed by acronym in parentheses. "Real User Monitoring (RUM)" then "RUM" thereafter.
* **No synonym alternation for actions.** Don't alternate between "create", "add", and "set up" when referring to the same operation.

## Pronouns

* **Pronoun must have a clear referent within 5 words.** Flag "it", "this", "that", "they", "these", "those" when the referent is ambiguous or more than one sentence back.
* **No bare "this" or "that" without a following noun.**
  * Flag: "This is important because..."
  * Fix: "This configuration is important because..."

## Active Voice

* **Flag passive constructions**: form of "be" (is, are, was, were, been) + past participle.
  * Flag: "The logs are collected by Datadog." / "The metric is sent to..."
  * Fix: "Datadog collects the logs." / "The agent sends the metric..."
* **Use imperative verbs in instructions.** Instructions should command, not describe.
  * Flag: "The user should click..." / "You'll want to navigate..."
  * Fix: "Click..." / "Navigate to..."

## Strong Verbs

* **Flag weak verb patterns and suggest replacements:**
  * "There is/are" → replace with a specific subject and verb
  * "occurs", "happens", "takes place" → replace with the specific action
  * "provides a description of" → "describes"
  * "is able to" → "can"
  * "in order to" → "to"
  * "makes use of" → "uses"
  * "at this point in time" → "now"
  * "due to the fact that" → "because"
  * "in the event that" → "if"

## Sentence Clarity

* **One idea per sentence.** Flag sentences that pack multiple distinct ideas joined by "and", "but", or "which".
* **Flag sentences over ~25 words.** Suggest splitting.
* **Eliminate filler phrases.** See weak verb patterns above for common examples.

## "That" vs. "Which"

* **"That" for essential (restrictive) clauses** — no comma before it. "The file that you created..."
* **"Which" for non-essential (non-restrictive) clauses** — preceded by a comma. "The config file, which is optional, ..."
* Flag incorrect usage when it creates ambiguity or alters meaning.

## Lists and Tables

* **Parallel structure mandatory.** All items in a list must follow the same grammatical form (all noun phrases, all imperative verbs, all complete sentences, etc.).
* **Numbered lists for sequential steps.** Bulleted lists for unordered items.
* **Imperative verbs to start numbered list items.** "Click the **Save** button." not "The Save button should be clicked."
* **Tables for comparison.** When comparing multiple options across the same attributes, a table is clearer than repeated paragraphs.

## Paragraphs

* **Strong opening sentence.** The first sentence of a paragraph should state the main point, not wind up to it.
* **One topic per paragraph.** Flag paragraphs that contain two distinct ideas.
* **Target 3-5 sentences per paragraph.** Flag walls of text (6+ sentence paragraphs).
* **Avoid burying the key point.** If the first sentence is scene-setting and the second sentence is the actual point, consider swapping them.

## Conditions Before Instructions

* **State the condition before the action.** "If the status is red, click **Retry**." not "Click **Retry** if the status is red."
* This applies to all conditional steps, including notes and warnings.

## Audience Awareness

* **No idioms or cultural references.** Flag expressions that may not translate for non-native English speakers.
* **No assumed knowledge beyond stated prerequisites.** If a concept appears without explanation, flag it if it's not covered in the course prerequisites.
* **Simple vocabulary.** Flag unnecessarily complex words when a simpler alternative exists.
* **Consistent tone.** Don't shift between formal and casual register within the same lesson.

---

## Quick Scan Checklist

Use this for rapid first-pass identification before doing a close read:

- [ ] Passive voice ("is/are/was/were + past participle")
- [ ] Bare "this" or "that" without a following noun
- [ ] "There is/are" constructions
- [ ] Sentences over ~25 words
- [ ] Lists with inconsistent grammatical form
- [ ] Acronyms used before being defined
- [ ] "In order to" / "is able to" / "provides a description of"
- [ ] Conditions stated after instructions ("Do X if Y")
- [ ] Synonym alternation for the same concept or UI element
