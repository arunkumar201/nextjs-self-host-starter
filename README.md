This is a [Next.js](https://nextjs.org) project bootstrapped with [`create-next-app`](https://nextjs.org/docs/app/api-reference/cli/create-next-app).

## Getting Started

First, run the development server:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
# or
bun dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the page by modifying `app/page.tsx`. The page auto-updates as you edit the file.

# Run using Docker web service (prod)

- Build the docker image

```bash
docker build -t self-host-nextjs ./
```

- Run the docker container

```bash
docker run -p 3000:3000 -d self-host-nextjs
```

# Run app with all service using Docker

```bash
pnpm docker:start
```

# Prisma setup

- Installing Prisma

```bash
pnpm install -D prisma
pnpx prisma init

```

## Configuring Prisma

- once we ran `pnpx prisma init` cmd it will add the `schema.prisma` and `.env` file with default code and DATABASE_URL env variable.

- easiest way to install the postgres database is to use the `docker` container

```bash
docker pull postgres
```

- start a Postgres instance by running the command below

```bash
docker run --name my-postgres -e POSTGRES_USER=root -e POSTGRES_PASSWORD=myuser -e POSTGRES_DB=mydb -p 5432:5432 -d postgres

```

- now we need to configure the `DATABASE_URL` env variable in the `.env` file

```bash
DATABASE_URL="postgresql://root:myuser@localhost:5432/mydb"
```

- now we can run the `prisma migrate dev` command to create the tables in the database

```bash
pnpx prisma migrate dev --name init

```

- Check the Migration Status

```bash
pnpx prisma migrate status
```

- Generate Prisma Client - generates the Prisma client in the node_modules directory, enabling us to use it to interact with your updated database schema.

```bash
pnpx prisma generate
```

- We can also run Prisma Studio, a visual editor for your database

```bash
pnpx prisma studio
```

## Creating the prisma client to interact with the database in nextjs application

- we can directly using Prisma Client in various parts of your application to interact with the database
  but it is not the most efficient or optimal approach, especially for a server-side environment like Next.js.

- insted,we need to create a dedicated module that ensures Prisma Client is used as a singleton across your application. it is crucial for maintaining efficient and reliable database connections.

- create `lib/prisma.ts` file and add the following code

```ts
import { PrismaClient } from "@prisma/client";

const prismaClientSingleton = () => {
	return new PrismaClient({
		datasources: { db: { url: process.env.DATABASE_URL } },
		...(process.env.DEBUG === "1" && {
			log: ["query", "info"],
		}),
	});
};

type PrismaClientSingleton = ReturnType<typeof prismaClientSingleton>;

const globalForPrisma = globalThis as unknown as {
	prisma: PrismaClientSingleton | undefined;
};

export const prisma = globalForPrisma.prisma ?? prismaClientSingleton();

if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma;
```

- This code creates a singleton instance of Prisma Client, which is then exported as the `prisma
- we shold use the Prisma client anywhere in your Next.js 15 application
