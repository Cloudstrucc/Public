#!/usr/bin/env bash
#
# setup-all.sh — One-shot bootstrap/fix script for the DID + Cloud Signature SaaS monorepo
# - Normalizes Yarn (Berry) + node-modules linker
# - Fixes workspace boundary issues
# - Ensures Admin Portal imports (Layout/Toaster) + ESM usage
# - Ensures Next.js transpiles internal packages
# - Adds @saas/agent dependency to admin portal
# - Cleans caches/node_modules and rebuilds in topological order
# - (Optional) Starts Mongo/Redis + dev services
#
# Usage:
#   ./tools/scripts/setup-all.sh            # do everything
#   SKIP_DOCKER=1 ./tools/scripts/setup-all.sh   # skip docker compose
#   NO_START=1   ./tools/scripts/setup-all.sh    # don’t run `yarn dev` at the end
#   KILL_PORTS=1 ./tools/scripts/setup-all.sh    # free 3000-3007 if bound
#
set -euo pipefail

BLUE='\033[0;34m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
say() { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()  { echo -e "${GREEN}[OK]${NC}   $*"; }
warn(){ echo -e "${YELLOW}[WARN]${NC} $*"; }
die() { echo -e "${RED}[ERR ]${NC} $*"; exit 1; }

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

# --- sanity checks
[ -f package.json ] || die "Run this from the monorepo root (where package.json exists). Current: $PWD"
if ! command -v node >/dev/null 2>&1; then die "Node.js not found. Install Node 20.x first."; fi

NODE_MAJOR="$(node -e 'console.log(process.versions.node.split(".")[0])')"
if [ "$NODE_MAJOR" -lt 18 ]; then die "Node >= 18 required (prefer 20.x). Found: $(node -v)"; fi

# --- normalize yarn (Berry + node-modules)
say "Configuring Yarn Berry with node-modules linker"
if ! command -v corepack >/dev/null 2>&1; then
  warn "corepack not found; continuing (Yarn 4 may not auto-manage)."
else
  corepack enable || true
fi

mkdir -p .yarn/releases
if [ ! -f ".yarn/releases/$(ls .yarn/releases 2>/dev/null || echo yarn-4.9.4.cjs)" ]; then
  say "Pinning Yarn stable"
  yarn set version stable >/dev/null 2>&1 || true
fi

# Ensure .yarnrc.yml with node-modules linker and a yarnPath
YARN_PATH_FILE=".yarn/releases/$(ls .yarn/releases | head -n1)"
if [ -z "$YARN_PATH_FILE" ]; then
  # fallback: fetch latest to ensure file exists
  yarn set version stable >/dev/null 2>&1 || true
  YARN_PATH_FILE=".yarn/releases/$(ls .yarn/releases | head -n1)"
fi

cat > .yarnrc.yml <<YRC
nodeLinker: node-modules
yarnPath: ./${YARN_PATH_FILE}
YRC
ok "Wrote .yarnrc.yml"

# --- guard against parent workspace boundary
# If a parent directory (like ../did) is a Yarn project, it can absorb this one.
say "Checking for parent Yarn project boundary conflicts"
PARENT_DIR="$(dirname "$REPO_ROOT")"
if [ -f "$PARENT_DIR/package.json" ] || [ -f "$PARENT_DIR/yarn.lock" ]; then
  warn "Parent directory looks like a Yarn project: $PARENT_DIR"
  warn "To keep this repo separate, we’ll ensure a local yarn.lock exists."
  : > "$REPO_ROOT/yarn.lock"
  ok "Created local yarn.lock to force project boundary here"
fi

# --- clean node_modules + lockfiles
say "Cleaning node_modules and lockfiles"
find . -name node_modules -type d -prune -exec rm -rf {} + || true
find . -name yarn.lock -type f -not -path "./yarn.lock" -delete || true
rm -rf .yarn/cache || true

# --- install deps
say "Installing dependencies"
yarn install

# --- ensure admin portal deps + structure
ADMIN="apps/admin-portal"
[ -d "$ADMIN" ] || die "Missing $ADMIN — expected admin portal under apps/"

say "Ensuring @saas/agent is a dependency of admin-portal"
if ! grep -q '"@saas/agent"' "$ADMIN/package.json"; then
  (cd "$ADMIN" && yarn add @saas/agent@workspace:*)
else
  ok "@saas/agent already listed in admin portal"
fi

# --- ensure Next transpiles internal packages (ESM / TS in workspaces)
say "Ensuring Next.js transpiles workspace packages"
NEXT_CFG="$ADMIN/next.config.js"
if [ ! -f "$NEXT_CFG" ]; then
  die "Missing $NEXT_CFG"
fi

if ! grep -q "transpilePackages" "$NEXT_CFG"; then
  # insert transpilePackages
  cat > "$NEXT_CFG" <<'NCFG'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  transpilePackages: ['@saas/agent','@saas/policy-engine','@saas/mip-wrapper','@saas/kv-hsm'],
};
module.exports = nextConfig;
NCFG
  ok "Wrote transpilePackages to next.config.js"
