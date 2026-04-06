# Pass 1: Structure & Format

Mechanical, rules-based checks. Scan for violations rather than reading for comprehension. Load this file once before reviewing any lessons.

Source: Learning Center style guides in `docs/style-guide/`.

---

## Do Not Flag

* `{target="_blank"}` on links (handled by build tooling)

---

## Titles and Headings

* **Title Case** for course, chapter, lesson, and activity titles.
* **Sentence case** for all other headings (subsections, activity summaries, etc.).
* **Imperative verbs, not gerunds, in titles.** "Optimize Frontend Performance" not "Optimizing Frontend Performance". Exception: "Getting Started with..." course titles.
* **Don't skip heading ranks.** H3 must be under H2; H4 must be under H3. Skipping is a critical accessibility violation.

## Punctuation

* **Complete sentence before a colon.** "You'll do the following: ..." not "You'll be able to: ..."
* **Period at end of complete-sentence list items.** No period for fragment list items (e.g., a shopping list).
* **Comma after introductory words and phrases.** "Finally, submit the form." not "Finally submit the form."
* **Oxford/serial comma.** "search, filter, and group" not "search, filter and group."
* **Em dash with no spaces.** "the assets—files and info—required" not "the assets — files and info — required."
* **Single space between sentences.**

## Text Formatting

* **Bold UI element labels/text** (button text, page titles, link text, tab names, headings, column labels).
* **Don't bold icon descriptions.** Use "click the gear icon" not "click the **gear** icon."
* **Describe the UI element type.** "Click the **Errors** tab." not "Click **Errors**."
* **Code formatting for text input** (learner-entered text, pre-populated input field text).
* **Code formatting for filenames.** "Open `docker-compose.yml`." not "Open docker-compose.yml."

## Datadog References

* **Refer to Datadog products as "products"** not "features."
* **Refer to the Datadog UI as "Datadog"** not "the Datadog UI", "the Datadog app", or "the Datadog application."

## Fake URLs and Email Addresses

* Use reserved domains only: `example.com`, `example.net`, `example.org`.
* Flag: `maria@storedog.com`, `my-web-store.com`

---

## LMS Lessons (files in `lms/*.md`)

* **No H1 headings** (`#` or `<h1>`). The Thinkific course title is the H1. Highest allowed: `##`. (critical - accessibility violation)
* **Avoid HTML** except: video embeds (`<div>`/`<iframe>`), `<details>`/`<summary>` elements.
* **Use semantic HTML** when HTML is needed: `<p>`, `<strong>`, `<em>`, `<code>`, `<pre><code>`. Not `<b>`, `<i>`, `<span>`, `<br>` for spacing.
* **Block quote syntax for alerts** (mimicking Instruqt alerts): `> **Note** \n > ...`
* **Markdown syntax for images**, not HTML `<img>` tags.
* **Empty line before the first list item.** Paragraph text must be followed by a blank line before the list starts.

### `<details>` elements in LMS

* Blank line after `</summary>` tag.
* Use HTML inside `<summary>` tags (not Markdown): `<strong>`, `<em>`, `<code>`.
* Use semantic HTML inside the `<details>` block.
* Proper Markdown indentation inside the block.

---

## Lab Instructions (files in `labs/*/assignment.md`)

### Structure

* **Conclude each activity with a summary section.**
  * Non-final activity: `Activity summary` using `===` collapsible syntax.
  * Final activity: `Lab summary` using `===` collapsible syntax.
  * Missing summary is a major finding.

### Markdown Syntax

* **Collapsible sections** use `===` syntax (Instruqt-specific).
* **Numbered lists**: use `1.` for all items (Markdown auto-numbers). Content related to a list item must be indented 4 spaces (2 tabs) beyond the `1.`.
* **Alerts**: use appropriate types:
  * `NOTE`: general callouts and reminders.
  * `IMPORTANT`: critical steps learners must not skip.
  * `WARNING`: potential errors the learner might cause.
* **Code blocks**:
  * Enable syntax highlighting with language identifiers.
  * Use `nocopy` for blocks learners should not copy.
  * Use `run` for commands learners execute in the terminal.

### `<details>` elements in labs

* Blank line after `</summary>` tag.
* HTML inside `<summary>` tags (not Markdown).
* Use semantic HTML.
* Proper indentation inside the block.
* Inside a list item: must indent 4 spaces (2 tabs) beyond the list item's `1.`.

### Lab Environment Terminology

| Use (Learning Center) | Don't use (Instruqt) |
|-----------------------|----------------------|
| Lab                   | Track                |
| Activity              | Challenge            |
| Tab                   | Challenge tabs       |

* **Don't over-explain the platform.** Assume learners have taken the Learning Environment course. Be explicit the first time, concise subsequently.
* **Tab switching**: use `In the lab,` prefix. "In the lab, click the **Terminal** tab."
* **IDE references**: "In the lab IDE, open `filename.yaml`."
* **Terminal references**: "In the lab terminal, run the following command:"

### Interacting with the Datadog UI

* **"Find it first."** Describe location before action. "Above the lab terminal, click the **Storedog** tab." not "Click the **Storedog** tab above the lab terminal."
  * Exception: unambiguous buttons (Save, Update) in a simple interface.
* **Don't use color for UI elements.** "Check if the status is `OK`." not "Check if the status is green." (critical - accessibility)
* **First navigation: detailed format.**
  `In Datadog, in the main menu, hover over **menu item**. Click **submenu** to navigate to **[page name](url)**.`
* **Subsequent navigation: concise format.**
  `Navigate to **[Menu Item > Submenu > Page](url)**.`
* **Don't link to a page without navigation hints.** Always use the `>` breadcrumb format.
* **Filter by `env` tag** the first time you describe a Datadog view that supports it.
  `Make sure that \`env:course-name\` is selected.`

### Common Phrases

* **Keyboard shortcuts**: use "press". "Press `cmd/ctrl+K`." not "Type `cmd/ctrl+K`."
* **Time range dropdown**: use "Set the time range to". "Set the time range to `Past 1 Hour`." not "In the time selector dropdown, select..."

---

## Screenshots and Images

* **Alt text is required** for all images. (critical - accessibility violation if missing)
* **Alt text ends with a period.** Screen readers pause after the period.
* **Don't start alt text with "An image of..." or "A screenshot of..."** Screen readers already announce it's an image.
* **Alt text works as a complete replacement of the image.** Include important text visible in the image.
* **Complex images: use two-part alt text.** Describe before or after the image in the lesson body. Alt text should say "Described above." or "Described in the next paragraph."
* **No surprise screenshots.** Images always follow the instructions they illustrate. If referring to an image above, say so: "As shown in the image above, ..."
* **Show only relevant UI areas** in screenshots.
* **Descriptive filenames in kebab-case.** "monitor-alert-status.png" not "screenshot1.png".
* **Lab images**: place in `labs/assets/` for the course.
* **LMS images**: place in `lms/assets/` for the course.
