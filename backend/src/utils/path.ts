export const isPathMatch = (inputPath: string, paths: string[]): boolean => {
  return paths.some((path) => {
    if (path.endsWith('*')) {
      const basePath = path.slice(0,-1);
      return inputPath.startsWith(basePath);
    }
    return inputPath === path;
  })
}