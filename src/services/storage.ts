export type StoredAsset={key:string;url:string;mimeType:string;size:number};
export interface StorageProvider{upload(input:{name:string;bytes:Uint8Array;mimeType:string}):Promise<StoredAsset>;delete(key:string):Promise<void>}
export class UnconfiguredStorageProvider implements StorageProvider{async upload():Promise<StoredAsset>{throw new Error('Persistent object storage is not configured. Set STORAGE_PROVIDER and its server-side credentials.')}async delete():Promise<void>{throw new Error('Persistent object storage is not configured.')}}
export function getStorageProvider():StorageProvider{return new UnconfiguredStorageProvider()}
