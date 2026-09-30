import {notFound} from 'next/navigation';import {ServiceLanding} from '@/components/services/ServiceLanding';import {ServiceType} from '@/types';
const valid=['airport-transfer','point-to-point','self-drive','chauffeur','group-transport','special-events'];
const serviceTypes:Record<string,ServiceType>={'airport-transfer':'airport','point-to-point':'point','self-drive':'self-drive','chauffeur':'chauffeur','group-transport':'group','special-events':'events'};
export default async function Page({params}:{params:Promise<{service:string}>}){const{service}=await params;if(!valid.includes(service))notFound();return <ServiceLanding type={serviceTypes[service]}/>}
