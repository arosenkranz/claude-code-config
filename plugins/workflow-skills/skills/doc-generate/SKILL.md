---
name: doc-generate
description: Auto-generate documentation for curriculum projects including OpenAPI specs, Instruqt lab guides, architecture docs, tutorials, and README files. Use when creating project documentation or training material docs.
disable-model-invocation: true
---

# Documentation Generator

Automatically generate comprehensive documentation for curriculum projects and training materials.

## Usage

```
/doc-generate [doc-type] [target] [options]
```

## Document Types

* `api` - OpenAPI/Swagger documentation (see `references/api-docs.md`)
* `lab` - Instruqt lab guides (see `references/lab-guides.md`)
* `architecture` - System architecture docs (see `references/architecture.md`)
* `tutorial` - Step-by-step tutorials
* `readme` - Project README files

## Process

1. **Code Analysis**
   * Parse source code for documentation
   * Extract API endpoints and schemas
   * Analyze project structure
   * Identify key components

1. **Content Generation**
   * Generate API documentation
   * Create architecture diagrams
   * Build user guides
   * Produce code documentation

1. **Format & Publish**
   * Format for multiple outputs
   * Generate interactive docs
   * Create PDF/HTML versions
   * Integrate with documentation sites

## Options

* `--format` - Output format (markdown/html/pdf)
* `--interactive` - Generate interactive documentation
* `--include-examples` - Include code examples
* `--diagrams` - Generate architecture diagrams
* `--api-spec` - Include OpenAPI specifications

## Examples

```
/doc-generate api ./src --format html --interactive
/doc-generate lab ./instruqt-config --include-examples
/doc-generate architecture ./project --diagrams mermaid
/doc-generate tutorial ./curriculum --format markdown
```
