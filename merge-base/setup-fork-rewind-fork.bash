#!/usr/bin/env bash


cat <<README
This script will create the following git repository history in the directory
fork-rewind-fork.

                    o---B2
                   /
   ---o---o---B1--o---o---o---B (origin/master)
           \
            B0
             \
              D0---D1---D (topic)

taken from git-merge-base(1)

It will include tags for all labeled points.

README

set -euo pipefail

set -x

mk_commit() {
  local -r name=$1
  local -r desc=$2

  date > "$name"
  git add "$name"
  git commit -m "$desc"
}

mk_root() {
  local -ri root=$1
  mk_commit "root${root}" "root + ${root}"
}

cd "$(dirname "${BASH_SOURCE[0]}")"

rm -rf fork-rewind-fork
mkdir fork-rewind-fork
cd fork-rewind-fork

###### Main branch
git init
touch .gitignore
git add .gitignore
git commit -m "Initial commit"

mk_root 1
mk_root 2
mk_commit B0 "B0 - Topic fork point - root + 3"
git tag B0

###### topic branch
git sw -c topic

mk_commit D0 "D0 (topic)"
git tag D0

mk_commit D1 "D1 (topic)"
git tag D1

mk_commit D "D - tip of topic branch"
git tag D

##### main branch
git sw main

# We are at B0
# Remove B0 from main.
git reset --hard B0~1

mk_commit B1 "B1 - root + 3"
git tag B1

mk_root 4

##### unnamed B branch
git sw -c unnamed

mk_commit "unnamed1" "unnamed fork + 1"
mk_commit B2 "B2 - tip of unnamed branch - unnamed fork + 2"

##### main branch
git sw main

mk_root 5
mk_root 6

mk_commit B "B - tip of main branch - root + 7"

# EOF
