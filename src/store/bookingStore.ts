'use client';
import {create} from 'zustand'; import {persist} from 'zustand/middleware'; import {ServiceType,Trip} from '@/types';
type State={trip:Trip;vehicleId?:string;extras:string[];customer?:Record<string,string>;setTrip:(v:Partial<Trip>)=>void;setVehicle:(id:string)=>void;toggleExtra:(x:string)=>void;setCustomer:(x:Record<string,string>)=>void;reset:()=>void};
const initial:Trip={service:'airport',pickup:'',destination:'',date:new Date(Date.now()+86400000).toISOString().slice(0,10),time:'10:30',passengers:1,luggage:1};
export const useBookingStore=create<State>()(persist((set)=>({trip:initial,extras:[],setTrip:v=>set(s=>({trip:{...s.trip,...v}})),setVehicle:id=>set({vehicleId:id}),toggleExtra:x=>set(s=>({extras:s.extras.includes(x)?s.extras.filter(e=>e!==x):[...s.extras,x]})),setCustomer:customer=>set({customer}),reset:()=>set({trip:initial,vehicleId:undefined,extras:[],customer:undefined})}),{name:'fleet-os-booking'}));
