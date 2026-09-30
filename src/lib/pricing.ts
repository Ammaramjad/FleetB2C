import {PriceBreakdown,ServiceType,Vehicle} from '@/types';
export const formatTwd=(n:number)=>new Intl.NumberFormat('en-US',{style:'currency',currency:'TWD',maximumFractionDigits:0}).format(n).replace('NT$','NT$ ');
export function calculateTripPrice(input:{service:ServiceType;distance:number;duration?:number;vehicle:Vehicle;time?:string;extras?:number;discount?:number}):PriceBreakdown{
 const baseFare=input.service==='self-drive'?input.vehicle.daily:input.service==='chauffeur'?input.vehicle.hourly*(input.duration||4):input.vehicle.basePrice;
 const distanceFare=['self-drive','chauffeur'].includes(input.service)?0:Math.round(input.distance*input.vehicle.perKm);
 const serviceFee=Math.round((baseFare+distanceFare)*.06); const airportFee=input.service==='airport'?300:0;
 const hour=Number((input.time||'12:00').split(':')[0]); const timeAdjustment=hour<6||hour>=22?350:0;
 const extras=input.extras||0,discount=input.discount||0; const subtotal=baseFare+distanceFare+serviceFee+airportFee+timeAdjustment+extras-discount; const tax=Math.round(subtotal*.05);
 return{baseFare,distanceFare,serviceFee,airportFee,timeAdjustment,extras,discount,tax,total:subtotal+tax};
}
