export function pickObjectProperties(obj: Record<string, unknown>, properties: string[]): Record<string, unknown> {
  return Object.fromEntries(
    properties.map((prop) => (obj[prop] !== undefined ? [prop, obj[prop]] : [])).filter((item) => item.length),
  );
}