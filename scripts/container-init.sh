#!/usr/bin/env bash
set -euo pipefail

run_scripts_in_container() {
  local container="$1"
  local dir="$2"

  # Check if the directory exists inside the container
  if ! docker exec "$container" test -d "$dir" 2>/dev/null; then
    return 0
  fi

  # Collect .sh files in that directory
  local files
  files=$(docker exec "$container" sh -c "ls ${dir}/*.sh 2>/dev/null" || true)

  if [ -z "$files" ]; then
    return 0
  fi

  echo "  [$container] Running scripts in $dir"
  while IFS= read -r script; do
    echo "  [$container] Executing $script"
    docker exec "$container" sh "$script"
  done <<< "$files"
}

main() {
  local containers
  containers=$(docker container ls --format '{{.Names}}')

  if [ -z "$containers" ]; then
    echo "No running containers found."
    exit 0
  fi

  while IFS= read -r container; do
    echo "==> $container"
    run_scripts_in_container "$container" "/bootstrap"
    run_scripts_in_container "$container" "/install"
  done <<< "$containers"

  echo "Done."
}

main "$@"
