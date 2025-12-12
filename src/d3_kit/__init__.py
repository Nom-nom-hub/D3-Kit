"""D3-Kit: Developer-Driven Development Framework"""

__version__ = "1.0.0"

# D3-Kit Configuration
D3_COMMANDS = {
    "specify": {
        "description": "Create or update feature specification from natural language description",
        "template": "d3-spec-template.md",
        "output": "d3-features/{number}-{name}/spec.md",
    },
    "intend": {
        "description": "Create or update feature specification from natural language description (alias for specify)",
        "template": "d3-spec-template.md",
        "output": "d3-features/{number}-{name}/spec.md",
    },
    "research": {
        "description": "Gather technical or contextual research automatically",
        "output": "d3-features/{number}-{name}/research.md",
    },
    "data": {
        "description": "Generate/update key entities & data models",
        "output": "d3-features/{number}-{name}/data-model.md",
    },
    "contracts": {
        "description": "Generate API/event contracts from the plan",
        "output": "d3-features/{number}-{name}/contracts/",
    },
    "plan": {
        "description": "Create technical implementation plan",
        "template": "d3-plan-template.md",
        "output": "d3-features/{number}-{name}/plan.md",
    },
    "tasks": {
        "description": "Generate actionable tasks from implementation plan",
        "template": "d3-tasks-template.md",
        "output": "d3-features/{number}-{name}/tasks.md",
    },
    "quickstart": {
        "description": "Produce a quickstart/validation guide to verify the feature independently",
        "output": "d3-features/{number}-{name}/quickstart.md",
    },
    "implement": {
        "description": "Execute tasks to implement the feature",
        "output": "src/ (generated code)",
    },
    "clarify": {
        "description": "Clarify underspecified areas in the specification",
        "output": "spec.md (updated)",
    },
    "analyze": {
        "description": "Analyze project artifacts for consistency",
        "output": "analysis-report.md",
    },
    "checklist": {
        "description": "Generate quality checklists for validation",
        "output": "checklists/",
    },
    "constitution": {
        "description": "Create or update project governing principles",
        "output": "memory/d3-constitution.md",
    },
    "taskstoissues": {
        "description": "Convert D3 tasks to GitHub issues for project management and tracking",
        "output": "GitHub issues (external)",
    },
}

D3_KIT_PRINCIPLES = [
    "Intent-First Development",
    "Executable Specifications",
    "Continuous Validation",
    "Task-Oriented Development",
    "Parallel Exploration",
    "Test-First Thinking",
    "Immutable Principles, Flexible Application",
    "No Speculation",
]