else
  ok "next.config.js already has transpilePackages"
fi

# --- ensure Layout + Toaster components and correct imports
say "Ensuring Admin UI components and imports"
mkdir -p "$ADMIN/components"

LAYOUT_FILE="$ADMIN/components/Layout.tsx"
if [ ! -f "$LAYOUT_FILE" ]; then
  cat > "$LAYOUT_FILE" <<'LAYOUT'
import Link from 'next/link';
import { ReactNode } from 'react';
import { Container, Nav, Navbar } from 'react-bootstrap';

export default function Layout({ title, children }: { title: string; children: ReactNode }) {
  return (
    <div className="d-flex" style={{ minHeight: '100vh' }}>
      <div className="bg-light border-end" style={{ width: 260 }}>
        <div className="p-3 border-bottom">
          <strong>DID + Cloud Signature</strong>
          <div className="text-muted small">Admin Portal</div>
        </div>
        <Nav className="flex-column p-2 gap-1">
          <Link href="/" className="nav-link">Dashboard</Link>
          <Link href="/orgs" className="nav-link">Organizations</Link>
          <Link href="/issuance" className="nav-link">Issue Credentials</Link>
          <Link href="/policies" className="nav-link">Policies</Link>
        </Nav>
      </div>
      <div className="flex-grow-1">
        <Navbar bg="white" className="border-bottom">
          <Container fluid>
            <Navbar.Brand className="fw-semibold">{title}</Navbar.Brand>
          </Container>
        </Navbar>
        <main className="p-4">{children}</main>
      </div>
    </div>
  );
}
LAYOUT
  ok "Created $LAYOUT_FILE"
fi

TOASTER_FILE="$ADMIN/components/toaster.tsx"
if [ ! -f "$TOASTER_FILE" ]; then
  cat > "$TOASTER_FILE" <<'TOAST'
import { createContext, useContext, useMemo, useState } from 'react';
import { Toast, ToastContainer } from 'react-bootstrap';
type ToastMsg = { id: string; title: string; body?: string; bg?: 'success'|'danger'|'info'|'warning' };
const ToasterCtx = createContext<{ push: (m: Omit<ToastMsg,'id'>)=>void }>({ push: () => {} });
export function ToasterProvider({ children }: { children: React.ReactNode }) {
  const [items, setItems] = useState<ToastMsg[]>([]);
  const push = (m: Omit<ToastMsg,'id'>) => {
    setItems(prev => [...prev, { id: String(Date.now()+Math.random()), ...m }]);
    setTimeout(() => setItems(prev => prev.slice(1)), 4000);
  };
  const v = useMemo(()=>({ push }),[]);
  return (
    <ToasterCtx.Provider value={v}>
      {children}
      <ToastContainer position="bottom-end" className="p-3">
        {items.map(t => (
          <Toast key={t.id} bg={t.bg ?? 'info'}>
            <Toast.Header closeButton={false}><strong className="me-auto">{t.title}</strong></Toast.Header>
            {t.body && <Toast.Body className="text-white">{t.body}</Toast.Body>}
          </Toast>
        ))}
      </ToastContainer>
    </ToasterCtx.Provider>
  );
}
export function useToaster(){ return useContext(ToasterCtx); }
TOAST
  ok "Created $TOASTER_FILE"
fi

