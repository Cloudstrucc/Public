# fix-internal-workspace-refs.sh
#!/usr/bin/env bash
set -euo pipefail

paths=(apps/* packages/*)
for d in "${paths[@]}"; do
  [ -f "$d/package.json" ] || continue
  tmp="$d/package.json.tmp"

  jq '
    def fix(ws):
      if ws == null then null
      else ws
        | with_entries(
            .value |= (if (type=="string" and (startswith("workspace:"))) then "*" else . end)
          )
      end;
    .dependencies           = fix(.dependencies)
    | .devDependencies      = fix(.devDependencies)
    | .optionalDependencies = fix(.optionalDependencies)
    | .peerDependencies     = fix(.peerDependencies)
  ' "$d/package.json" > "$tmp" && mv "$tmp" "$d/package.json"
done

echo "✔ Rewrote all workspace:* refs to *"

