export function formatIpRegion(region?: string | null): string {
  return (region ?? '').split('|').map(part => part.trim()).filter(part => part && part !== '0').join('|');
}
