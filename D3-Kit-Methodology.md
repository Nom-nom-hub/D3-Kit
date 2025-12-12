# D3-Kit: Developer-Driven Development Methodology

## Overview

D3-Kit (Developer-Driven Development) is a methodology that inverts traditional software development by making developer intent the primary driver of all code generation. Instead of code being king with documentation serving it, D3-Kit ensures that specifications, plans, and tasks are the source of truth with code as the final implementation output.

## The Core Philosophy

In D3-Kit, code is always generated from structured intent, not the other way around. The old model—where code is king and documentation merely serves it—creates gaps between what developers intend and what the system actually does.

D3-Kit flips this: specifications, plans, and tasks are the source of truth. Code is the final output, an implementation of intent-driven development. Every artifact you create—specs, implementation plans, tests—is versioned, structured, and executable.

AI assists by transforming abstract requirements into actionable development items, ensuring that intent is consistently realized in code.

## D3-Kit Workflow

The workflow is iterative, modular, and AI-assisted:

1. **Idea Capture**: The developer captures a feature idea or user story in natural language. This becomes the initial spec draft.

2. **Specification Structuring**: AI converts the draft into a structured specification, defining:
   - User stories with priorities
   - Developer intent behind each story
   - Independent test criteria
   - Acceptance scenarios
   - Edge cases
   - Dependencies and constraints

3. **Research**: AI gathers technical research to inform implementation (optional):
   - Library/framework comparisons
   - Performance benchmarks
   - Security implications
   - Organizational standards

4. **Data Modeling**: AI generates data models based on specification:
   - Key entities and attributes
   - Relationships between entities
   - Constraints and indexes

5. **Contracts Generation**: AI creates API/event contracts:
   - API endpoints with schemas
   - Event definitions
   - Validation rules

6. **Implementation Planning**: AI generates an implementation plan, including:
   - Architecture mapping
   - Technology stack decisions
   - API endpoints
   - Testing strategies
   - Parallel exploration opportunities

7. **Task Generation**: AI translates the plan into discrete, executable tasks, marked with:
   - Dependencies
   - Parallelization flags [P]
   - User story associations [US1], [US2], etc.
   - Estimated complexity

8. **Quickstart Validation**: AI creates validation guide:
   - Setup instructions
   - Test procedures
   - Success metrics

9. **Code Generation & Validation**: Code is generated from tasks, then validated against tests derived from the specification.

10. **Feedback Loop**: Runtime metrics, incidents, and user feedback feed back into specs, ensuring the system evolves organically.

## Key Differentiators from Spec Kit

- **Developer Intent Focus**: Each specification explicitly captures WHY something matters, not just WHAT needs to be built
- **User Stories**: Features are broken into independently developable, testable units with clear user value
- **Parallel Exploration**: Built-in support for generating multiple approaches to compare performance, usability, and maintainability
- **AI-Centric Design**: All artifacts are designed for optimal AI consumption and code generation
- **Regeneration-Friendly**: Specs include notes on which parts can be safely AI-regenerated when requirements change

## Core Principles

- **Intent-First Development**: Everything starts from developer intent captured in natural language.
- **Executable Specifications**: Specs must be precise enough to generate working code.
- **Continuous Validation**: Specs and plans are continuously checked for ambiguity, contradictions, and gaps.
- **Task-Oriented Development**: Every plan translates into actionable tasks for AI or humans.
- **Parallel Exploration**: Generate multiple approaches for experimentation—performance, usability, maintainability.
- **Test-First Thinking**: All code is test-driven; tests are derived from specifications, not the other way around.
- **Immutable Principles, Flexible Application**: Core methodology rules remain stable, but their application adapts to new tech and requirements.

## D3-Kit Command Concepts

### `/d3.intend`
Converts a raw idea into a structured feature specification.
Auto-generates feature numbering and file structure.
Marks uncertainties with [CLARIFY].

Example:
```
/d3.intend "Add user activity dashboard"
```

Generates:
```
d3-features/004-user-activity/spec.md
- User stories with developer intent
- Acceptance criteria
- Dependencies
- [CLARIFY] markers
- Regeneration notes
```

### `/d3.research`
Gathers technical or contextual research automatically for a feature.
Compares libraries/frameworks, benchmarks performance, analyzes security implications.

Example:
```
/d3.research
```

Generates:
```
d3-features/004-user-activity/research.md
- Library comparisons
- Performance benchmarks
- Security implications
- Organizational standards
```

### `/d3.data`
Generates/updates key entities & data models for the feature.
Defines entities, relationships, and constraints without implementation details.

Example:
```
/d3.data
```

Generates:
```
d3-features/004-user-activity/data-model.md
- Entity definitions
- Relationships
- Attributes
- Constraints
```

### `/d3.contracts`
Generates API/event contracts from the plan.
Creates contracts directory with endpoint and event definitions.

Example:
```
/d3.contracts
```

Generates:
```
d3-features/004-user-activity/contracts/
- API endpoint definitions
- Event schemas
- Validation rules
```

### `/d3.plan`
Transforms the specification into a detailed implementation plan.
Maps requirements to architecture, data models, APIs, and tests.
Highlights potential design alternatives for parallel exploration.

Example:
```
/d3.plan "PostgreSQL for activity storage, GraphQL for queries, React dashboard"
```

Generates:
```
d3-features/004-user-activity/plan.md
- Architecture diagrams
- API contracts
- Test strategies
- Task dependencies
- Parallel exploration strategy
- Data models
- Quickstart guide
```

### `/d3.tasks`
Breaks the plan into discrete, executable tasks with parallelization markers.
Flags independent tasks [P] for parallel execution.
Produces ready-to-run development lists organized by user story.

Example:
```
/d3.tasks
```

Generates:
```
d3-features/004-user-activity/tasks.md
- [ ] Create DB schema
- [P] [US1] Implement GraphQL queries
- [ ] [US2] Create frontend dashboard
- [P] [US3] Write contract and unit tests
- [PEX] Explore performance optimization approaches
```

### `/d3.quickstart`
Produces a quickstart/validation guide to verify the feature independently.
Creates step-by-step instructions for validating the feature in isolation.

Example:
```
/d3.quickstart
```

Generates:
```
d3-features/004-user-activity/quickstart.md
- Prerequisites
- Setup instructions
- Validation steps
- Success metrics
```

## Template Principles

Templates guide AI to produce high-quality, actionable outputs:

- **Focus on Intent, Not Tech**: Templates enforce abstraction; avoid premature tech decisions.
- **Explicit Clarification Markers**: AI must mark uncertainties with [CLARIFY].
- **Structured Self-Validation**: Checklists embedded in templates ensure completeness and consistency.
- **Phase Gates**: Critical architectural principles enforced before task breakdown.
- **Hierarchical Detail**: Keep high-level plans readable; complex algorithms and implementation details live in separate files.
- **Test-Driven Order**: All code must be preceded by tests.
- **No Speculation**: Every item must map to a user story or requirement.
- **AI-First Design**: All templates structured for optimal AI consumption.
- **Parallel-Ready**: Tasks designed for independent, concurrent execution with explicit parallelization markers.

## The D3-Kit Advantage

- **Intent Alignment**: Developers focus on creativity; AI handles translation and code generation.
- **Rapid Iteration**: Specifications, plans, and tasks update instantly when requirements change.
- **Traceable Decisions**: Every technical choice maps back to a requirement or developer intent.
- **Parallel Development**: Tasks designed for independent, concurrent execution with explicit parallelization markers.
- **Living Documentation**: Specs evolve continuously alongside the system with regeneration notes.
- **AI-Optimized**: All artifacts designed for effective AI processing and code generation.