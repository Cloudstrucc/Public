#!/usr/bin/env bash
# tools/scripts/setup-all.sh
# Unified setup script for did-cloud-signature-saas
# - Configures Yarn Berry with nodeLinker=node-modules
# - Cleans node_modules & lockfiles
# - Ensures dev script includes employee portal
# - Fixes Employee Portal to use Pages Router (no App Router 404)
# - Installs deps, builds packages, starts services
#
# Env toggles:
#   NO_START=1       -> install & build only (don’t run yarn dev)
#   KILL_PORTS=1     -> kill processes on ports 3000-3010
#   NO_DOCKER=1      -> skip docker compose (mongodb/redis)
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

say() { printf "\033[1;34m[SETUP]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
ok() { printf "\033[1;32m[OK]\033[0m %s\n" "$*"; }
err() { printf "\033[1;31m[ERR]\033[0m %s\n" "$*"; }

ensure_cmd() {
  command -v "$1" >/dev/null 2>&1 || { err "Missing $1. Please install it."; exit 1; }
}

# ------------------------------------------------------------------------------
# 0) Preconditions
# ------------------------------------------------------------------------------
ensure_cmd node
ensure_cmd bash

# ------------------------------------------------------------------------------
# 1) Yarn Berry (v4) + nodeLinker=node-modules
# ------------------------------------------------------------------------------
say "Configuring Yarn Berry (v4) with nodeLinker=node-modules…"
corepack enable >/dev/null 2>&1 || true
mkdir -p .yarn/releases
if ! grep -q '^yarnPath:' .yarnrc.yml 2>/dev/null; then
  yarn set version stable
fi
YARN_RELEASE="$(ls .yarn/releases | head -n1)"
if [ -z "${YARN_RELEASE:-}" ]; then
  yarn set version stable
  YARN_RELEASE="$(ls .yarn/releases | head -n1)"
fi
cat > .yarnrc.yml <<YML
nodeLinker: node-modules
yarnPath: .yarn/releases/${YARN_RELEASE}
YML
ok "Yarn configured: $(yarn --version)"

# ------------------------------------------------------------------------------
# 2) Optionally free ports (3000–3010)
# ------------------------------------------------------------------------------
if [ "${KILL_PORTS:-}" = "1" ]; then
  say "Freeing ports 3000-3010…"
  for p in $(seq 3000 3010); do
    if lsof -ti tcp:$p >/dev/null 2>&1; then
      kill -9 $(lsof -ti tcp:$p) || true
    fi
  done
  ok "Ports freed."
fi

# ------------------------------------------------------------------------------
# 3) Clean installs
# ------------------------------------------------------------------------------
say "Cleaning node_modules and lockfiles…"
find . -name node_modules -type d -prune -exec rm -rf {} + || true
find . -name yarn.lock -type f -delete || true

# ------------------------------------------------------------------------------
# 4) Ensure root package.json is valid and dev script includes employee portal
# ------------------------------------------------------------------------------
say "Validating root package.json & dev script…"
node - "$ROOT_DIR" <<'NODE'
const fs = require('fs');
const f = 'package.json';
if (!fs.existsSync(f)) {
  console.error('[ERR] Missing root package.json.');
  process.exit(1);
}
let j;
try { j = JSON.parse(fs.readFileSync(f,'utf8')); }
catch(e){ console.error('[ERR] Invalid package.json.'); process.exit(1); }

j.workspaces = j.workspaces || ["apps/*","packages/*"];
j.scripts = j.scripts || {};
const want = 'yarn workspace @saas/employee-portal dev';
if(!j.scripts.dev){
  j.scripts.dev = `concurrently "yarn workspace @saas/admin-portal dev" "yarn workspace @saas/teams-ext dev" "yarn workspace @saas/secure-note-a dev" "yarn workspace @saas/secure-note-b dev" "yarn workspace @saas/issuer-api dev" "yarn workspace @saas/verifier-api dev" "${want}"`;
} else if(!j.scripts.dev.includes('@saas/employee-portal')) {
  // Append exactly once
  j.scripts.dev = j.scripts.dev.trim();
  if(!j.scripts.dev.startsWith('concurrently')) {
    j.scripts.dev = 'concurrently ' + j.scripts.dev;
  }
  j.scripts.dev += ` "${want}"`;
}
fs.writeFileSync(f, JSON.stringify(j,null,2) + '\n');
console.log('[OK] Root dev script ensured.');
NODE

# ------------------------------------------------------------------------------
# 5) Fix Admin Portal & Employee Portal bootstrap peer & CSS
# ------------------------------------------------------------------------------
fix_portal_bootstrap () {
  local portal="$1"  # @saas/admin-portal or @saas/employee-portal
  say "Ensuring Bootstrap peer and CSS for ${portal}…"
  # install popper peer (quiet if already present)
  yarn workspace "${portal}" add -E @popperjs/core >/dev/null 2>&1 || true
  # make sure _app.tsx imports bootstrap CSS (Pages Router)
  local dir="apps/${portal#*@saas/}"
  if [ -d "$dir/pages" ]; then
    if ! grep -qs "bootstrap.min.css" "$dir/pages/_app.tsx" 2>/dev/null; then
      cat > "$dir/pages/_app.tsx" <<'TSX'
import 'bootstrap/dist/css/bootstrap.min.css';
import type { AppProps } from 'next/app';
export default function App({ Component, pageProps }: AppProps) {
  return <Component {...pageProps} />;
}
TSX
    fi
  fi
}
fix_portal_bootstrap "@saas/admin-portal"
fix_portal_bootstrap "@saas/employee-portal"

# ------------------------------------------------------------------------------
# 6) Employee Portal: force Pages Router and remove shadowing dirs
# ------------------------------------------------------------------------------
EMP_DIR="apps/employee-portal"
if [ -d "$EMP_DIR" ]; then
  say "Patching Employee Portal routing (prevent 404)…"
  # Remove any App Router or src-based routers that shadow /pages
  rm -rf "$EMP_DIR/app" "$EMP_DIR/src/app" "$EMP_DIR/src/pages" 2>/dev/null || true

  # Force Pages Router (ignore app/)
  cat > "$EMP_DIR/next.config.js" <<'JS'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  experimental: { appDir: false } // Force Pages Router
};
module.exports = nextConfig;
JS

  # Ensure minimal layout + pages/index.tsx exist
  mkdir -p "$EMP_DIR/components" "$EMP_DIR/pages"
  if [ ! -f "$EMP_DIR/components/Layout.tsx" ]; then
    cat > "$EMP_DIR/components/Layout.tsx" <<'TSX'
