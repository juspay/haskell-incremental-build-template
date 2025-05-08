# Find Intermediates Base Action

This GitHub Action finds the most recent commit (from the last 5) with cached build artifacts for a specified Nix flake `packages` output.

## Dependencies
- **Nix**: The runner must have Nix installed.
- **Git**: Required for `git log` to retrieve commit history.
- **Bash**: The Action uses Bash scripting, so a Unix-like environment is required.

## Setup Instructions
To use this Action, ensure the runner has Nix installed. You can set up Nix in your workflow with the following step:

```yaml
  # Inside `jobs.<name>.steps`
  - uses: DeterminateSystems/nix-installer-action@main
  - name: Find Build Intermediates Base
    uses: ./.github/actions/find-intermediates-base
    if: github.event_name == 'pull_request'
    id: find_build_intermediates
    with:
      cache_url: "<binary-cache-url>"
```

The step that actually runs the build can then use the commit hash (`steps.find_build_intermediates.outputs.commit_hash`) for which the intermediates exist to build incrementally.

