import {NextResponse} from 'next/server';
import {db} from '@/lib/db';

export const dynamic='force-dynamic';
export const runtime='nodejs';

export async function GET(){
  const configuration={databaseUrl:Boolean(process.env.DATABASE_URL),authSecret:Boolean(process.env.AUTH_SECRET&&process.env.AUTH_SECRET.length>=32)};
  try{
    await db.$queryRaw`SELECT 1`;
    const healthy=configuration.databaseUrl&&configuration.authSecret;
    return NextResponse.json({status:healthy?'ok':'misconfigured',database:'connected',configuration},{status:healthy?200:503});
  }catch(error){
    console.error('Database health check failed',error);
    return NextResponse.json({status:'unhealthy',database:'unavailable',configuration},{status:503});
  }
}