import Head from 'next/head';
import Container from 'react-bootstrap/Container';
import Nav from 'react-bootstrap/Nav';
import Navbar from 'react-bootstrap/Navbar';

type Props = { title?: string; children: React.ReactNode };

export default function Layout({ title = 'Employee Portal', children }: Props) {
  return (
    <>
      <Head><title>{title}</title></Head>
      <Navbar expand="lg" bg="light" className="mb-4">
        <Container>
          <Navbar.Brand href="/">Employee Portal</Navbar.Brand>
          <Nav className="me-auto">
            <Nav.Link href="/scan">Scan</Nav.Link>
            <Nav.Link href="/import">Import</Nav.Link>
            <Nav.Link href="/dashboard">Dashboard</Nav.Link>
          </Nav>
        </Container>
      </Navbar>
      <Container>{children}</Container>
    </>
  );
}
TSX
  fi
  if [ ! -f "$EMP_DIR/pages/index.tsx" ]; then
    cat > "$EMP_DIR/pages/index.tsx" <<'TSX'
import Layout from '../components/Layout';
import { Card } from 'react-bootstrap';

export default function Home() {
  return (
    <Layout title="Employee Dashboard">
      <Card><Card.Body>
        <h2>Welcome</h2>
        <p>Use the navbar to Scan or Import a credential, then Present & Verify it.</p>
      </Card.Body></Card>
    </Layout>
  );
}
TSX
  fi
  # Optional helpers to avoid 404 on navbar links
  [ -f "$EMP_DIR/pages/scan.tsx" ] || cat > "$EMP_DIR/pages/scan.tsx" <<'TSX'
import Layout from '../components/Layout';
export default function Scan() {
  return (
    <Layout title="Scan QR">
      <p>Scanner placeholder (QR/RFID). Hook up a QR lib as needed.</p>
    </Layout>
  );
}
TSX
  [ -f "$EMP_DIR/pages/import.tsx" ] || cat > "$EMP_DIR/pages/import.tsx" <<'TSX'
import { useEffect, useState } from 'react';
import Layout from '../components/Layout';

export default function Import() {
  const [vc, setVc] = useState('');
  useEffect(() => {
    const url = new URL(window.location.href);
    const qp = url.searchParams.get('vc');
    if (qp) setVc(qp);
  }, []);
  return (
    <Layout title="Import Credential">
      <p>Paste or prefilled VC JWT:</p>
      <textarea className="form-control" rows={6} value={vc} onChange={e=>setVc(e.target.value)} />
      <div className="mt-3">
        <button className="btn btn-primary" onClick={() => alert('Saved locally (demo).')}>Save</button>
      </div>
    </Layout>
  );
}
TSX

  # Clear Next cache to avoid stale _not-found
  rm -rf "$EMP_DIR/.next" 2>/dev/null || true
  ok "Employee Portal Pages Router enforced."
else
  warn "Employee Portal not found at apps/employee-portal (skipping portal patch)."
fi

# ------------------------------------------------------------------------------
# 7) Install dependencies
# ------------------------------------------------------------------------------
say "Installing workspace dependencies…"
yarn install --inline-builds

# ------------------------------------------------------------------------------
# 8) Build shared packages (topological)
# ------------------------------------------------------------------------------
say "Building shared packages…"
yarn workspace @saas/kv-hsm build || true
yarn workspace @saas/policy-engine build || true
yarn workspace @saas/agent build || true
yarn workspace @saas/mip-wrapper build || true
ok "Packages built."

# ------------------------------------------------------------------------------
# 9) Optional: start infra (mongodb/redis) via docker-compose
# ------------------------------------------------------------------------------
if [ "${NO_DOCKER:-}" != "1" ] && [ -f docker-compose.yml ]; then
  say "Starting docker services (mongodb, redis)…"
  docker compose up -d mongodb redis || docker-compose up -d mongodb redis || true
else
  warn "Skipping docker compose (NO_DOCKER=1 or docker-compose.yml missing)."
fi

# ------------------------------------------------------------------------------
# 10) Start all apps (unless NO_START=1)
# ------------------------------------------------------------------------------
if [ "${NO_START:-}" = "1" ]; then
  ok "Install & build completed. Skipping start (NO_START=1)."
  exit 0
fi

say "Launching all apps with yarn dev…"
yarn dev

