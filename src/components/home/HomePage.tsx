'use client';

import Link from 'next/link';
import {useEffect, useRef, useState} from 'react';
import {
  ArrowRight, BriefcaseBusiness, CarFront, CheckCircle2, ChevronLeft,
  ChevronRight, Clock3, Globe2, Heart, MapPin, Plane, Play, Quote,
  ShieldCheck, Sparkles, Star, Users,
} from 'lucide-react';
import {BookingPanel} from '@/components/booking/BookingPanel';
import {formatTwd} from '@/lib/pricing';
import {ServiceType} from '@/types';

type HomeService={id:ServiceType;title:string;desc:string;href:string;image:string};
type HomeRoute={id:string;from:string;to:string;duration:string;km:number;price:number;image:string};
type HomeVehicle={id:string;slug:string;name:string;category:string;image:string;seats:number;luggage:number;basePrice:number};
type Hero={title:string;highlightedText:string;subtitle:string;desktopImage:string};

const stories=[
  {tag:'Travel guide',title:'A local’s guide to 48 hours in Taipei',date:'Sep 26, 2026',image:'https://images.unsplash.com/photo-1470004914212-05527e49370b?auto=format&fit=crop&w=900&q=85'},
  {tag:'Fleet news',title:'Our new executive fleet has arrived',date:'Sep 18, 2026',image:'https://images.unsplash.com/photo-1619767886558-efdc259cde1a?auto=format&fit=crop&w=900&q=85'},
  {tag:'Airport tips',title:'Everything to know before landing at TPE',date:'Sep 10, 2026',image:'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?auto=format&fit=crop&w=900&q=85'},
];

