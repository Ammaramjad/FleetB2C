import type {Metadata} from 'next'; import './globals.css'; import {AppShell} from '@/components/layout/AppShell';
export const metadata:Metadata={title:'FLEET OS — Taiwan Mobility',description:'Premium mobility, connected across Taiwan'};
export default function RootLayout({children}:{children:React.ReactNode}){return <html lang="en"><body><AppShell>{children}</AppShell></body></html>}
