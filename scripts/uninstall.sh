#!/usr/bin/env bash
# uninstall.sh — remove symlinks created by this repo's install.sh
#
# Usage:
#   ./scripts/uninstall.sh                  # remove all repo-managed skill links (global)
#   ./scripts/uninstall.sh hello-world      # remove one skill link (global)
#   ./scripts/uninstall.sh --project /path  # remove links under project .claude/skills
#   ./scripts/uninstall.sh --project /path hello-world
#
# Only removes symlinks that point into this repository's skills/ directory.
# Never deletes real directories or foreign symlinks.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILLS_SRC="${REPO_ROOT}/skills"
GLOBAL_TARGET="${HOME}/.claude/skills"

PROJECT_DIR=""
SKILL_NAMES=()

usage() {
  sed -n '2,12p' "$0" | sed 's/^# \?//'
}

resolve_target_dir() {
  if [[ -n "${PROJECT_DIR}" ]]; then
    echo "${PROJECT_DIR}/.claude/skills"
  else
    echo "${GLOBAL_TARGET}"
  fi
}

is_repo_symlink() {
  local path="$1"
  if [[ ! -L "${path}" ]]; then
    return 1
  fi
  local real
  real="$(readlink "${path}" 2>/dev/null || true)"
  [[ "${real}" == "${SKILLS_SRC}/"* ]] || [[ "${real}" == "${REPO_ROOT}/skills/"* ]]
}

# uninstall_one <name> <target_dir>
uninstall_one() {
  local name="$1"
  local target_dir="$2"
  local dest="${target_dir}/${name}"

  if [[ ! -e "${dest}" && ! -L "${dest}" ]]; then
    echo "SKIP: ${name} — not installed at ${dest}"
    return 0
  fi

  if is_repo_symlink "${dest}"; then
    rm -f "${dest}"
    echo "OK:   removed ${dest}"
    return 0
  fi

  if [[ -L "${dest}" ]]; then
    echo "SKIP: ${name} — symlink points elsewhere: $(readlink "${dest}")"
    return 0
  fi

  echo "SKIP: ${name} — not a symlink from this repo: ${dest}"
  return 0
}

# collect_installed_from_repo <target_dir> — names of repo-managed links
collect_installed_from_repo() {
  local target_dir="$1"
  local d
  [[ -d "${target_dir}" ]] || return 0
  for d in "${target_dir}"/*; do
    [[ -e "${d}" || -L "${d}" ]] || continue
    if is_repo_symlink "${d}"; then
      basename "${d}"
    fi
  done
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --project)
      if [[ $# -lt 2 ]]; then
        echo "ERROR: --project requires a directory argument" >&2
        exit 1
      fi
      PROJECT_DIR="$2"
      shift 2
      ;;
    --*)
      echo "ERROR: unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      SKILL_NAMES+=("$1")
      shift
      ;;
  esac
done

TARGET_DIR="$(resolve_target_dir)"

if [[ ${#SKILL_NAMES[@]} -eq 0 ]]; then
  while IFS= read -r n; do
    [[ -n "${n}" ]] && SKILL_NAMES+=("${n}")
  done < <(collect_installed_from_repo "${TARGET_DIR}")
fi

if [[ ${#SKILL_NAMES[@]} -eq 0 ]]; then
  echo "No repo-managed skill links found under ${TARGET_DIR}"
  exit 0
fi

echo "Uninstalling from: ${TARGET_DIR}"
echo "Repo: ${REPO_ROOT}"
echo "---"

for name in "${SKILL_NAMES[@]}"; do
  uninstall_one "${name}" "${TARGET_DIR}"
done

echo "---"
echo "Done."
