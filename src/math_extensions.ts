/**
 * Clamps the given number to be between min and max (inclusive)
 * @param value The number to be clamped
 * @param min The minimum allowed number
 * @param max The maximum allowed number
 * @returns Clamped number
 */
export function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max);
}
