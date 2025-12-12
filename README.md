# D3-Kit: Developer-Driven Development Framework

<div align="center">
    <h3>Build high-quality software faster with Developer-Driven Development</h3>
</div>

<p align="center">
    <strong>An open source toolkit that allows you to focus on developer intent and predictable outcomes instead of vibe coding every piece from scratch.</strong>
</p>

## 🚀 What is D3-Kit?

D3-Kit (Developer-Driven Development) is a methodology that inverts traditional software development. Instead of code being king with documentation serving it, D3-Kit ensures that specifications, plans, and tasks are the source of truth with code as the final implementation output.

**Key Innovation**: D3-Kit emphasizes developer intent-first development, where every feature starts with the "why" behind it, not just the "what."

## 🌟 Core Features

- **Intent-First Development**: Every specification captures the "why" behind features
- **Coding Slices**: Features broken into independently developable units
- **AI-Optimized**: All templates and commands designed for AI-assisted development
- **Parallel Exploration**: Built-in support for multiple implementation approaches
- **Executable Specifications**: Specs that directly generate working code
- **Slice-Based Architecture**: Each component is independently testable and deployable

## ⚡ Quick Start

### 1. Install D3-Kit

Install D3-Kit directly from GitHub using `uv`:

```bash
uv tool install git+https://github.com/Nom-nom-hub/D3-Kit.git@master
```

This installs D3-Kit as a command-line tool globally, making the `d3` command available in your terminal.

Alternatively, with `pipx`:

```bash
pipx install git+https://github.com/Nom-nom-hub/D3-Kit.git@master
```

Or clone and run locally:

```bash
git clone https://github.com/Nom-nom-hub/D3-Kit.git
cd D3-Kit
uv run d3 init <PROJECT_NAME>
```

### 2. Initialize D3-Kit Project

```bash
# Initialize with your AI assistant
d3 init <PROJECT_NAME> --ai claude
# or
d3 init <PROJECT_NAME> --ai cursor
```

### 3. Launch Your AI Assistant

Navigate to your project directory and launch your AI assistant (Claude Desktop, Cursor, etc.):

```bash
cd <PROJECT_NAME>
# Launch your AI assistant in this directory
```

### 4. Capture Developer Intent

Use the **`/d3.constitution`** command to create principles and development guidelines:

```bash
/d3.constitution Create principles focused on code quality, testing standards, user experience consistency, and performance requirements
```

### 5. Create the D3 Specification

Use the **`/d3.intend`** command to describe what you want to build. Focus on the **what**, **why**, and **developer intent**:

```bash
/d3.intend Build an application that can help me organize my photos in separate photo albums. Albums are grouped by date and can be re-organized by dragging and dropping on the main page. Albums are never in other nested albums. Within each album, photos are previewed in a tile-like interface.
```

### 6. (Optional) Gather Technical Research

Use the **`/d3.research`** command to automatically gather technical research:

```bash
/d3.research
```

### 7. Define Data Models

Use the **`/d3.data`** command to generate key entities and data models:

```bash
/d3.data
```

### 8. Generate API Contracts

Use the **`/d3.contracts`** command to create API/event contracts:

```bash
/d3.contracts
```

### 9. Create a Technical Implementation Plan

Use the **`/d3.plan`** command to provide your tech stack and architecture choices:

```bash
/d3.plan The application uses Vite with minimal number of libraries. Use vanilla HTML, CSS, and JavaScript as much as possible. Images are not uploaded anywhere and metadata is stored in a local SQLite database.
```

### 10. Break down into User Stories

Use **`/d3.tasks`** to create an actionable task list from your implementation plan:

```bash
/d3.tasks
```

### 11. (Optional) Create Validation Guide

Use **`/d3.quickstart`** to create a quickstart/validation guide:

```bash
/d3.quickstart
```

### 12. Execute Implementation

Use **`/d3.implement`** to execute all tasks and build your feature according to the plan:

```bash
/d3.implement
```

## Helper Scripts

D3-Kit includes helper scripts in the `scripts/` directory to automate common workflows:

### Bash Scripts
- `check-prerequisites.sh` - Verify required tools are installed
- `create-new-feature.sh` - Create a new feature branch and spec file
- `setup-plan.sh` - Initialize plan, data model, and quickstart files
- `update-agent-context.sh` - Generate context file from feature artifacts
- `common.sh` - Shared utility functions

### PowerShell Scripts
- `check-prerequisites.ps1` - Verify required tools are installed
- `create-new-feature.ps1` - Create a new feature branch and spec file
- `setup-plan.ps1` - Initialize plan, data model, and quickstart files
- `update-agent-context.ps1` - Generate context file from feature artifacts
- `common.ps1` - Shared utility functions

