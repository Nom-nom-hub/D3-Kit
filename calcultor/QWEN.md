# Qwen Code - D3-Kit Integration Instructions

## How D3 Commands Work in Qwen Code

When you use any `/d3.*` command in Qwen Code:

### Phase 1: Script Execution
1. The command will run a PowerShell or bash script
2. The script creates a template file (spec.md, plan.md, tasks.md, etc.)
3. The script returns JSON with the file path

### Phase 2: File Editing (THE IMPORTANT PART)
**This is where most agents fail. You must:**

4. **Open the file** at the path provided in the JSON response
5. **Edit the file content** - replace bracketed placeholders with actual content
6. **Save the file** after making changes
7. **Report back** to the user with details of what you filled in

## Why This is Critical

The scripts ONLY create templates with empty sections like:
```
- **Developer Intent**: [What are you trying to achieve?]
- [ ] Requirement 1: [Specific, measurable requirement]
```

These brackets are NOT auto-filled. You must manually replace them with content based on the user's description.

## Example: /d3.intend

### What NOT to do:
```
✓ Created spec.md for feature: 1-calculator
  Location: d3-features/1-calculator/spec.md
(User says: But you didn't fill anything in!)
```

### What TO do:
```
✓ Created spec.md for feature: 1-calculator
  Location: d3-features/1-calculator/spec.md

✓ FILLED IN:
  • Developer Intent: Offline calculator with unique interface
  • Functional Requirements: 5 requirements (offline, unique UI, HTML-based, operations, offline-first)
  • Edge Cases: 5 clarifications (operations scope, precision, history, mobile, browsers)
  • Key Entities: Calculator State, History, User Interaction
  • Success Criteria: 4 metrics (correct math, unique UI, offline, fast load)

⚠ Clarifications needed:
  • Scientific functions or basic 4 operations only?
  • Mobile device support?
  • Which browsers must work?
```

## File Operations in Qwen

Qwen Code should be able to:
- Read files with `fs.readFile()` or similar
- Edit files by replacing content sections
- Write files with updated content
- Report file locations and changes

## Commands That Require File Editing

These commands create templates that MUST be edited:

1. `/d3.intend` → Edit spec.md with requirements
2. `/d3.plan` → Edit plan.md with design approach
3. `/d3.tasks` → Edit tasks.md with specific tasks
4. `/d3.data` → Edit data-model.md with entity definitions
5. `/d3.research` → Edit research.md with findings
6. `/d3.contracts` → Edit api.md with contracts
7. `/d3.quickstart` → Edit quickstart.md with setup steps
8. `/d3.implement` → Edit implementation-log.md with progress

## Commands That Auto-Generate Reports

These commands just create output, no manual editing needed:
- `/d3.clarify` → Lists ambiguities
- `/d3.analyze` → Reports consistency issues
- `/d3.checklist` → Creates validation checklist
- `/d3.constitution` → Documents principles
- `/d3.taskstoissues` → Converts tasks to issues

## Quick Checklist for Qwen

When running any `/d3.*` command:

- [ ] Script executed successfully
- [ ] JSON response shows file path
- [ ] Did I open that file?
- [ ] Did I find bracketed placeholders?
- [ ] Did I replace them with actual content?
- [ ] Did I save the file?
- [ ] Did I report to user what was filled in?

If any of these are NO, go back and do it.

## File Locations

All features are created in:
```
calcultor/d3-features/[NUMBER]-[FEATURE-NAME]/
├── spec.md              ← From /d3.intend
├── plan.md              ← From /d3.plan
├── tasks.md             ← From /d3.tasks
├── data-model.md        ← From /d3.data
├── research.md          ← From /d3.research
└── implementation-log.md ← From /d3.implement
```

Shared files:
```
calcultor/
├── memory/d3-constitution.md  ← From /d3.constitution
├── contracts/api.md           ← From /d3.contracts
└── quickstart.md              ← From /d3.quickstart
```

## Example: Complete /d3.intend Workflow

**User input:**
```
/d3.intend a calculator in html that has a nice unique interface and works offline
```

**What Qwen should do:**

1. ✓ Execute script: `powershell -ExecutionPolicy Bypass -File ".d3/scripts/powershell/d3-intend.ps1" "a calculator..."`
2. ✓ Get JSON response with spec_file path
3. ✓ **Open that file** (e.g., `calcultor/d3-features/1-a-calculator-in-html/spec.md`)
4. ✓ **Find bracketed sections** like `[What are you trying to achieve technically with a-calculator-in-html?]`
5. ✓ **Replace with actual content** based on user's description
6. ✓ **Save the file**
7. ✓ **Report back** with what was filled in and what clarifications are needed

**Expected report:**
```
✓ Created spec.md for feature: 1-a-calculator-in-html
  Location: calcultor/d3-features/1-a-calculator-in-html/spec.md
  
✓ FILLED IN:
  • Purpose: "a calculator in html that has a nice unique interface and works offline"
  • Developer Intent: Create offline-capable calculator with innovative interface
  • Primary Scenario: User calculates math problems without internet
  • Functional Requirements: 
    - Offline functionality (no network required)
    - Unique/innovative interface design
    - HTML/CSS/JavaScript implementation
    - Basic math operations (+, -, *, /)
  • Key Entities: Calculator State, Calculation History
  • Success Criteria: Works offline, unique UI, correct calculations, fast loading

⚠ Clarifications needed from user:
  • Should it support advanced math (sin, cos, etc.)?
  • Save calculation history?
  • Mobile device support needed?
  • Specific browsers to support?
```

That's a complete `/d3.intend` execution.
