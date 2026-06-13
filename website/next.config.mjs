import path from 'path';

/** @type {import('next').NextConfig} */
const nextConfig = {
  output: "export",
  trailingSlash: true,
  typedRoutes: true,
  images: {
    unoptimized: true,
  },
  turbopack: {
    root: path.join(process.env.TIMERERTIM_REPO_ROOT)
  }
};

export default nextConfig;
