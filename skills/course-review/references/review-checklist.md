# Course Review Checklist

> **Deprecated.** This checklist has been split into three pass-specific files:
> `pass-1-structure-format.md`, `pass-2-writing-quality.md`, `pass-3-content-flow.md`.
> The skill no longer loads this file directly. Content is preserved below as a fallback reference.

## Course Review Checklist (archived content)

Condensed from four Learning Center style guides. Load this file once at review start. For edge cases, consult the raw style guides in `docs/style-guide/`.

---

## Section 1: All Content

Source: `docs/style-guide/general-style-guide.md`

### Tone and voice

- **Use the imperative mood for instructions.** Tell learners to act; don't suggest or imply.
  - Flag: "You can click...", "You'll want to...", "Go ahead and..."
  - Fix: "Click the button."
- **Avoid first-person plural pronouns.** No "we", "our", "us".
  - Flag: "We'll cover...", "Our RUM product"
  - Fix: "You'll learn about...", "Datadog RUM"
- **Use plain language.** Short sentences, short paragraphs, precise terminology. No jargon or slang.
- **Treat the learner as an equal.** Don't over-explain concepts the audience already knows.
- **Use inclusive and gender-neutral language.** No ableist language, no figurative language, idioms, or sarcasm.
- **Use contractions.** Conversational tone: "can't" not "cannot", "you'll" not "you will".

### Language and grammar

- **Active voice.** Make the "doer" the subject.
  - Flag: "The logs are collected by Datadog."
  - Fix: "Datadog collects the logs."
- **Present tense for general behavior.** "There are three options." not "You should see three options."
- **Avoid hypothetical future "would."** "Clicking starts the process." not "If you clicked, the process would begin."
- **Consistent verb tense** for similar information (lists, headings). Don't mix tenses in parallel structures.
- **Parallel sentence structures** for similar information. Instructions in a list should follow the same grammatical pattern.
- **Spell out abbreviations on first reference.** "Real User Monitoring (RUM)" then "RUM".

### Titles and headings

- **Title Case** for course, chapter, lesson, and activity titles.
- **Sentence case** for all other headings (subsections, activity summaries, etc.).
- **Imperative verbs, not gerunds, in titles.** "Optimize Frontend Performance" not "Optimizing Frontend Performance". Exception: "Getting Started with..." course titles.
- **Don't skip heading ranks.** H3 must be under H2; H4 must be under H3. Skipping is an accessibility violation (P1).

### Punctuation

- **Complete sentence before a colon.** "You'll do the following: ..." not "You'll be able to: ..."
- **Period at end of complete-sentence list items.** No period for fragment list items (e.g., a shopping list).
- **Comma after introductory words and phrases.** "Finally, submit the form." not "Finally submit the form."
- **Oxford/serial comma.** "search, filter, and group" not "search, filter and group."
- **Em dash with no spaces.** "the assets—files and info—required" not "the assets — files and info — required."
- **Single space between sentences.**

### Text formatting

- **Bold UI element labels/text** (button text, page titles, link text, tab names, headings, column labels).
- **Don't bold icon descriptions.** Use "click the gear icon" not "click the **gear** icon."
- **Describe the UI element type.** "Click the **Errors** tab." not "Click **Errors**."
- **Code formatting for text input** (learner-entered text, pre-populated input field text).
- **Code formatting for filenames.** "Open `docker-compose.yml`." not "Open docker-compose.yml."

### Datadog references

- **Refer to Datadog products as "products"** not "features."
- **Refer to the Datadog UI as "Datadog"** not "the Datadog UI", "the Datadog app", or "the Datadog application."

### Fake URLs and email addresses

- Use reserved domains only: `example.com`, `example.net`, `example.org`.
- Flag: `maria@storedog.com`, `my-web-store.com`

---

## Section 2: LMS Lessons

Source: `docs/style-guide/lms-lessons-style-guide.md`

Applies to files in `lms/*.md`.

- **No H1 headings** (`#` or `<h1>`). The Thinkific course title is the H1. Highest allowed: `##`. (P1 - accessibility violation)
- **Avoid HTML** except: video embeds (`<div>`/`<iframe>`), `<details>`/`<summary>` elements.
- **Use semantic HTML** when HTML is needed: `<p>`, `<strong>`, `<em>`, `<code>`, `<pre><code>`. Not `<b>`, `<i>`, `<span>`, `<br>` for spacing.
- **Block quote syntax for alerts** (mimicking Instruqt alerts): `> **Note** \n > ...`
- **Markdown syntax for images**, not HTML `<img>` tags.
- **Empty line before the first list item.** Paragraph text must be followed by a blank line before the list starts.
- **Links must open in a new tab**: `[text](url){target="_blank"}`.

### `<details>` elements in LMS

- Blank line after `</summary>` tag.
- Use HTML inside `<summary>` tags (not Markdown): `<strong>`, `<em>`, `<code>`.
- Use semantic HTML inside the `<details>` block.
- Proper Markdown indentation inside the block.

---

## Section 3: Lab Instructions

Source: `docs/style-guide/lab-instructions-style-guide.md`

Applies to `labs/*/assignment.md` files.

### Structure

