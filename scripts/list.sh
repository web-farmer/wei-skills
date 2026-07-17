#!/usr/bin/env bash
# list.sh — list skills in this repo and their install status
#
# Usage:
#   ./scripts/list.sh
#   ./scripts/list.sh --project /path/to/app
#
# Shows for each skill under skills/:
#   name | status (installed / foreign / missing / broken) | link target

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILLS_SRC="${REPO_ROOT}/skills"
GLOBAL_TARGET="${HOME}/.claude/skills"

PROJECT_DIR=""

usage() {
  sed -n '2,10p' "$0" | sed 's/^# \?//'
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

status_of() {
  local name="$1"
  local target_dir="$2"
  local dest="${target_dir}/${name}"
  local src="${SKILLS_SRC}/${name}"

  if [[ ! -e "${dest}" && ! -L "${dest}" ]]; then
    echo "not-installed"
    return
  fi

  if [[ -L "${dest}" ]]; then
    local link
    link="$(readlink "${dest}")"
    if is_repo_symlink "${dest}"; then
      if [[ -d "${src}" ]]; then
        echo "installed"
      else
        echo "broken"
      fi
    else
      echo "foreign"
    fi
    return
  fi

  # real directory / file at destination
  echo "occupied"
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
    *)
      echo "ERROR: unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

TARGET_DIR="$(resolve_target_dir)"

echo "Repo:    ${REPO_ROOT}"
echo "Target:  ${TARGET_DIR}"
echo "---"
printf "%-24s %-14s %s\n" "NAME" "STATUS" "LINK"
printf "%-24s %-14s %s\n" "----" "------" "----"

found=0
if [[ -d "${SKILLS_SRC}" ]]; then
  for d in "${SKILLS_SRC}"/*/; do
    [[ -d "${d}" ]] || continue
    name="$(basename "${d}")"
    if [[ ! -f "${d}/SKILL.md" ]]; then
      continue
    fi
    found=1
    st="$(status_of "${name}" "${TARGET_DIR}")"
    dest="${TARGET_DIR}/${name}"
    link_info="-"
    if [[ -L "${dest}" ]]; then
      link_info="$(readlink "${dest}")"
    elif [[ -e "${dest}" ]]; then
      link_info="${dest} (not a symlink)"
    fi
    printf "%-24s %-14s %s\n" "${name}" "${st}" "${link_info}"
  done
fi

if [[ ${found} -eq 0 ]]; then
  echo "(no skills with SKILL.md under skills/)"
fi

echo "---"
echo "Status legend: installed | not-installed | foreign | occupied | broken"
