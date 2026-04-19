# Shadow Sentinel Skills

Open-source skills for turning agent shells into practical, scheduled, OS-native automation systems.

`shadow-sentinel-*` is an ecosystem of installable skills focused on one idea:

> Let agent runtimes do the intelligence. Let skills handle the orchestration, conventions, and operational glue.

This repository is the source of truth for the Shadow Sentinel skills catalog.

## Vision

Most agent tools are excellent at interactive work, but they stop where operating-system automation begins.

Shadow Sentinel Skills fills that gap by packaging reusable skills, helpers, templates, and examples for:

- scheduled jobs
- recurring reviews
- proactive workflows
- OS-native automation patterns
- safe operational conventions

The project is intentionally pragmatic:

- skills first
- native scheduler first
- command-first execution model
- minimal hidden magic
- explicit manifests, outputs, and logs

## What This Repository Is

This repository contains:

- versioned skills
- platform references
- helpers
- templates
- examples
- documentation and test plans

This repository does **not** store runtime data from user machines.

## Design Principles

### 1. Executor-first

The skill should not reimplement the intelligence of the underlying executor.

If the executor is:

- `opencode`
- `claude`
- `gh`
- `python`
- `pwsh`
- `node`

then the skill should focus on scheduling, packaging, validation, and lifecycle management.

### 2. Command-first

Jobs are modeled around commands, not around one specific agent runtime.

That means a job can schedule:

- `opencode run ...`
- `gh issue list ...`
- `pwsh -File ...`
- `python script.py`
- any other CLI command supported by the user environment

### 3. Native scheduler-first

Shadow Sentinel prefers the scheduler already present on the user machine.

- Windows -> Task Scheduler via PowerShell `ScheduledTasks`
- Linux -> `systemd`/`cron`
- macOS -> `launchd`

### 4. Helpers over fragile shell improvisation

When a platform has sharp edges, the project favors:

- helpers
- templates
- generated scripts
- explicit validation flows

instead of asking the LLM to improvise every low-level operational detail from scratch.

## Current Status

Current flagship skill:

- `shadow-sentinel-schedule`

Current maturity:

- command-first architecture defined
- Windows-first backend significantly improved
- official Windows helpers, templates, and examples included
- safe registration flow established for scheduled jobs on Windows
- OpenCode-specific Windows template now included as an official pattern

## Repository Layout

```text
shadow_sentinel_skills/
  README.md
  CHANGELOG.md
  VERSION
  skills/
    shadow-sentinel-schedule/
      SKILL.md
      WORKFLOW.md
      PERSISTENCE.md
      reference/
      helpers/
      templates/
      examples/
  docs/
    reports/
    test-plans/
  scripts/
```

## Installed vs Versioned Files

There are three distinct layers in the Shadow Sentinel model.

### 1. Versioned source of truth

This repository.

It contains the versioned source for skills and their operational assets.

### 2. Installed skills

Typically installed into the OpenCode global skills directory, for example:

```text
%USERPROFILE%\.config\opencode\skills\
```

### 3. Runtime data

Runtime manifests, generated scripts, outputs, logs, and state live outside the repository, typically in:

```text
%USERPROFILE%\.shadow_sentinel\
```

This separation is intentional and important.

## Featured Skill: `shadow-sentinel-schedule`

`shadow-sentinel-schedule` creates and manages recurring OS-native jobs from CLI commands.

It is built around a simple contract:

- understand the user intent
- model the command
- create the job manifest
- materialize it through the native scheduler
- validate it end to end

The skill is not "an agent scheduler" in the narrow sense.
It is a scheduler skill for commands in general.

That means it can schedule:

- OpenCode jobs
- GitHub CLI reports
- PowerShell diagnostics
- Python scripts
- other read-only or operational commands

## Windows Strategy

Windows is the most mature target in the repository today.

Official strategy:

- backend: PowerShell `ScheduledTasks`
- registration: `powershell.exe -File <register-script.ps1>`
- runners: generated in `%USERPROFILE%\.shadow_sentinel\skills\generated\`
- validation: `inspect-task.ps1` + `run-task-now.ps1` + stdout/stderr + `LastTaskResult`

Important operational rule:

- rich payloads are allowed
- fragile inline shell invocations are not

In practice, this means:

- generate a runner
- generate a register script when needed
- avoid rich `powershell -Command "..."` flows for task registration

## Why This Project Exists

Because the missing layer in most agent ecosystems is not raw intelligence.

It is operational discipline.

Shadow Sentinel Skills aims to provide:

- reusable conventions
- portable manifests
- safe examples
- platform-specific helpers
- battle-tested scheduling patterns

so that building automation on top of agent runtimes becomes boring in the best possible way.

## Roadmap

Near term:

- keep hardening `shadow-sentinel-schedule`
- add more safe test scenarios across multiple CLIs
- improve install/sync workflow for OpenCode
- reduce Windows edge cases around quoting and validation timing

Later:

- Linux backend maturity
- macOS backend maturity
- more Shadow Sentinel skills beyond scheduling

## Contributing

Contributions are welcome, especially around:

- scheduler backends
- Windows hardening
- examples for real-world CLIs
- safe testing patterns
- installation and sync flows

When contributing, prefer:

- explicit manifests
- portable examples
- no machine-specific paths
- no private runtime data

## Security and Privacy

This repository should remain safe to publish publicly.

Do not commit:

- local runtime outputs
- machine-specific secrets
- private reports
- local scheduler state
- user-specific environment details beyond documented placeholders

## License

License to be defined.

Until then, treat the repository as source-controlled project code pending final open-source licensing.
