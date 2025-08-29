# 1) Force pages router in the employee portal
node - <<'NODE'
const fs = require('fs');
const f = 'apps/employee-portal/next.config.js';
let s = fs.readFileSync(f,'utf8');
if(!/experimental:\s*\{[^}]*appDir:\s*false/m.test(s)){
  // add/merge experimental.appDir:false
  if(/module\.exports\s*=/.test(s)){
    s = s.replace(/module\.exports\s*=\s*(\{[\s\S]*?\});?/,
      (m,obj)=>`const cfg=${obj};
cfg.experimental = Object.assign({}, cfg.experimental, { appDir: false });
module.exports = cfg;`);
  } else {
    s += `

if(!module.exports) module.exports = {};
module.exports.experimental = Object.assign({}, module.exports.experimental, { appDir: false });
`;
  }
  fs.writeFileSync(f,s);
  console.log('Updated next.config.js to experimental.appDir=false');
} else {
  console.log('next.config.js already sets experimental.appDir=false');
}
NODE

# 2) (Optional) if you have an accidental empty app/ folder, remove it
rm -rf apps/employee-portal/app 2>/dev/null || true

# 3) Restart just the employee portal or your whole dev
yarn workspace @saas/employee-portal dev

