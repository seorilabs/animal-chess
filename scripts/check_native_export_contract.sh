#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
project_dir="$repo_root/godot"
presets_file="$project_dir/export_presets.cfg"

fail() {
  echo "native export contract: $*" >&2
  exit 1
}

section_value() {
  local section="$1"
  local key="$2"

  awk -v section="$section" -v key="$key" '
    $0 == section { in_section = 1; next }
    /^\[/ { in_section = 0 }
    in_section && index($0, key "=") == 1 {
      print substr($0, length(key) + 2)
      exit
    }
  ' "$presets_file"
}

require_value() {
  local section="$1"
  local key="$2"
  local expected="$3"
  local actual

  actual="$(section_value "$section" "$key")"
  [[ "$actual" == "$expected" ]] || fail "$section $key must be $expected (got ${actual:-missing})"
}

[[ -f "$presets_file" ]] || fail "missing godot/export_presets.cfg"
[[ -f "$project_dir/project.godot" ]] || fail "missing godot/project.godot"
grep -Fxq 'textures/vram_compression/import_etc2_astc=true' "$project_dir/project.godot" || fail "Android ETC2/ASTC import is not enabled"

require_value "[preset.0]" "name" '"Android"'
require_value "[preset.0]" "platform" '"Android"'
require_value "[preset.0.options]" "gradle_build/use_gradle_build" "true"
require_value "[preset.0.options]" "gradle_build/export_format" "1"
require_value "[preset.0.options]" "gradle_build/min_sdk" '"24"'
require_value "[preset.0.options]" "architectures/arm64-v8a" "true"
require_value "[preset.0.options]" "package/unique_name" '"com.seorilabs.animalchess"'
require_value "[preset.0.options]" "package/signed" "false"

while IFS= read -r resource; do
  relative_path="${resource#res://}"
  [[ -e "$project_dir/$relative_path" ]] || fail "missing referenced resource: $resource"
done < <(grep -Eo 'res://[^" ]+' "$presets_file" | sort -u)

if grep -Eq '(BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|keystore/(release|debug)(_password)?=.+|password=.+)' "$presets_file"; then
  fail "signing material must not be stored in export_presets.cfg"
fi

if [[ "${REQUIRE_GODOT_EXPORT_TEMPLATES:-0}" == "1" ]]; then
  [[ -n "${GODOT_VERSION:-}" ]] || fail "GODOT_VERSION is required when template verification is enabled"
  template_dir="${XDG_DATA_HOME:-$HOME/.local/share}/godot/export_templates/${GODOT_VERSION}.${GODOT_STATUS:-stable}"
  [[ -d "$template_dir" ]] || fail "missing Godot export templates: $template_dir"
  for template_name in android_source.zip android_release.apk; do
    [[ -s "$template_dir/$template_name" ]] || fail "missing Godot Android export template: $template_name"
  done
fi

if [[ "${VERIFY_EXPORT_PACKS:-0}" == "1" ]]; then
  command -v godot >/dev/null 2>&1 || fail "godot executable is required for export-pack verification"
  temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/animal-chess-export-contract.XXXXXX")"
  cleanup() {
    [[ -n "${temp_dir:-}" && "$temp_dir" != "/" ]] && rm -rf -- "$temp_dir"
  }
  trap cleanup EXIT
  if ! godot --headless --path "$project_dir" --export-pack Android "$temp_dir/android.pck" >"$temp_dir/android.log" 2>&1; then
    sed -n '1,200p' "$temp_dir/android.log" >&2
    fail "Android export-pack verification failed"
  fi
  if grep -Eq 'SCRIPT ERROR|ERROR:' "$temp_dir/android.log"; then
    sed -n '1,200p' "$temp_dir/android.log" >&2
    fail "Android export-pack emitted an engine error"
  fi
  [[ -s "$temp_dir/android.pck" ]] || fail "Android export-pack verification did not produce an artifact"
  artifact_sha256="$(shasum -a 256 "$temp_dir/android.pck" | awk '{print $1}')"
  echo "native export artifact: android.pck sha256=$artifact_sha256"
fi

echo "native export contract: OK"
