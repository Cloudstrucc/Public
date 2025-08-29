/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  // Force Pages Router so pages/ is used (not app/)
  experimental: { appDir: false }
};
module.exports = nextConfig;
