---
name: test-harness
description: Generate comprehensive testing frameworks for curriculum projects. Supports pytest, Jest, Cypress, and Postman across API, frontend, integration, and Instruqt lab validation scenarios.
disable-model-invocation: true
---

# Test Harness Generator

Generate comprehensive testing frameworks for curriculum projects with proper validation and coverage.

## Usage

```
/test-harness [project-type] [framework] [options]
```

## Project Types

* `api` - REST API testing
* `frontend` - React/Vue component testing
* `integration` - Service integration testing
* `instruqt` - Instruqt lab validation
* `curriculum` - Training material validation

## Frameworks

* `pytest` - Python testing with fixtures (see `references/pytest-templates.md`)
* `jest` - JavaScript/TypeScript testing (see `references/jest-templates.md`)
* `cypress` - End-to-end testing
* `postman` - API testing collections

## Process

1. **Test Strategy Design**
   * Analyze application architecture
   * Design test pyramid structure
   * Define coverage requirements
   * Plan test data management

1. **Test Suite Generation**
   * Create unit test templates
   * Generate integration tests
   * Set up end-to-end scenarios
   * Add performance tests

1. **Validation Framework** (see `references/instruqt-validation.md` for lab scripts)
   * Implement test fixtures
   * Create mock services
   * Add test data factories
   * Configure CI/CD integration

## Options

* `--coverage` - Set minimum coverage threshold
* `--integration` - Include integration test setup
* `--performance` - Add load testing configuration
* `--e2e` - Include end-to-end testing
* `--ci` - Generate CI/CD pipeline

## Examples

```
/test-harness api pytest --coverage 80 --integration --ci
/test-harness frontend jest --e2e cypress
/test-harness instruqt validation --performance
```
