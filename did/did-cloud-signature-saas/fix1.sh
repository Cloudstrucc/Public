# 1) Ensure this folder has its own Yarn release (the last command saved it one level up)
mkdir -p .yarn/releases
if [ -f ../.yarn/releases/yarn-4.9.4.cjs ]; then
  cp ../.yarn/releases/yarn-4.9.4.cjs .yarn/releases/
fi

# 2) Point .yarnrc.yml at the local release and use node_modules linker
cat > .yarnrc.yml <<'YML'
nodeLinker: node-modules
yarnPath: .yarn/releases/yarn-4.9.4.cjs
YML

# 3) Make THIS directory a standalone Yarn root (prevents walking up to ../did)
touch yarn.lock

# 4) Clean any leftovers (zsh-safe)
find . -name node_modules -type d -prune -exec rm -rf {} +
find . -name .pnp.cjs -type f -delete 2>/dev/null || true
find . -name .pnp.loader.mjs -type f -delete 2>/dev/null || true

# 5) Install
yarn install

# 6) Build shared packages then apps
yarn build:packages
yarn build:apps   # optional

# 7) Run dev
yarn dev

