'use client';

import Link from 'next/link';
import {BookingPanel} from '@/components/booking/BookingPanel';
import {services, vehicles} from '@/data/catalog';
import {ServiceType} from '@/types';
import {ArrowRight, CheckCircle2, Clock3, Headphones, MapPin, ShieldCheck, Users} from 'lucide-react';

const detail:Record<ServiceType,{kicker:string;headline:string;intro:string;steps:string[];uses:string[]}>={
  airport:{kicker:'ARRIVE WITH EASE',headline:'The calmest way to leave the airport.',intro:'From touchdown to your hotel door, your arrival is monitored and coordinated in real time.',steps:['Share your flight','Meet your driver','Relax all the way'],uses:['Complimentary flight tracking','Meet & greet available','60 minutes included waiting time']},
  point:{kicker:'CITY TO CITY',headline:'Private travel, precisely where you need it.',intro:'A direct ride with no detours, shared stops or complicated connections.',steps:['Choose your route','Select your vehicle','Meet at your door'],uses:['Door-to-door convenience','Flexible pickup times','Upfront route pricing']},
  'self-drive':{kicker:'YOUR ROAD, YOUR WAY',headline:'The freedom to explore Taiwan.',intro:'A well-maintained vehicle, simple collection and the open road ahead.',steps:['Choose your car','Confirm your details','Collect and explore'],uses:['Daily and multi-day hire','Clear insurance options','Flexible return locations']},
  chauffeur:{kicker:'DRIVEN AROUND YOU',headline:'A professional driver, by the hour.',intro:'Keep the day flowing while a dedicated chauffeur handles every road and stop.',steps:['Plan your hours','Choose your vehicle','Set your own pace'],uses:['Experienced chauffeurs','Multi-stop itineraries','Ideal for business travel']},
  group:{kicker:'BETTER, TOGETHER',headline:'Group travel without the logistics.',intro:'One comfortable vehicle, one coordinated plan and space for everyone.',steps:['Tell us your group size','Build your itinerary','Travel together'],uses:['Minibuses and 45-seat coaches','Event and tour coordination','Generous luggage capacity']},
  events:{kicker:'MOMENTS THAT MATTER',headline:'Transport worthy of the occasion.',intro:'Polished arrivals and coordinated departures for weddings, conferences and VIP guests.',steps:['Share your event plan','Approve your fleet','Leave timing to us'],uses:['Dedicated coordinator','Multi-vehicle planning','VIP and guest management']},
};

export function ServiceLanding({type}:{type:ServiceType}){
  const service=services.find(x=>x.id===type)!; const content=detail[type]; const suited=vehicles.filter(v=>v.services.includes(type)).slice(0,3);
  return <main className="service-page">
    <section className="service-hero" style={{backgroundImage:`linear-gradient(90deg,#06172bf2 5%,#06172b99 52%,#06172b22),url('${service.image}')`}}><span className="eyebrow">{content.kicker}</span><h1>{service.title},<br/>beautifully simple.</h1><p>{content.intro}</p><a href="#book">Book this service <ArrowRight/></a></section>
    <div className="home-content service-book"><BookingPanel defaultService={type}/>
      <section className="service-intro"><div><span className="eyebrow">WHY FLEET OS</span><h2>{content.headline}</h2><p>{service.desc}. Transparent pricing, trusted vehicles and a local support team whenever you need it.</p></div><div>{content.uses.map(x=><span key={x}><CheckCircle2/>{x}</span>)}</div></section>
      <section className="service-steps"><span className="eyebrow">HOW IT WORKS</span><h2>Three steps. Zero stress.</h2><div>{content.steps.map((step,index)=><article key={step}><i>0{index+1}</i><h3>{step}</h3><p>{index===0?'Add the details that make this journey yours.':index===1?'See the best options with clear, upfront pricing.':'Your professional driver takes care of the rest.'}</p></article>)}</div></section>
      <section className="service-assurance"><div><ShieldCheck/><b>Safety first</b><span>Vetted drivers and maintained vehicles</span></div><div><Clock3/><b>On your time</b><span>Precise scheduling and live coordination</span></div><div><Headphones/><b>Human support</b><span>A local team available around the clock</span></div><div><MapPin/><b>Local knowledge</b><span>Routes planned by people who know Taiwan</span></div></section>
      <section><div className="section-head"><div><span className="eyebrow">RECOMMENDED FLEET</span><h2>Made for this journey.</h2></div><Link href="/fleet">See every vehicle <ArrowRight/></Link></div><div className="service-vehicle-grid">{suited.map(v=><Link href={`/fleet/${v.slug}`} key={v.id}><img src={v.image} alt={v.name}/><span>{v.category}</span><h3>{v.name}</h3><p><Users/> Up to {v.seats} passengers</p><b>View vehicle <ArrowRight/></b></Link>)}</div></section>
      <section className="service-final"><div><span className="eyebrow">READY WHEN YOU ARE</span><h2>Let’s plan your {service.title.toLowerCase()}.</h2></div><a href="#book">Start booking <ArrowRight/></a></section>
    </div>
  </main>
}
