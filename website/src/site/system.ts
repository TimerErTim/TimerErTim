export type BuildInfo = {
  repoRoot: string;
};

function getBuildInfo(): BuildInfo {
  return {
    repoRoot: process.env.TIMERERTIM_REPO_ROOT!,
  };
}

export const buildInfo = getBuildInfo();
