# Find Latest Cached Commit Action

This GitHub Action finds the most recent commit (from the last 5) with cached build artifacts for a specified Nix flake `packages` output.

## Dependencies

- **Nix**: Required for checking if the binary cache has intermediates cached.
- **Git**: Required for `git log` to retrieve commit history.
- **Bash**: The Action uses Bash scripting, so a Unix-like environment is required.


### Example Workflow

This example github action workflow configuration does the following:
- Install Nix
- Setup cachix (Nix store object cache)
- Find the previously cached build artifacts
- Uses the cache to incrementally build the latest version of the package

```yaml
name: CI with Cached Intermediates
on:
  pull_request:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install Nix
        uses: DeterminateSystems/nix-installer-action@v1.0.0
      - uses: cachix/cachix-action@v14
        with:
          name: mycompany
          authToken: '${{ secrets.CACHIX_AUTH_TOKEN }}'
      - name: Find Latest Cached Commit
        if: github.event_name == 'pull_request'
        id: latest_cached
        uses: ./.github/actions/find-latest-cached-commit
        with:
          # Nix store object cache used to query the cached build artifacts
          cache_url: "https://mycompany.cachix.org"
          # The package whose build artifacts are fetched and incremented on in the latest revision of the project
          package_name: "default"
      - name: Build Incrementally
        run: |
          if [ -n "${{ steps.latest_cached.outputs.commit_hash }}" ]; then
            echo "Building incrementally from commit ${{ steps.latest_cached.outputs.commit_hash }}"
            nix build .#default --override-input prev ${{ steps.latest_cached.outputs.flake_ref }}
          else
            echo "No cached intermediates found; performing full build"
            nix build .#default
          fi