export function HomePage({services,routes,vehicles,hero}:{services:HomeService[];routes:HomeRoute[];vehicles:HomeVehicle[];hero:Hero}){
  const[video,setVideo]=useState(false); const[favs,setFavs]=useState<string[]>([]); const[cat,setCat]=useState('All');
  const[slide,setSlide]=useState(0); const fleetRef=useRef<HTMLDivElement>(null);
  const slides=[{title:hero.title,accent:hero.highlightedText,copy:hero.subtitle,image:hero.desktopImage,href:'#book'},...routes.slice(0,2).map(r=>({title:`${r.from} to ${r.to}`,accent:'Travel, reimagined',copy:`A seamless ${r.duration} private journey, planned around you.`,image:r.image,href:'#book'}))];
  useEffect(()=>{const timer=window.setInterval(()=>setSlide(current=>(current+1)%slides.length),6000);return()=>window.clearInterval(timer)},[slides.length]);
  const toggle=(id:string)=>{const next=favs.includes(id)?favs.filter(x=>x!==id):[...favs,id];setFavs(next);localStorage.setItem('fleet-favorites',JSON.stringify(next))};
  const move=(direction:number)=>setSlide(current=>(current+direction+slides.length)%slides.length);

  return <main>
    <section className="cinematic-hero">
      <div className="hero-stage">
        {slides.map((item,index)=><article className={`hero-slide ${index===slide?'is-active':''}`} key={`${item.title}-${index}`} aria-hidden={index!==slide}>
          <div className="hero-slide-image" style={{backgroundImage:`url('${item.image}')`}}/>
          <div className="hero-slide-copy"><span className="eyebrow">PREMIUM TAIWAN MOBILITY</span><h1>{item.title}.<br/><em>{item.accent}.</em></h1><p>{item.copy}</p><div className="hero-actions"><Link href={item.href}>Plan your journey <ArrowRight/></Link><button onClick={()=>setVideo(true)}><Play/> Watch film</button></div></div>
        </article>)}
        <div className="hero-rail"><button onClick={()=>move(-1)} aria-label="Previous slide"><ChevronLeft/></button><span><b>0{slide+1}</b> / 0{slides.length}</span><div>{slides.map((_,i)=><button key={i} aria-label={`Go to slide ${i+1}`} className={i===slide?'active':''} onClick={()=>setSlide(i)}/>)}</div><button onClick={()=>move(1)} aria-label="Next slide"><ChevronRight/></button></div>
        <div className="hero-float"><ShieldCheck/><span><b>Travel with confidence</b><small>Licensed drivers · live trip support</small></span></div>
      </div>
    </section>

    <div className="home-content"><BookingPanel serviceOptions={services}/>
      <section className="intro-band"><div><span className="eyebrow">ONE PLATFORM, EVERY JOURNEY</span><h2>Move through Taiwan<br/>on your terms.</h2></div><p>From a quiet airport arrival to a coach for the whole team, we pair local knowledge with polished service—so the journey feels as considered as the destination.</p><Link href="/explore">Discover Taiwan <ArrowRight/></Link></section>

      <section><div className="section-head"><div><span className="eyebrow">WAYS TO MOVE</span><h2>A service for every story.</h2></div><Link href="/fleet">Explore the fleet <ArrowRight/></Link></div><div className="service-grid editorial">{services.map((s,i)=><Link href={s.href} className="service-card" key={s.id}><img src={s.image} alt=""/><div><i>0{i+1}</i><h3>{s.title}</h3><p>{s.desc}</p><span>Explore service <ArrowRight/></span></div></Link>)}</div></section>

      <section className="experience-split"><div className="experience-image"><span>TAIWAN<br/><b>WITHOUT LIMITS</b></span></div><div className="experience-copy"><span className="eyebrow">THE FLEET OS DIFFERENCE</span><h2>More than a ride.<br/>A better way to arrive.</h2><p>Every detail is coordinated by people who know Taiwan: the right vehicle, the smartest route and a warm welcome exactly when you need it.</p>{['Professionally vetted local drivers','Flight monitoring and flexible pickup','One team, available around the clock'].map(x=><span key={x}><CheckCircle2/>{x}</span>)}<Link href="/help">How we care for every trip <ArrowRight/></Link></div></section>

      <section><div className="section-head"><div><span className="eyebrow">CURATED FOR YOU</span><h2>Popular journeys.</h2></div><Link href="/destinations">View all destinations <ArrowRight/></Link></div><div className="routes-grid">{routes.map(r=><article className="route-card" key={r.id}><div className="route-image" style={{backgroundImage:`url('${r.image}')`}}><button aria-label="Favorite" onClick={()=>toggle(r.id)} className={favs.includes(r.id)?'liked':''}><Heart fill={favs.includes(r.id)?'currentColor':'none'}/></button><span>{r.duration}</span></div><div><h3>{r.from} <ArrowRight/> {r.to}</h3><p>{r.km} km · Private transfer</p><b>From {formatTwd(r.price)}</b></div></article>)}</div></section>

      <section className="fleet-section"><div className="section-head"><div><span className="eyebrow">THE FLEET</span><h2>Your space. Your standard.</h2></div><div className="carousel-buttons"><button onClick={()=>fleetRef.current?.scrollBy({left:-350,behavior:'smooth'})}><ChevronLeft/></button><button onClick={()=>fleetRef.current?.scrollBy({left:350,behavior:'smooth'})}><ChevronRight/></button></div></div><div className="filters">{['All','Sedan','SUV','MPV','Luxury','Minibus','Coach'].map(x=><button className={cat===x?'active':''} onClick={()=>setCat(x)} key={x}>{x}</button>)}</div><div className="fleet-carousel" ref={fleetRef} tabIndex={0}>{vehicles.filter(v=>cat==='All'||v.category===cat).map(v=><Link href={`/fleet/${v.slug}`} className="fleet-card" key={v.id}><img src={v.image} alt={v.name}/><span>{v.category}</span><h3>{v.name}</h3><p><Users/> {v.seats} seats <BriefcaseBusiness/> {v.luggage} bags</p><b>From {formatTwd(v.basePrice)}</b></Link>)}</div></section>

      <section className="promise-grid"><article><Globe2/><b>Island-wide reach</b><p>Reliable transport in every major city and destination.</p></article><article><Clock3/><b>Always on your time</b><p>Live coordination before, during and after every ride.</p></article><article><CarFront/><b>The right vehicle</b><p>From refined sedans to comfortable 45-seat coaches.</p></article><article><Sparkles/><b>Thoughtful by design</b><p>Clear pricing, easy booking and no unwelcome surprises.</p></article></section>

      <section className="testimonial"><Quote/><blockquote>“The easiest part of our Taiwan trip. Our driver was waiting before we landed, the car was immaculate, and every detail simply worked.”</blockquote><div><span>CL</span><p><b>Claire Lin</b><small>Verified airport transfer · Singapore</small></p><strong><Star fill="currentColor"/><Star fill="currentColor"/><Star fill="currentColor"/><Star fill="currentColor"/><Star fill="currentColor"/></strong></div></section>

      <section className="journal"><div className="section-head"><div><span className="eyebrow">JOURNAL & NEWS</span><h2>Ideas for the road.</h2></div><Link href="/explore">Read all stories <ArrowRight/></Link></div><div className="journal-grid">{stories.map((story,index)=><article key={story.title} className={index===0?'featured':''}><img src={story.image} alt=""/><div><span>{story.tag} · {story.date}</span><h3>{story.title}</h3><Link href="/explore">Read story <ArrowRight/></Link></div></article>)}</div></section>

      <section className="final-cta"><MapPin/><div><span className="eyebrow">WHERE TO NEXT?</span><h2>Your Taiwan journey starts here.</h2><p>Tell us where you are going. We will take care of everything in between.</p></div><Link href="#book">Book your ride <ArrowRight/></Link></section>
      <section className="trust"><div><b>10,000+</b><span>Professional rides</span></div><div><b>50,000+</b><span>Happy travelers</span></div><div><b>24/7</b><span>Human support</span></div><div><b>100%</b><span>Safety commitment</span></div><div><b><Star fill="currentColor"/>4.8/5</b><span>Verified rating</span></div></section>
    </div>
    {video&&<div className="modal-backdrop" onClick={()=>setVideo(false)}><div className="video-modal" onClick={e=>e.stopPropagation()}><button onClick={()=>setVideo(false)}>×</button><div><Play/><h2>Across Taiwan, together.</h2><p>A cinematic preview of the people, places, and premium vehicles behind every FLEET OS journey.</p></div></div></div>}
  </main>
}
