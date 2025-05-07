#!/bin/sh

# Preserve original stdout in fd 3, then redirect all stdout to stderr
exec 3>&1 1>&2

repo="$1"
package_name="$2"
cache_url="$3"

for COMMIT in $(git log -n 5 --pretty=%H); do
  echo "Testing commit $COMMIT"
  # Check if the `packages.<package_name>` flake output of this commit revision is present in the cache.
  #
  # Note: Only checks for the presence, doesn't pull the path from the cache.
  if nix path-info $(nix eval $REPO/$COMMIT#$package_name.outPath | tr -d '"') --store $cache_url; then
    echo "Intermediates exist for $COMMIT"
    # Output only the commit hash to original stdout (fd 3)
    echo "$COMMIT" >&3
    exit 0
  else
    echo "Intermediates do not exist for $COMMIT"
  fi
done
