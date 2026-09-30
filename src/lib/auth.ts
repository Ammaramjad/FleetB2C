import { cookies } from 'next/headers';
import { SignJWT, jwtVerify } from 'jose';
import { db } from './db';

const secret = new TextEncoder().encode(process.env.AUTH_SECRET || 'development-only-change-me');
export type SessionUser={id:string;email:string;name:string;permissions:string[]};

export async function createSession(user:SessionUser){return new SignJWT(user).setProtectedHeader({alg:'HS256'}).setIssuedAt().setExpirationTime('8h').sign(secret)}
export async function getSession():Promise<SessionUser|null>{const token=(await cookies()).get('fleet_session')?.value;if(!token)return null;try{return (await jwtVerify(token,secret)).payload as unknown as SessionUser}catch{return null}}
export async function getUserAccess(userId:string){const user=await db.user.findUnique({where:{id:userId,status:'ACTIVE'},include:{roles:{include:{role:{include:{permissions:{include:{permission:true}}}}}}}});if(!user)return null;return{id:user.id,email:user.email,name:user.name,permissions:[...new Set(user.roles.flatMap(r=>r.role.permissions.map(p=>p.permission.key)))]}}
export async function requirePermission(permission:string){const session=await getSession();if(!session)throw new Error('FORBIDDEN');const current=await getUserAccess(session.id);if(!current?.permissions.includes(permission))throw new Error('FORBIDDEN');return current}