These scripts help automate feature development workflows and maintain consistent structure across projects.

## 🛠️ D3-Kit Commands

| Command | Description |
|--------|-------------|
| `/d3.intend` | Create a new feature specification from a user description, capturing developer intent and user stories |
| `/d3.research` | Gather technical or contextual research automatically for a feature |
| `/d3.data` | Generate/update key entities & data models for the feature |
| `/d3.contracts` | Generate API/event contracts from the plan |
| `/d3.plan` | Generate implementation plan for a feature based on its spec.md, mapping user stories to technical tasks |
| `/d3.tasks` | Generate an executable task list from the implementation plan, with parallelization |
| `/d3.quickstart` | Produce a quickstart/validation guide to verify the feature independently |
| `/d3.implement` | Execute all tasks to build the feature according to the plan |
| `/d3.clarify` | Clarify underspecified areas (recommended before `/d3.plan`) |
| `/d3.analyze` | Cross-artifact consistency & coverage analysis |
| `/d3.checklist` | Generate custom quality checklists |
| `/d3.constitution` | Create or update project governing principles and development guidelines |

## 📋 D3-Kit Workflow

1. **Idea Capture**: Natural language feature description
2. **D3 Specification**: Structured spec with developer intent and user stories (`/d3.intend`)
3. **Technical Research**: Optional research gathering (`/d3.research`)
4. **Data Modeling**: Entity and data model generation (`/d3.data`)
5. **Contract Generation**: API/event contract definition (`/d3.contracts`)
6. **Technical Planning**: Implementation plan with architecture decisions (`/d3.plan`)
7. **Task Generation**: User story-organized, parallelizable tasks (`/d3.tasks`)
8. **Validation Guide**: Quickstart/validation guide creation (`/d3.quickstart`)
9. **Code Generation**: AI-assisted implementation from tasks (`/d3.implement`)
10. **Validation**: Testing against original intent and requirements

## 🎯 Key Differences from Spec Kit

| Aspect | Spec Kit | D3-Kit |
|--------|----------|---------|
| Focus | Feature specifications | Developer intent + coding slices |
| Organization | User stories | Coding slices |
| Parallelization | Basic | Built-in exploration of multiple approaches |
| AI Optimization | Standard | AI-first design for better code generation |
| Intent Tracking | Implicit | Explicit in every artifact |
| Regeneration | Full rebuilds | Safe, partial regeneration notes |

## 🏗️ Project Structure

```
project/
├── d3-features/              # D3 feature specifications
│   └── 001-feature-name/
│       ├── spec.md           # Developer intent & user stories
│       ├── plan.md           # Technical implementation plan
│       ├── tasks.md          # User story-organized tasks
│       ├── research.md       # Tech research & decisions
│       ├── data-model.md     # Data models and entities
│       ├── quickstart.md     # Validation guide
│       └── contracts/        # API/event contracts
├── memory/                   # D3-Kit constitution
│   └── d3-constitution.md    # Project principles
├── D3-templates/             # D3-Kit templates
│   ├── d3-spec-template.md   # Specification template
│   ├── d3-plan-template.md   # Planning template
│   ├── d3-tasks-template.md  # Tasks template
│   ├── d3-commands/          # Command templates
│   │   ├── d3.intend.md      # Intend command template
│   │   ├── d3.research.md    # Research command template
│   │   ├── d3.data.md        # Data command template
│   │   ├── d3.contracts.md   # Contracts command template
│   │   ├── d3.plan.md        # Plan command template
│   │   ├── d3.tasks.md       # Tasks command template
│   │   ├── d3.quickstart.md  # Quickstart command template
│   │   ├── d3.implement.md   # Implement command template
│   │   ├── d3.clarify.md     # Clarify command template
│   │   ├── d3.analyze.md     # Analyze command template
│   │   ├── d3.checklist.md   # Checklist command template
│   │   └── d3.constitution.md # Constitution command template
│   └── contracts/            # Contract templates
└── scripts/                  # D3-Kit automation scripts
```

## 🎯 D3-Kit Principles

- **Intent-First Development**: Everything starts from developer intent
- **Executable Specifications**: Specs that generate working code
- **Continuous Validation**: Quality checking throughout the process
- **Task-Oriented Development**: Clear, actionable work items
- **Parallel Exploration**: Multiple approaches for optimization
- **Test-First Thinking**: Tests derived from specifications
- **No Speculation**: Every item maps to original intent

## 🤝 Contributing

We welcome contributions to D3-Kit! Please see our [contributing guidelines](CONTRIBUTING.md) for more details.

## 📄 License

This project is licensed under the terms of the MIT open source license. Please refer to the [LICENSE](LICENSE) file for the full terms.