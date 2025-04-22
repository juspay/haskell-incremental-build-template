#!/bin/sh

# Preserve original stdout in fd 3, then redirect all stdout to stderr
exec 3>&1 1>&2

for COMMIT in $(git log -n 5 --pretty=%H); do
  echo "Testing commit $COMMIT"
  WORKTREE_DIR="temp-worktree-$COMMIT"
  git worktree add $WORKTREE_DIR $COMMIT
  cd $WORKTREE_DIR
  if nix path-info $(nix eval .#default.intermediates.outPath | tr -d '"') --store https://cache.nixos.asia/oss; then
    echo "Intermediates exist for $COMMIT"
    # Output only the commit hash to original stdout (fd 3)
    echo "$COMMIT" >&3
    git worktree remove $WORKTREE_DIR
    exit 0
  else
    echo "Intermediates do not exist for $COMMIT"
    git worktree remove $WORKTREE_DIR
  fi
  cd -
done
