---
name: spec-and-plan
description: Lightweight orchestrator for spec-before-plan workflow. Use when starting a feature with ambiguous requirements. Walks SPEC.md → PLAN.md → execute, delegating to /superpowers:writing-plans and /superpowers:executing-plans. Invoke when asked to "spec this out", "spec-first", "spec and plan for X", or when feature requirements are vague.
---

# Spec-and-Plan Orchestrator

A three-phase workflow for ambiguous features. This skill is a **lightweight markdown path** for repos that don't use OpenSpec; for OpenSpec-configured repos, prefer `/openspec-propose` instead.

This skill **delegates** to existing skills rather than duplicating them, so it survives the context clears it recommends between phases.

## Routing

- **OpenSpec repo?** Use `/openspec-propose` instead. (Detect by checking for `.openspec/` or `openspec.yaml`.)
- **Repo using `docs/superpowers/plans/` convention?** Phase 2 will write there via `/superpowers:writing-plans`.
- **Otherwise:** SPEC.md and PLAN.md go in repo root.

## Phase 1 — Spec

Goal: capture observable behavior, resolve ambiguity, get user signoff.

1. Ask the user to describe the feature in their words.
2. Write `SPEC.md` (or `docs/specs/<feature>.md` if the repo has a `docs/specs/` directory) with sections:
   - **Behavior** — what the user/system observes
   - **Inputs / Outputs**
   - **Edge cases & error states**
   - **Non-goals** (explicit)
   - **Open questions** (numbered, for the user to answer)
3. Iterate with the user — they can either answer in chat or write `FEEDBACK:` blocks directly into SPEC.md.
4. When the spec is approved, write `.spec-and-plan-state.json` at repo root containing `{ "phase": "plan", "spec_path": "<path>" }` so this skill can resume after context clear.
5. Recommend the user run `/clear` (or open a fresh session) before Phase 2.

## Phase 2 — Plan

Goal: turn the spec into an executable plan via the existing planning skill.

1. Read `.spec-and-plan-state.json` to recover state, then read the spec.
2. **Invoke `/superpowers:writing-plans`** with the spec content as input. That skill handles all the plan-writing details (file paths, structure, file location conventions). Do not reimplement.
3. When the plan is approved, update `.spec-and-plan-state.json` to `{ "phase": "execute", "spec_path": "<path>", "plan_path": "<path>" }`.
4. Recommend `/clear` before Phase 3.

## Phase 3 — Execute

Goal: implement against the plan, with agent review.

1. Read `.spec-and-plan-state.json` and the plan file.
2. **Invoke `/superpowers:executing-plans`** with the plan path. That skill handles step-by-step execution.
3. Per CLAUDE.md guardrail #4, commit after each meaningful step.
4. Per CLAUDE.md guardrail #6, after implementation: run `git diff` self-review, then spawn `trevelyan`, capped at 2 rounds, severity-gated.
5. Delete `.spec-and-plan-state.json` when done.

## When to skip this skill

- Trivial changes (per CLAUDE.md guardrail #2's skip list)
- Crystal-clear requirements — invoke `/superpowers:writing-plans` directly
- Bug fixes — write a failing test instead, no spec needed
