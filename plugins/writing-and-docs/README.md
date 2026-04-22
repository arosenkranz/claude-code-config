# writing-and-docs

Technical writing, documentation generation, API docs, tutorials, ADRs, and writing quality review.

## Skills

| Skill | Purpose |
|---|---|
| `documenting-apis` | Generate API reference docs from code or OpenAPI specs |
| `documenting-architectures` | Write architecture docs and diagrams |
| `creating-tutorials` | Draft step-by-step tutorials for technical topics |
| `creating-reference-docs` | Create reference documentation |
| `doc-coauthoring` | Collaborative doc drafting with iterative feedback |
| `add-doc-item` | Add a single item (function, endpoint, type) to existing docs |
| `internal-comms` | Draft internal announcements, RFCs, and proposals |
| `problem-statement` | Write clear problem statements for features or bugs |
| `linting-technical-writing` | Review docs against Google Technical Writing guidelines |
| `brand-guidelines` | Apply brand voice and style to content |
| `maintaining-brag-docs` | Keep a running brag document updated |
| `learning-guide` | Create structured learning guides for a topic |

## Requirements

No external binaries are required. Skills are purely generative — they produce Markdown, OpenAPI YAML, or prose.

Optional tools that improve specific workflows:

| Tool | Purpose | Install |
|---|---|---|
| Mermaid CLI | Render architecture diagrams locally | `npm install -g @mermaid-js/mermaid-cli` |
| OpenAPI generator | Validate OpenAPI specs | `brew install openapi-generator` |

## Notes

- `documenting-apis` works best when pointed at existing code or an OpenAPI spec — give it a file path or paste the spec
- `linting-technical-writing` applies Google's developer documentation style guide; it's opinionated about passive voice, second-person address, and sentence length
- `maintaining-brag-docs` is also triggered by the `goldeneye-agents` `moneypenny` agent at session end — they write to the same doc, so pick one approach or both will accumulate entries
