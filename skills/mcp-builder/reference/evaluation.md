# MCP Server Evaluation Guide

## Overview

Create comprehensive evaluations to test whether LLMs can effectively use your MCP server to answer realistic, complex questions.

---

## Quick Reference

### Evaluation Requirements
- Create 10 human-readable questions
- Questions must be READ-ONLY, INDEPENDENT, NON-DESTRUCTIVE
- Each question requires multiple tool calls (potentially dozens)
- Answers must be single, verifiable values
- Answers must be STABLE (won't change over time)

### Output Format
```xml
<evaluation>
   <qa_pair>
      <question>Your question here</question>
      <answer>Single verifiable answer</answer>
   </qa_pair>
</evaluation>
```

---

## Question Guidelines

### Core Requirements

1. **Questions MUST be independent** - Each question should NOT depend on answers to other questions

2. **Questions MUST require ONLY NON-DESTRUCTIVE AND IDEMPOTENT tool use** - Should not modify state

3. **Questions must be REALISTIC, CLEAR, CONCISE, and COMPLEX** - Must require multiple tools or steps

### Complexity and Depth

4. **Questions must require deep exploration** - Multi-hop questions requiring sequential tool calls

5. **Questions may require extensive paging** - May need paging through multiple pages of results

6. **Questions must require deep understanding** - Not surface-level knowledge

7. **Questions must not be solvable with straightforward keyword search** - Use synonyms, related concepts

### Tool Testing

8. **Questions should stress-test tool return values** - Large JSON objects, various data types

9. **Questions should MOSTLY reflect real human use cases**

10. **Questions may require dozens of tool calls** - Challenges LLMs with limited context

11. **Include ambiguous questions** - Force difficult decisions while maintaining single verifiable answer

### Stability

12. **Questions must be designed so the answer DOES NOT CHANGE** - Don't ask about dynamic state

---

## Answer Guidelines

### Verification

1. **Answers must be VERIFIABLE via direct string comparison**
   - Specify output format in the QUESTION
   - Examples: "Use YYYY/MM/DD.", "Respond True or False."

### Readability

2. **Answers should prefer HUMAN-READABLE formats**
   - Names, datetimes, URLs, yes/no, true/false
   - Rather than opaque IDs (though IDs are acceptable)

### Stability

3. **Answers must be STABLE/STATIONARY**
   - Look at old, closed content
   - Create questions based on concepts unlikely to change

### Diversity

4. **Answers must be DIVERSE** - Various formats: IDs, names, timestamps, URLs, booleans

5. **Answers must NOT be complex structures** - Not lists or objects unless straightforwardly verifiable

---

## Evaluation Process

### Step 1: Documentation Inspection
- Read API documentation to understand available functionality
- Fetch additional info from web if needed

### Step 2: Tool Inspection
- List available tools in the MCP server
- Understand input/output schemas and descriptions

### Step 3: Developing Understanding
- Iterate on steps 1 & 2 until good understanding
- Think about challenging tasks to create

### Step 4: Read-Only Content Inspection
- Use the MCP tools to explore actual data
- Identify specific content for questions

### Step 5: Question Creation
- Create 10 questions based on exploration
- Verify each answer independently

---

## Example Questions

**Good Question:**
```
Find discussions about AI model launches with animal codenames. One model needed
a specific safety designation that uses the format ASL-X. What number X was being
determined for the model named after a spotted wild cat?
```
Answer: `3`

**Why it's good:**
- Requires multiple searches and exploration
- Answer is stable and verifiable
- Uses synonyms (doesn't say "leopard" directly)
- Requires understanding context

**Bad Question:**
```
How many messages are in the #general channel?
```

**Why it's bad:**
- Answer changes constantly
- Too simple (one tool call)
- Not realistic human use case
