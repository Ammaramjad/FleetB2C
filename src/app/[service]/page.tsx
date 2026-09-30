import {notFound} from 'next/navigation';import {ServiceLanding} from '@/components/services/ServiceLanding';import {serviceFromPath} from '@/store/bookingStore';
const valid=['airport-transfer','point-to-point','self-drive','chauffeur','group-transport','special-events'];
export default async function Page({params}:{params:Promise<{service:string}>}){const{service}=await params;if(!valid.includes(service))notFound();return <ServiceLanding type={serviceFromPath(service)}/>}
