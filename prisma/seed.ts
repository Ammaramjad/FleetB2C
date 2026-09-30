import { PrismaClient, LocationType } from '@prisma/client';
import { hash } from 'bcryptjs';

const prisma = new PrismaClient();

const permissions = [
  'dashboard.view','booking.view','booking.create','booking.edit','booking.cancel','booking.assign_driver','booking.assign_vehicle',
  'fleet.view','fleet.create','fleet.edit','fleet.delete','pricing.view','pricing.edit','customer.view','customer.edit',
  'payment.view','refund.create','cms.view','cms.edit','cms.publish','user.view','user.create','user.edit','role.manage',
  'settings.view','settings.edit','reports.view','audit.view'
];

const vehicleSeeds = [
  ['premium-sedan','Premium Sedan','Sedan',4,2,1280,22,650,3200,'https://images.unsplash.com/photo-1619767886558-efdc259cde1a?auto=format&fit=crop&w=1200&q=85'],
  ['premium-suv','Premium SUV','SUV',6,4,1580,27,820,4200,'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?auto=format&fit=crop&w=1200&q=85'],
  ['luxury-mpv','Luxury MPV','MPV',7,5,1980,31,980,5100,'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=1200&q=85'],
  ['executive-van','Executive Van','Executive Van',10,8,2280,38,1250,6800,'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=1200&q=85'],
  ['touring-minibus','Touring Minibus','Minibus',20,15,4980,55,1800,9800,'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=1200&q=85'],
  ['grand-coach','Grand Coach','Coach',45,40,8680,78,2600,15800,'https://images.unsplash.com/photo-1570125909232-eb263c188f7e?auto=format&fit=crop&w=1200&q=85']
] as const;

