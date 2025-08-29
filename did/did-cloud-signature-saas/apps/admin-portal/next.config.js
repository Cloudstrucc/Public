/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  // ⬇️ add all internal packages you import from the admin portal
  transpilePackages: ['@saas/agent', '@saas/policy-engine', '@saas/mip-wrapper', '@saas/kv-hsm'],
};

module.exports = nextConfig;
