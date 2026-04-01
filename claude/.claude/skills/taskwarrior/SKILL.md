---
name: taskwarrior
description: Work on a taskwarrior task. Reads task details and associated note to gather full context, then either plans or executes the work.
---

# Taskwarrior Skill

Use this skill when the user asks to work on, do, plan, or perform a taskwarrior task (e.g., "do task 1", "plan task 3", "execute task 2").

## Arguments

The skill receives a task ID and a mode:
- **plan**: Research and write an implementation plan into the task's note buffer.
- **execute**: Read the existing plan/context from the note buffer and start executing it.

If the user says "do task 1" or "work on task 1" without specifying, default to **execute**.
If the user says "plan task 1" or "think about task 1", use **plan**.

## Steps (both modes)

1. **Get task details**: Run `task <id> export` to get the full task JSON (description, project, tags, priority, annotations, dependencies, etc.)

2. **Read the associated note**: Get the task UUID from the export, then read the note file at `~/.task/notes/<uuid>.md`. This file may contain detailed context, instructions, or requirements for the task. If the file doesn't exist, proceed without it.

3. **Check dependencies**: If the task has dependencies (`depends` field in the JSON), run `task <dep_uuid> export` for each dependency to understand what this task depends on and whether those are completed.

4. **Mark task as started**: Run `task start <id>`.

## Plan mode

After gathering context, append a plan to the note file (`~/.task/notes/<uuid>.md`):

- Add a separator line: `──────────────────────────────────────` (a long line of `─` characters)
- Below it, write a heading `## Plan` followed by the date
- Write a clear, actionable implementation plan with numbered steps
- Reference specific files, functions, or commands where relevant
- Do NOT execute any work — only plan

## Execute mode

After gathering context:

- Read the note buffer carefully — it may contain a previously written plan
- Execute the work described in the task and/or the plan
- When the work is complete, run `task done <id>`

## Notes

- The note file is a markdown file that may contain anything: instructions, code snippets, links, requirements, etc. Treat it as the primary source of context for what needs to be done.
- If the task description or note references files or projects, explore them as needed.