async function main() {
  for (const key of permissions) await prisma.permission.upsert({where:{key},update:{},create:{key,description:key.replaceAll('.',' ')}});
  const superAdmin = await prisma.role.upsert({where:{name:'Super Admin'},update:{},create:{name:'Super Admin',isSystem:true,description:'Unrestricted platform access'}});
  for (const name of ['Administrator','Operations Manager','Dispatcher','Fleet Manager','Pricing Manager','Customer Support','Finance','Content Manager','Read Only','Customer']) await prisma.role.upsert({where:{name},update:{},create:{name,isSystem:true}});
  const allPermissions = await prisma.permission.findMany();
  await prisma.rolePermission.createMany({data:allPermissions.map(p=>({roleId:superAdmin.id,permissionId:p.id})),skipDuplicates:true});
  const admin = await prisma.user.upsert({where:{email:'admin@fleetos.tw'},update:{},create:{email:'admin@fleetos.tw',name:'Fleet OS Administrator',passwordHash:await hash(process.env.SEED_ADMIN_PASSWORD||'ChangeMe123!',12)}});
  await prisma.userRole.upsert({where:{userId_roleId:{userId:admin.id,roleId:superAdmin.id}},update:{},create:{userId:admin.id,roleId:superAdmin.id}});

  const serviceCategory = await prisma.serviceCategory.upsert({where:{slug:'mobility'},update:{},create:{name:'Mobility Services',slug:'mobility'}});
  const services = [
    ['airport','Airport Transfer','Flight-tracked, door-to-door transfers'],['point','Point-to-Point','Private city and intercity rides'],['self-drive','Self-Drive Rental','Freedom to explore Taiwan'],
    ['chauffeur','Chauffeur','Professional driver by the hour'],['group','Group Transportation','Minibuses and coaches'],['events','Special Events','Weddings, conferences and VIP travel']
  ];
  for (const [slug,title,description] of services) await prisma.service.upsert({where:{slug},update:{title,description},create:{slug,title,description,categoryId:serviceCategory.id,displayOrder:services.findIndex(x=>x[0]===slug)}});

  const categories = new Map<string,string>();
  for (const [index,name] of ['Sedan','SUV','MPV','Luxury MPV','Executive Van','Minibus','Coach'].entries()) {
    const category = await prisma.vehicleCategory.upsert({where:{slug:name.toLowerCase().replaceAll(' ','-')},update:{displayOrder:index},create:{name,slug:name.toLowerCase().replaceAll(' ','-'),displayOrder:index}}); categories.set(name,category.id);
  }
  for (const [index,v] of vehicleSeeds.entries()) {
    const [slug,name,category,seats,luggage,baseFare,perKmRate,hourlyRate,dailyRate,imageUrl]=v;
    const vehicle=await prisma.vehicle.upsert({where:{slug},update:{},create:{slug,name,fleetNumber:`FOS-${String(index+1).padStart(3,'0')}`,categoryId:categories.get(category)!,passengerCapacity:seats,luggageCapacity:luggage,doors:category==='Coach'?2:4,baseFare,perKmRate,hourlyRate,dailyRate,isFeatured:true,displayOrder:index,rentalEligible:index<3,groupEligible:index>3}});
    await prisma.vehicleImage.upsert({where:{id:`seed-image-${index}`},update:{url:imageUrl},create:{id:`seed-image-${index}`,vehicleId:vehicle.id,url:imageUrl,isPrimary:true,altText:name}});
    for (const feature of ['Professional driver','USB charging','Climate control']) await prisma.vehicleFeature.createMany({data:[{vehicleId:vehicle.id,name:feature}],skipDuplicates:true});
  }

  const cityData=[['Taipei',25.033,121.5654],['Taoyuan',24.9937,121.301],['Taichung',24.1477,120.6736],['Nantou',23.9609,120.9719],['Kaohsiung',22.6273,120.3014],['Hualien',23.9911,121.6112],['Pingtung',22.0,120.7448]] as const;
  const cityIds=new Map<string,string>();
  for(const [name] of cityData){const c=await prisma.city.upsert({where:{slug:name.toLowerCase()},update:{},create:{name,slug:name.toLowerCase()}});cityIds.set(name,c.id)}
  const locationData:[string,string,LocationType,number,number,string?][]=[['Taipei','Taipei',LocationType.CITY,25.033,121.5654],['Taoyuan Airport','Taoyuan',LocationType.AIRPORT,25.0797,121.2342,'TPE'],['Jiufen','Taipei',LocationType.ATTRACTION,25.1099,121.8452],['Sun Moon Lake','Nantou',LocationType.DESTINATION,23.8574,120.9159],['Kaohsiung','Kaohsiung',LocationType.CITY,22.6273,120.3014],['Kaohsiung Airport','Kaohsiung',LocationType.AIRPORT,22.5702,120.3499,'KHH'],['Taroko Gorge','Hualien',LocationType.ATTRACTION,24.1587,121.621],['Kenting','Pingtung',LocationType.DESTINATION,21.9469,120.798]];
  const locations=new Map<string,string>();
  for(const [name,city,type,latitude,longitude,code] of locationData){const slug=name.toLowerCase().replaceAll(' ','-');const l=await prisma.location.upsert({where:{slug},update:{},create:{name,slug,type,latitude,longitude,cityId:cityIds.get(city),isFeatured:true}});locations.set(name,l.id);if(code)await prisma.airport.upsert({where:{code},update:{},create:{code,name,cityId:cityIds.get(city)!}})}
  const airportService=await prisma.service.findUniqueOrThrow({where:{slug:'airport'}});const pointService=await prisma.service.findUniqueOrThrow({where:{slug:'point'}});
  const routeSeeds=[['taipei-tpe','Taipei','Taoyuan Airport',airportService.id,38,34,1280,'https://images.unsplash.com/photo-1470004914212-05527e49370b?auto=format&fit=crop&w=1200&q=85'],['taipei-jiufen','Taipei','Jiufen',pointService.id,40,36,1580,'https://images.unsplash.com/photo-1537531383496-f4749b8032cf?auto=format&fit=crop&w=1200&q=85'],['taichung-sun-moon-lake','Taichung','Sun Moon Lake',pointService.id,70,78,2480,'https://images.unsplash.com/photo-1518002054494-3a6f94352e9d?auto=format&fit=crop&w=1200&q=85'],['kaohsiung-khh','Kaohsiung','Kaohsiung Airport',airportService.id,30,22,980,'https://images.unsplash.com/photo-1598954467835-3b0b6fe3be70?auto=format&fit=crop&w=1200&q=85'],['hualien-taroko','Hualien','Taroko Gorge',pointService.id,50,42,1880,'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=85'],['kaohsiung-kenting','Kaohsiung','Kenting',pointService.id,80,90,2680,'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=85']] as const;
  for(const [i,r] of routeSeeds.entries()){const[slug,from,to,serviceId,durationMinutes,distanceKm,startingPrice,imageUrl]=r;if(!locations.has(from)){const c=await prisma.city.findUniqueOrThrow({where:{slug:from.toLowerCase()}});const l=await prisma.location.upsert({where:{slug:from.toLowerCase()},update:{},create:{name:from,slug:from.toLowerCase(),type:LocationType.CITY,latitude:24.1,longitude:121,cityId:c.id}});locations.set(from,l.id)}await prisma.route.upsert({where:{slug},update:{imageUrl},create:{slug,serviceId,originId:locations.get(from)!,destinationId:locations.get(to)!,durationMinutes,distanceKm,startingPrice,isFeatured:true,displayOrder:i,imageUrl}})}
  await prisma.heroSlide.upsert({where:{id:'primary-hero'},update:{},create:{id:'primary-hero',title:'Professional Mobility',highlightedText:'Connecting You Across Taiwan',subtitle:'Airport transfers, charter travel and corporate transport with professional drivers you can trust.',desktopImage:'https://images.unsplash.com/photo-1508729640558-1c1f0c20dc35?auto=format&fit=crop&w=2200&q=90',ctaText:'Book your journey',ctaUrl:'#book'}});
  const sections=[['why','Why Choose Fleet OS'],['how','How It Works'],['explore','Explore Taiwan'],['airports','Airport Coverage'],['reviews','Loved by travelers'],['faq','Frequently Asked Questions'],['final-cta','Ready when you are']];
  for(const [i,[key,title]] of sections.entries())await prisma.homepageSection.upsert({where:{key},update:{},create:{key,title,isActive:true,displayOrder:i+1}});
}

main().finally(()=>prisma.$disconnect());
