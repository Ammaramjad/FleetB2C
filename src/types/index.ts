export type ServiceType='airport'|'point'|'self-drive'|'chauffeur'|'group'|'events';
export type Vehicle={id:string;slug:string;name:string;category:string;image:string;seats:number;luggage:number;doors:number;basePrice:number;perKm:number;hourly:number;daily:number;features:string[];services:ServiceType[];available:boolean};
export type Trip={service:ServiceType;pickup:string;destination:string;date:string;time:string;passengers:number;luggage:number;flight?:string};
export type PriceBreakdown={baseFare:number;distanceFare:number;serviceFee:number;airportFee:number;timeAdjustment:number;extras:number;discount:number;tax:number;total:number};
