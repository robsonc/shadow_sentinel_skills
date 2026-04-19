# Shadow Sentinel Skills

Open-source skills that turn an agent harness into a practical Agent OS.

Shadow Sentinel is a growing catalog of `shadow-sentinel-*` skills for scheduling, orchestration, proactivity, and operational automation.

The core idea is simple:

> the harness provides the runtime
> the skills provide the operating system behaviors

Together, they form the foundation for a complete agent OS.

## What this is

This repository is the source of truth for Shadow Sentinel skills.

It contains:

- skills
- helpers
- templates
- examples
- lightweight docs

It does **not** contain user runtime data.

## Why it exists

Most agent runtimes are great at interactive intelligence, but weak at recurring, OS-native, operational workflows.

Shadow Sentinel fills that gap with reusable skills that make agents feel persistent, proactive, and automatable.

## Current focus

- `shadow-sentinel-schedule`
  - create and manage native scheduled jobs
  - command-first model
  - Windows-first backend today

## Positioning

Shadow Sentinel is not trying to replace an agent harness.

It is the layer that makes a harness feel like an operating system for agents.

Examples of what that means:

- schedule jobs
- recurring reports
- proactive routines
- OS-native automation patterns
- reusable operational conventions

## Repository layout

```text
shadow_sentinel_skills/
  skills/
    shadow-sentinel-schedule/
  docs/
  scripts/
```

## Runtime model

- this repo -> versioned source of truth
- installed skills -> OpenCode/other harness skill directory
- runtime data -> `%USERPROFILE%\.shadow_sentinel\`

## Status

Early, real, and already useful.

The first skill, `shadow-sentinel-schedule`, is being hardened through real Windows execution tests with native scheduled jobs.

## Contributing

Contributions are welcome, especially around:

- scheduler backends
- helpers and templates
- safe examples
- cross-platform support
- installation and sync flows

## Security note

Do not commit local runtime outputs, private reports, secrets, or machine-specific data.

## License

TBD
