import {MapPin} from 'lucide-react';
export type MapMarker={id:string;name:string;latitude:number;longitude:number;type:string};
export interface MapProviderProps{markers:MapMarker[];route?:string[]}
export function TaiwanMap({markers}:MapProviderProps){return <section className="taiwan-map" aria-label="Fleet OS Taiwan coverage map"><div className="taiwan-silhouette" aria-hidden="true"/>{markers.map(marker=><div className="map-marker" key={marker.id} style={{left:`${Math.max(8,Math.min(92,(marker.longitude-120)*55))}%`,top:`${Math.max(6,Math.min(94,(25.5-marker.latitude)*23))}%`}} title={marker.name}><MapPin/><span>{marker.name}</span></div>)}<div className="map-legend"><b>Taiwan, connected.</b><span>Live service locations managed in Fleet OS Admin.</span></div></section>}
