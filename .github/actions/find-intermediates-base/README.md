# Find Intermediates Base Action

This GitHub Action finds the most recent commit (from the last 5) with cached build artifacts for a specified Nix flake `packages` output.

## Dependencies

- **Nix**: Required for checking if the binary cache has intermediates cached.
- **Git**: Required for `git log` to retrieve commit history.
- **Bash**: The Action uses Bash scripting, so a Unix-like environment is required.


### Example Workflow

```yaml
name: CI with Cached Intermediates
on:
  pull_request:
jobs:
  find-intermediates:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install Nix
        uses: DeterminateSystems/nix-installer-action@v1.0.0
      - name: Find Build Intermediates Base
        if: github.event_name == 'pull_request'
        id: find_build_intermediates
        uses: ./.github/actions/find-intermediates-base
        with:
          cache_url: "https://cache.nixos.org"
      - name: Build Incrementally
        run: |
          if [ -n "${{ steps.find_build_intermediates.outputs.commit_hash }}" ]; then
            echo "Building incrementally from commit ${{ steps.find_build_intermediates.outputs.commit_hash }}"
            # Add your incremental build command here
          else
            echo "No cached intermediates found; performing full build"
            # Add your full build command here
          fi

