# D3-Kit Command System

This directory contains all D3-Kit commands, templates, and configuration for the D3 specification methodology.

## Command Workflow

### 1. **d3.intend** - Create Feature Specification
Start here when you have a new feature idea.
- **Input**: Feature description
- **Output**: `d3-features/NNN-feature-name/spec.md`
- **What agent does**:
  1. Runs script to create feature directory and spec file
  2. Opens spec.md
  3. Fills in Developer Intent, Functional Requirements, and Edge Cases from your description
  4. Reports what was filled in

### 2. **d3.plan** - Create Implementation Plan
Next, break down the specification into an implementation approach.
- **Input**: Path to d3-features/NNN-feature-name/
- **Output**: `d3-features/NNN-feature-name/plan.md`
- **What agent does**:
  1. Runs script to create plan file
  2. Opens plan.md
  3. Fills in High-Level Design, Key Decisions, Phases, Parallel opportunities
  4. Reports what was filled in

### 3. **d3.tasks** - Generate Executable Tasks
Break the plan into specific, actionable tasks.
- **Input**: Path to d3-features/NNN-feature-name/
- **Output**: `d3-features/NNN-feature-name/tasks.md`
- **What agent does**:
  1. Runs script to create tasks file
  2. Opens tasks.md
  3. Defines specific tasks with IDs, parallelization markers, dependencies, acceptance criteria
  4. Reports task breakdown

### 4. **d3.data** - Define Data Models
Create the data architecture for your feature.
- **Input**: Path to d3-features/NNN-feature-name/
- **Output**: `d3-features/NNN-feature-name/data-model.md`
- **What agent does**:
  1. Runs script to create data-model file
  2. Opens data-model.md
  3. Defines entities, attributes, relationships, storage strategy, validation rules
  4. Reports data model structure

### 5. **d3.clarify** - Identify Ambiguities
Check the specification for unclear requirements.
- **Input**: Path to spec.md
- **Output**: List of clarifications needed
- **Use when**: You want to verify the spec is complete and unambiguous

### 6. **d3.analyze** - Verify Consistency
Ensure all artifacts are consistent with each other.
- **Input**: Feature directory
- **Output**: Analysis report
- **Use when**: You want to verify spec, plan, and tasks align

### 7. **d3.checklist** - Create Validation Checklists
Generate quality assurance and testing checklists.
- **Input**: Feature directory
- **Output**: Quality checklists
- **Use when**: Ready to define how to validate the feature works

### 8. **d3.research** - Document Research Findings
Store research and investigation results.
- **Input**: Feature directory and research findings
- **Output**: `d3-features/NNN-feature-name/research.md`
- **Use when**: You need to document technology research, API investigation, etc.

### 9. **d3.contracts** - Define API/Service Contracts
Document external integrations and API contracts.
- **Input**: Feature directory
- **Output**: `contracts/api.md`
- **Use when**: You need to define contracts with external systems

### 10. **d3.constitution** - Set Project Principles
Define project-wide principles and conventions.
- **Input**: Principles and values
- **Output**: `memory/d3-constitution.md`
- **Use when**: You want to establish project guidelines

### 11. **d3.quickstart** - Create Getting Started Guide
Document how to set up and run the project.
- **Input**: Setup instructions
- **Output**: `quickstart.md`
- **Use when**: You want to help others get started quickly

### 12. **d3.implement** - Track Implementation Progress
Log implementation decisions and progress.
- **Input**: Feature directory
- **Output**: `implementation-log.md`
- **Use when**: Recording implementation progress and decisions

### 13. **d3.taskstoissues** - Convert Tasks to Issue Tracking
Convert tasks.md into issue tracker format.
- **Input**: tasks.md
- **Output**: Issue creation commands or formatted issues
- **Use when**: You want to create issues in your tracking system

## File Structure

```
d3-features/
├── 1-feature-name/
│   ├── spec.md              (Feature specification)
│   ├── plan.md              (Implementation plan)
│   ├── tasks.md             (Executable tasks)
│   ├── data-model.md        (Data structures)
│   ├── research.md          (Research findings)
│   └── implementation-log.md (Progress tracking)
├── 2-another-feature/
│   └── ...
└── ...

memory/
├── d3-constitution.md       (Project principles)
└── ...

contracts/
└── api.md                   (External contracts)
```

## How Scripts Work

Each D3 command has:
1. **Template files** (.md files in D3-templates/) that define the structure
2. **Scripts** (bash and PowerShell) that:
   - Create the file from the template
   - Replace placeholders with actual values
   - Return JSON with file paths
3. **Command templates** (d3-commands/*.md) that instruct agents to:
   - Execute the script
   - Open the generated file
   - Fill in content from your requirements
   - Confirm completion to you

## Template Placeholder Rules

Templates in D3-templates/ use these placeholders:
- `{FEATURE_NAME}` - Auto-replaced by script
- `{FEATURE_BRANCH}` - Auto-replaced by script
- `{CREATION_DATE}` - Auto-replaced by script
- `{DEVELOPER_NAME}` - Auto-replaced by script
- `{DESCRIPTION}` - Auto-replaced by script (from d3.intend)

Other sections are filled manually by the agent after script creates the file.

## Best Practices

### For Users
1. Start with `/d3.intend` to specify what you want
2. Use `/d3.plan` to think through the approach
3. Use `/d3.tasks` to break work into pieces
4. Use other commands as needed for your project

### For Agents
1. **Always execute the script first** - don't manually fill templates
2. **Fill in ALL sections** - script creates template, you fill the content
3. **Reference previous artifacts** - use spec when writing plan, use plan when writing tasks
4. **Report what you did** - tell user which sections were filled in
5. **Ask for clarification** - if requirements are ambiguous, list questions

## Version Control

All feature files should be committed to git:
```bash
git add d3-features/
git commit -m "Add/update feature: [feature-name]"
```

## Getting Help

Check the d3-commands/ directory for detailed instructions for each command.
