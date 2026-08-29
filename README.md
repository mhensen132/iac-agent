# Sandboxed IaC Automation Agent

An AI agent that proposes infrastructure changes to a KVM lab environment as
GitHub pull requests, sandboxed in a rootless Podman container.

## Development approach

I built this project in collaboration with Claude (Anthropic's AI assistant)
as a learning exercise. Claude helped with architecture decisions, explained
concepts I was new to (KVM, rootless containers, Terraform providers), and
suggested next steps when I got stuck.

I made every decision, ran every command, and did all the troubleshooting on
my own hardware. The collaboration was closer to pair programming with a
patient senior engineer than "AI wrote it for me" — I understand what each
piece does and why it's there.

The working log in NOTES.md captures the real process, including mistakes,
detours, and things I got wrong the first time.

## Status

In development. See NOTES.md for working log.

## Stack

- AlmaLinux 10 (host)
- KVM/libvirt (virtualization)
- Rootless Podman (agent sandbox)
- Terraform + libvirt provider (IaC)
- Python + Claude API (agent)
- GitHub Actions (CI/PR flow)

## Security model

Agent has no infrastructure credentials. It reads and writes Terraform files
in a git repo and opens PRs. A human reviews and merges. Merge triggers apply
via a self-hosted runner on the host.

More detail coming as the project develops.
