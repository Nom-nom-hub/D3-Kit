# D3-Kit AI Agent Integration Guide

This document describes how to set up and use D3-Kit with various AI coding agents and assistants.

## Supported AI Agents

### Claude (Anthropic)
Claude Code works excellently with D3-Kit:

1. Create a new project:
   ```bash
   d3 init my-project --ai claude
   cd my-project
   ```

2. Use D3 commands in Claude Desktop or Web:
   - `/d3.intend` - Specify features with developer intent
   - `/d3.plan` - Create implementation plans
   - `/d3.tasks` - Generate executable task lists
   - `/d3.implement` - Execute implementation

3. Claude follows the structured format of D3-Kit templates automatically.

### Cursor
Cursor AI integrates seamlessly with D3-Kit:

1. Initialize project:
   ```bash
   d3 init my-project --ai cursor
   cd my-project
   ```

2. Open the project in Cursor
3. Use D3 commands in the chat panel
4. Cursor can work directly with your codebase using D3 structure

### GitHub Copilot
GitHub Copilot can leverage D3-Kit structure:

1. Initialize with Copilot support:
   ```bash
   d3 init my-project --ai copilot
   ```

2. Use D3 templates as context for code completion
3. Copilot will follow patterns from D3 specifications and plans

### Other Agents
D3-Kit works with most AI coding assistants including:
- Qwen Code
- Amazon Q Developer
- JetBrains AI
- Tabnine
- Replit Ghostwriter

## Setup Instructions

### For Claude/Cursor:
1. Install D3-Kit: `uv tool install d3-kit`
2. Initialize project: `d3 init <project-name> --ai <assistant>`
3. Use D3 commands in AI assistant chat

### For VSCode Extensions:
1. Install D3-Kit CLI and templates
2. Use the generated context files in your AI extension
3. Follow the template structure for best results

## Best Practices

### Prompt Engineering
- Use specific D3 commands to guide AI behavior
- Share generated specifications and plans as context
- Reference existing code patterns in the project

### Parallel Workflows
- Use [P] markers to indicate parallelizable tasks
- Let AI agents work on independent user stories simultaneously
- Validate completed sections independently

### Quality Assurance
- Review AI-generated code against D3 specifications
- Ensure generated code matches the intended behavior
- Use D3 validation commands to verify implementation

## Template Integration

D3-Kit templates are specifically designed for AI consumption:

- Clear, structured format
- Explicit requirements and acceptance criteria
- Parallelization markers ([P])
- Implementation guidance
- Validation instructions

AI agents can directly use these templates to generate code that matches your specifications.