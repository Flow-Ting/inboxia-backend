import "reflect-metadata";
import { DataSource } from "typeorm";
import { User } from "./auth/user.entity.ts";
import { Domain } from "./domain/domain.entity.ts";
import { EmailMetric } from "./email/email.entity.ts";

export const AppDataSource = new DataSource({
  type: "postgres",
  url: process.env.DATABASE_URL,
  synchronize: false,
  logging: false,
  entities: [User, Domain, EmailMetric],
  migrations: ["dist/migrations/*.js"],
  subscribers: [],
});
