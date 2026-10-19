import { getRequest, postRequest } from '/@/lib/axios';

export interface CacheItem {
  cacheName: string;
  displayName: string;
}

export const cacheApi = {
  list: (): Promise<{ data: CacheItem[] }> => getRequest('/support/cache/list', {}),
  clear: (cacheName: string): Promise<unknown> => postRequest(`/support/cache/clear/${encodeURIComponent(cacheName)}`, {}),
  clearAll: (): Promise<unknown> => postRequest('/support/cache/clearAll', {}),
};
