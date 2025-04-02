import {MigrationInterface, QueryRunner} from "typeorm";

export class CreateUserAndDomain1623456789012 implements MigrationInterface {
    name = 'CreateUserAndDomain1623456789012'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(\`CREATE TABLE "user" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "tenantId" character varying NOT NULL, "username" character varying NOT NULL, "password" character varying NOT NULL, "role" character varying NOT NULL DEFAULT 'user', CONSTRAINT "UQ_username" UNIQUE ("username"), CONSTRAINT "PK_user" PRIMARY KEY ("id"))\`);
        await queryRunner.query(\`CREATE TABLE "domain" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "tenantId" character varying NOT NULL, "name" character varying NOT NULL, "spfVerified" boolean NOT NULL DEFAULT false, "dkimVerified" boolean NOT NULL DEFAULT false, "dmarcVerified" boolean NOT NULL DEFAULT false, "verificationError" character varying, CONSTRAINT "PK_domain" PRIMARY KEY ("id"))\`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(\`DROP TABLE "domain"\`);
        await queryRunner.query(\`DROP TABLE "user"\`);
    }
}
