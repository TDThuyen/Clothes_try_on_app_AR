import { PrismaClient } from '../generated/prisma';

let prisma: PrismaClient;

export function getPrisma() {
  if (!prisma) {
    prisma = new PrismaClient();
  }
  return prisma;
}
