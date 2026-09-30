import {HomePage} from '@/components/home/HomePage';
import {routes, services, vehicles} from '@/data/catalog';

export default function Page(){
  return <HomePage
    hero={{
      title:'Professional Mobility',
      highlightedText:'Connecting You Across Taiwan',
      subtitle:'Airport transfers, charter travel and corporate transport with professional drivers you can trust.',
      desktopImage:'https://images.unsplash.com/photo-1508729640558-1c1f0c20dc35?auto=format&fit=crop&w=2200&q=90',
    }}
    services={services}
    routes={routes}
    vehicles={vehicles.map(vehicle=>({
      id:vehicle.id,
      slug:vehicle.slug,
      name:vehicle.name,
      category:vehicle.category,
      image:vehicle.image,
      seats:vehicle.seats,
      luggage:vehicle.luggage,
      basePrice:vehicle.basePrice,
    }))}
  />;
}
