#!/usr/bin/env bash
# install.sh — symlink skills from this repo into Claude Code discover paths
#
# Usage:
#   ./scripts/install.sh                  # install all skills (global)
#   ./scripts/install.sh hello-world      # install one skill (global)
#   ./scripts/install.sh --project /path  # install all into project .claude/skills
#   ./scripts/install.sh --project /path hello-world
#
# Options:
#   --project <dir>   Install into <dir>/.claude/skills instead of ~/.claude/skills
#   -h, --help        Show help
#
# Behavior:
#   - Creates symlink: <target>/<name> -> <repo>/skills/<name>
#   - Skips if target exists and is not a symlink created by this repo
#   - Replaces if target is already a symlink pointing into this repo

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILLS_SRC="${REPO_ROOT}/skills"
GLOBAL_TARGET="${HOME}/.claude/skills"

PROJECT_DIR=""
SKILL_NAMES=()

usage() {
  sed -n '2,16p' "$0" | sed 's/^# \?//'
}

# resolve_target_dir — decide global vs project install path
resolve_target_dir() {
  if [[ -n "${PROJECT_DIR}" ]]; then
    echo "${PROJECT_DIR}/.claude/skills"
  else
    echo "${GLOBAL_TARGET}"
  fi
}

# is_repo_symlink <path> — true if path is a symlink into this repo's skills/
is_repo_symlink() {
  local path="$1"
  if [[ ! -L "${path}" ]]; then
    return 1
  fi
  local real
  real="$(readlink "${path}" 2>/dev/null || true)"
  [[ "${real}" == "${SKILLS_SRC}/"* ]] || [[ "${real}" == "${REPO_ROOT}/skills/"* ]]
}

# install_one <name> <target_dir> — symlink a single skill
install_one() {
  local name="$1"
  local target_dir="$2"
  local src="${SKILLS_SRC}/${name}"
  local dest="${target_dir}/${name}"

  if [[ ! -d "${src}" ]]; then
    echo "ERROR: skill not found: ${name} (${src})" >&2
    return 1
  fi

  if [[ ! -f "${src}/SKILL.md" ]]; then
    echo "ERROR: missing SKILL.md in ${src}" >&2
    return 1
  fi

  mkdir -p "${target_dir}"

  if [[ -e "${dest}" || -L "${dest}" ]]; then
    if is_repo_symlink "${dest}"; then
      # already installed from this repo — refresh link
      rm -f "${dest}"
    elif [[ -L "${dest}" ]]; then
      echo "SKIP: ${name} — symlink exists but points elsewhere: $(readlink "${dest}")"
      return 0
    else
      echo "SKIP: ${name} — path exists and is not a symlink from this repo: ${dest}"
      return 0
    fi
  fi

  ln -s "${src}" "${dest}"
  echo "OK:   ${name} -> ${dest}"
}

# collect_skill_names — all dirs under skills/ that contain SKILL.md
collect_skill_names() {
  local names=()
  local d
  for d in "${SKILLS_SRC}"/*/; do
    [[ -d "${d}" ]] || continue
    local base
    base="$(basename "${d}")"
    if [[ -f "${d}/SKILL.md" ]]; then
      names+=("${base}")
    fi
  done
  printf '%s\n' "${names[@]}"
}

# --- parse args ---
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

if [[ -n "${PROJECT_DIR}" && ! -d "${PROJECT_DIR}" ]]; then
  echo "ERROR: project directory does not exist: ${PROJECT_DIR}" >&2
  exit 1
fi

TARGET_DIR="$(resolve_target_dir)"

if [[ ${#SKILL_NAMES[@]} -eq 0 ]]; then
  while IFS= read -r n; do
    [[ -n "${n}" ]] && SKILL_NAMES+=("${n}")
  done < <(collect_skill_names)
fi

if [[ ${#SKILL_NAMES[@]} -eq 0 ]]; then
  echo "No skills found under ${SKILLS_SRC}"
  exit 0
fi

echo "Installing skills into: ${TARGET_DIR}"
echo "Repo: ${REPO_ROOT}"
echo "---"

failed=0
for name in "${SKILL_NAMES[@]}"; do
  if ! install_one "${name}" "${TARGET_DIR}"; then
    failed=1
  fi
done

echo "---"
if [[ ${failed} -ne 0 ]]; then
  echo "Finished with errors."
  exit 1
fi
echo "Done."
