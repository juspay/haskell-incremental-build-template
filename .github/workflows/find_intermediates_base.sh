#!/bin/sh

for COMMIT in $(git log -n 5 --pretty=%H); do
  echo "Testing commit $COMMIT"
  WORKTREE_DIR="temp-worktree-$COMMIT"
  git worktree add $WORKTREE_DIR $COMMIT
  cd $WORKTREE_DIR
  if nix path-info $(nix eval .#default.intermediates.outPath | tr -d '"') --store https://cache.nixos.asia/oss; then
    echo "Intermediates exist for $COMMIT"
    echo "$COMMIT"
    git worktree remove $WORKTREE_DIR
    exit 0
  else
    echo "Intermediates do not exist for $COMMIT"
    git worktree remove $WORKTREE_DIR
  fi
  cd -
done
echo "None of the previous 5 commits have build intermediates"
exit 1