- **Conclude each activity with a summary section.**
  - Non-final activity: `Activity summary` using `===` collapsible syntax.
  - Final activity: `Lab summary` using `===` collapsible syntax.
  - Missing summary is P2.

### Markdown syntax

- **Collapsible sections** use `===` syntax (Instruqt-specific).
- **Numbered lists**: use `1.` for all items (Markdown auto-numbers). Content related to a list item must be indented 4 spaces (2 tabs) beyond the `1.`.
- **Alerts**: use appropriate types:
  - `NOTE`: general callouts and reminders.
  - `IMPORTANT`: critical steps learners must not skip.
  - `WARNING`: potential errors the learner might cause.
- **Code blocks**:
  - Enable syntax highlighting with language identifiers.
  - Use `nocopy` for blocks learners should not copy.
  - Use `run` for commands learners execute in the terminal.

### `<details>` elements in labs

- Blank line after `</summary>` tag.
- HTML inside `<summary>` tags (not Markdown).
- Use semantic HTML.
- Proper indentation inside the block.
- Inside a list item: must indent 4 spaces (2 tabs) beyond the list item's `1.`.

### Interacting with the Datadog UI

- **"Find it first."** Describe location before action. "Above the lab terminal, click the **Storedog** tab." not "Click the **Storedog** tab above the lab terminal."
  - Exception: unambiguous buttons (Save, Update) in a simple interface.
- **Don't use color for UI elements.** "Check if the status is `OK`." not "Check if the status is green." (P1 - accessibility)
- **First navigation: detailed format.**
  `In Datadog, in the main menu, hover over **menu item**. Click **submenu** to navigate to **[page name](url)**.`
- **Subsequent navigation: concise format.**
  `Navigate to **[Menu Item > Submenu > Page](url)**.`
- **Don't link to a page without navigation hints.** Always use the `>` breadcrumb format.
- **Filter by `env` tag** the first time you describe a Datadog view that supports it.
  `Make sure that \`env:course-name\` is selected.`

### Lab environment terminology

| Use (Learning Center) | Don't use (Instruqt) |
|-----------------------|----------------------|
| Lab                   | Track                |
| Activity              | Challenge            |
| Tab                   | Challenge tabs       |

- **Don't over-explain the platform.** Assume learners have taken the Learning Environment course. Be explicit the first time, concise subsequently.
- **Tab switching**: use `In the lab,` prefix. "In the lab, click the **Terminal** tab."
- **IDE references**: "In the lab IDE, open `filename.yaml`."
- **Terminal references**: "In the lab terminal, run the following command:"

### Common phrases

- **Keyboard shortcuts**: use "press". "Press `cmd/ctrl+K`." not "Type `cmd/ctrl+K`."
- **Time range dropdown**: use "Set the time range to". "Set the time range to `Past 1 Hour`." not "In the time selector dropdown, select..."

---

## Section 4: Screenshots and Images

Source: `docs/style-guide/screenshots-and-images.md`

- **Alt text is required** for all images. (P1 - accessibility violation if missing)
- **Alt text ends with a period.** Screen readers pause after the period.
- **Don't start alt text with "An image of..." or "A screenshot of..."** Screen readers already announce it's an image.
- **Alt text works as a complete replacement of the image.** Include important text visible in the image.
- **Complex images: use two-part alt text.** Describe before or after the image in the lesson body. Alt text should say "Described above." or "Described in the next paragraph."
- **No surprise screenshots.** Images always follow the instructions they illustrate. If referring to an image above, say so: "As shown in the image above, ..."
- **Show only relevant UI areas** in screenshots.
- **Descriptive filenames in kebab-case.** "monitor-alert-status.png" not "screenshot1.png".
- **Lab images**: place in `labs/assets/` for the course.
- **LMS images**: place in `lms/assets/` for the course.

---

## Section 5: Technical Writing Quality

Beyond the style guides. These checks catch clarity and instructional design issues.

### Sentence clarity

- **Ambiguous pronouns.** "It does..." or "This shows..." — what does "it" or "this" refer to? Flag when the referent is more than one sentence back.
- **Weak verbs.** "There is...", "There are...", "It does..." — prefer specific, active verbs.
- **Sentence length.** Flag sentences over ~25 words. Suggest splitting.
- **Jargon without explanation.** Technical terms introduced without definition when the audience may not know them.

### Logical flow

- **One topic per paragraph.** Flag paragraphs that mix two distinct ideas.
- **Strong opening sentences.** Paragraph openers should state the main point, not wind up to it.
- **Missing transitions.** Abrupt shifts between topics or steps without a connecting phrase.

### Step gap detection (labs only)

- **Skipped assumed knowledge.** Instructions assume the learner knows something not yet taught (e.g., "Open the config file" without saying which file or where it is).
- **Unclear target.** "Click here" or "Select it" without identifying what "here" or "it" is.
- **Missing context switches.** Moving between the lab environment and Datadog without signaling the switch to the learner.
- **Unexplained prerequisites.** Referencing a resource, value, or state that hasn't been set up in prior steps.
- **Navigation without enough detail.** First-time navigation instructions that don't tell the learner where to hover, click, or look.
