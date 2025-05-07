#!/bin/sh

# Preserve original stdout in fd 3, then redirect all stdout to stderr
exec 3>&1 1>&2

repo="$1"
package_name="$2"
cache_url="$3"

for commit in $(git log -n 5 --pretty=%H); do
  echo "Testing $commit"
  # Check if the `packages.<package_name>` flake output of this commit revision is present in the cache.
  #
  # Note: Only checks for the presence, doesn't pull the path from the cache.
  if nix path-info $(nix eval github:$repo/$commit#$package_name.outPath | tr -d '"') --store $cache_url; then
    echo "Intermediates exist for $commit"
    # Output only the commit hash to original stdout (fd 3)
    echo "$commit" >&3
    exit 0
  else
    echo "Intermediates do not exist for $commit"
  fi
done