# Fix imports in pages to reference components/
fix_import() {
  local file="$1"
  [ -f "$file" ] || return 0
  sed -i.bak "s#from '../src/Layout'#from '../components/Layout'#g" "$file" || true
  sed -i.bak "s#from '../../src/Layout'#from '../../components/Layout'#g" "$file" || true
  sed -i.bak "s#from '../src/toaster'#from '../components/toaster'#g" "$file" || true
  sed -i.bak "s#from '../../src/toaster'#from '../../components/toaster'#g" "$file" || true
  rm -f "${file}.bak"
}
fix_import "$ADMIN/pages/_app.tsx"
fix_import "$ADMIN/pages/index.tsx"
fix_import "$ADMIN/pages/orgs/index.tsx"
fix_import "$ADMIN/pages/issuance/index.tsx"
fix_import "$ADMIN/pages/policies/index.tsx"

# Ensure _app uses ToasterProvider
if ! grep -q "ToasterProvider" "$ADMIN/pages/_app.tsx"; then
  cat > "$ADMIN/pages/_app.tsx" <<'APP'
import type { AppProps } from 'next/app';
import 'bootstrap/dist/css/bootstrap.min.css';
import '../styles/globals.css';
import { ToasterProvider } from '../components/toaster';
export default function App({ Component, pageProps }: AppProps) {
  return (
    <ToasterProvider>
      <Component {...pageProps} />
    </ToasterProvider>
  );
}
APP
  ok "Updated _app.tsx with ToasterProvider"
fi

# --- API route: use ESM import for @saas/agent
HOLDER_DID="$ADMIN/pages/api/holder-did.ts"
if [ -f "$HOLDER_DID" ]; then
  sed -i.bak "s#require('@saas/agent')#await import('@saas/agent')#g" "$HOLDER_DID" || true
  # if commonjs style existed, convert to dynamic import block
  if ! grep -q "await import('@saas/agent')" "$HOLDER_DID"; then
    cat > "$HOLDER_DID" <<'HDID'
import type { NextApiRequest, NextApiResponse } from 'next';
export default async function handler(_req: NextApiRequest, res: NextApiResponse) {
  try {
    const { createDIDAgent } = await import('@saas/agent');
    const a = createDIDAgent();
    const id = await a.didManagerCreate({ provider: 'did:key', alias: 'holder-ui' });
    res.json({ did: id.did });
  } catch (e: any) {
    res.status(500).json({ error: String(e?.message || e) });
  }
}
HDID
  fi
  rm -f "${HOLDER_DID}.bak"
  ok "Ensured holder-did API uses ESM import"
fi

# --- add predev hook to build packages before admin dev (optional)
if ! grep -q '"predev"' "$ADMIN/package.json"; then
  say "Adding predev hook to admin portal"
  node - <<'NODE'
const fs=require('fs');const p='./apps/admin-portal/package.json';
const j=JSON.parse(fs.readFileSync(p,'utf8'));
j.scripts=j.scripts||{}; j.scripts.predev=j.scripts.predev||'yarn build:packages';
fs.writeFileSync(p, JSON.stringify(j,null,2));
NODE
  ok "Added predev script"
fi

# --- build packages topologically
say "Building workspace packages (topological)"
if yarn run -s build:packages >/dev/null 2>&1; then
  yarn run build:packages
else
  yarn workspaces foreach -At --topological run build || true
fi

# --- optional: start docker deps (Mongo/Redis)
if [ "${SKIP_DOCKER:-0}" -ne 1 ]; then
  if [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
    say "Starting docker services (mongodb, redis)"
    docker compose up -d mongodb redis || docker-compose up -d mongodb redis || warn "Docker compose not available/skipped"
  else
    warn "No docker-compose file found; skipping DBs"
  fi
fi

# --- free dev ports (optional)
if [ "${KILL_PORTS:-0}" -eq 1 ]; then
  say "Freeing dev ports 3000-3007"
  for p in 3000 3001 3002 3003 3004 3005 3006 3007; do
    PID=$(lsof -ti tcp:"$p" || true)
    [ -n "$PID" ] && kill -9 $PID || true
  done
  ok "Ports cleared"
fi

# --- final install to ensure link after changes
say "Final yarn install to ensure workspace links"
yarn install

# --- start dev (unless NO_START=1)
if [ "${NO_START:-0}" -ne 1 ]; then
  say "Starting all dev services (Ctrl+C to stop)"
  yarn dev
else
  ok "Setup completed. Skipping dev start (NO_START=1)"
fi

ok "All done! ✔"

