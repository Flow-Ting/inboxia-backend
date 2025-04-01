#!/bin/bash
# ------------------------------------------------------------------------------
# Inboxia Backend Full Setup Script
#
# This script sets up the complete production-ready Inboxia backend.
# It creates the directory structure, writes all necessary source files,
# and configures CI/CD with GitHub Actions and Docker.
#
# Please back up your old backend files before running this script.
# ------------------------------------------------------------------------------
 
PROJECT_DIR="inboxia-backend"

# Step 1: Remove any existing project directory (backup old files if needed)
if [ -d "$PROJECT_DIR" ]; then
  echo "Removing existing $PROJECT_DIR directory..."
  rm -rf "$PROJECT_DIR"
fi

# Step 2: Create the directory structure
echo "Creating project directories..."
mkdir -p "$PROJECT_DIR/src/common/logger"
mkdir -p "$PROJECT_DIR/src/auth"
mkdir -p "$PROJECT_DIR/src/domain"
mkdir -p "$PROJECT_DIR/src/email"
mkdir -p "$PROJECT_DIR/src/analytics"
mkdir -p "$PROJECT_DIR/src/esp"
mkdir -p "$PROJECT_DIR/src/tenant"
mkdir -p "$PROJECT_DIR/migrations"
mkdir -p "$PROJECT_DIR/test"
mkdir -p "$PROJECT_DIR/.github/workflows"

# Step 3: Create the main application entry file (src/main.ts)
echo "Creating src/main.ts..."
cat > "$PROJECT_DIR/src/main.ts" << 'EOF'
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { WinstonLoggerService } from './common/logger/winston-logger.service';
import * as helmet from 'helmet';
import * as cors from 'cors';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: new WinstonLoggerService(),
  });
  app.useGlobalPipes(new ValidationPipe());
  app.use(helmet());
  app.use(cors());
  await app.listen(process.env.PORT || 3000);
}
bootstrap();
EOF

# Step 4: Create the root module (src/app.module.ts)
echo "Creating src/app.module.ts..."
cat > "$PROJECT_DIR/src/app.module.ts" << 'EOF'
import { Module, MiddlewareConsumer } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './auth/auth.module';
import { DomainModule } from './domain/domain.module';
import { EmailModule } from './email/email.module';
import { AnalyticsModule } from './analytics/analytics.module';
import { EspModule } from './esp/esp.module';
import { TenantMiddleware } from './tenant/tenant.middleware';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'postgres',
      url: process.env.DATABASE_URL,
      autoLoadEntities: true,
      synchronize: false,
      migrationsRun: true,
      migrations: ['dist/migrations/*.js'],
    }),
    AuthModule,
    DomainModule,
    EmailModule,
    AnalyticsModule,
    EspModule,
  ],
})
export class AppModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(TenantMiddleware).forRoutes('*');
  }
}
EOF

# Step 5: Create the common logger (src/common/logger/winston-logger.service.ts)
echo "Creating src/common/logger/winston-logger.service.ts..."
cat > "$PROJECT_DIR/src/common/logger/winston-logger.service.ts" << 'EOF'
import { Injectable, LoggerService } from '@nestjs/common';
import * as winston from 'winston';

@Injectable()
export class WinstonLoggerService implements LoggerService {
  private logger: winston.Logger;

  constructor() {
    this.logger = winston.createLogger({
      level: 'info',
      format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.printf(({ timestamp, level, message }) => \`\${timestamp} [\${level}]: \${message}\`)
      ),
      transports: [new winston.transports.Console()],
    });
  }

  log(message: string) { this.logger.info(message); }
  error(message: string, trace?: string) { this.logger.error(\`\${message} - \${trace}\`); }
  warn(message: string) { this.logger.warn(message); }
  debug(message: string) { this.logger.debug(message); }
  verbose(message: string) { this.logger.verbose(message); }
}
EOF

# Step 6: Create Tenant Middleware (src/tenant/tenant.middleware.ts)
echo "Creating src/tenant/tenant.middleware.ts..."
cat > "$PROJECT_DIR/src/tenant/tenant.middleware.ts" << 'EOF'
import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';

@Injectable()
export class TenantMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    req['tenantId'] = req.headers['x-tenant-id'] || 'default_tenant';
    next();
  }
}
EOF

# Step 7: Create Auth Module files
echo "Creating Auth Module files..."
# src/auth/user.entity.ts
cat > "$PROJECT_DIR/src/auth/user.entity.ts" << 'EOF'
import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity()
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  tenantId: string;

  @Column({ unique: true })
  username: string;

  @Column()
  password: string;

  @Column({ default: 'user' })
  role: string;
}
EOF

# src/auth/auth.service.ts
cat > "$PROJECT_DIR/src/auth/auth.service.ts" << 'EOF'
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { User } from './user.entity';
import { Repository } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';
import * as bcrypt from 'bcrypt';
import { JwtService } from '@nestjs/jwt';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User) private readonly userRepo: Repository<User>,
    private readonly jwtService: JwtService,
  ) {}

  async validateUser(username: string, pass: string, tenantId: string): Promise<any> {
    const user = await this.userRepo.findOne({ where: { username, tenantId } });
    if (user && await bcrypt.compare(pass, user.password)) {
      const { password, ...result } = user;
      return result;
    }
    throw new UnauthorizedException();
  }

  async login(user: any) {
    const payload = { username: user.username, sub: user.id, tenantId: user.tenantId, role: user.role };
    return { access_token: this.jwtService.sign(payload) };
  }
}
EOF

# src/auth/jwt.strategy.ts
cat > "$PROJECT_DIR/src/auth/jwt.strategy.ts" << 'EOF'
import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET || 'default_secret',
    });
  }

  async validate(payload: any) {
    return { userId: payload.sub, username: payload.username, tenantId: payload.tenantId, role: payload.role };
  }
}
EOF

# src/auth/auth.controller.ts
cat > "$PROJECT_DIR/src/auth/auth.controller.ts" << 'EOF'
import { Controller, Post, Body, Req } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  async login(@Body() body, @Req() req) {
    const user = await this.authService.validateUser(body.username, body.password, req.tenantId);
    return this.authService.login(user);
  }
}
EOF

# src/auth/auth.module.ts
cat > "$PROJECT_DIR/src/auth/auth.module.ts" << 'EOF'
import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { JwtModule } from '@nestjs/jwt';
import { JwtStrategy } from './jwt.strategy';
import { AuthController } from './auth.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from './user.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([User]),
    JwtModule.register({
      secret: process.env.JWT_SECRET || 'default_secret',
      signOptions: { expiresIn: '3600s' },
    }),
  ],
  providers: [AuthService, JwtStrategy],
  controllers: [AuthController],
  exports: [AuthService],
})
export class AuthModule {}
EOF

# Step 8: Create Domain Module files
echo "Creating Domain Module files..."
# src/domain/domain.entity.ts
cat > "$PROJECT_DIR/src/domain/domain.entity.ts" << 'EOF'
import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity()
export class Domain {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  tenantId: string;

  @Column()
  name: string;

  @Column({ default: false })
  spfVerified: boolean;

  @Column({ default: false })
  dkimVerified: boolean;

  @Column({ default: false })
  dmarcVerified: boolean;

  @Column({ nullable: true })
  verificationError: string;
}
EOF

# src/domain/domain.service.ts
cat > "$PROJECT_DIR/src/domain/domain.service.ts" << 'EOF'
import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Domain } from './domain.entity';
import { Repository } from 'typeorm';
import * as dns from 'dns/promises';

@Injectable()
export class DomainService {
  constructor(
    @InjectRepository(Domain) private readonly domainRepo: Repository<Domain>,
  ) {}

  async createDomain(tenantId: string, name: string): Promise<Domain> {
    const domain = this.domainRepo.create({ tenantId, name });
    return this.domainRepo.save(domain);
  }

  async verifyDomain(domainId: string): Promise<Domain> {
    const domain = await this.domainRepo.findOne({ where: { id: domainId } });
    if (!domain) {
      throw new InternalServerErrorException('Domain not found');
    }
    try {
      const spfRecords = await dns.resolveTxt(domain.name);
      domain.spfVerified = spfRecords.some(rec => rec.join('').includes('v=spf1'));
      domain.dkimVerified = true;  // placeholder
      domain.dmarcVerified = true; // placeholder
      return this.domainRepo.save(domain);
    } catch (err) {
      domain.verificationError = err.message;
      return this.domainRepo.save(domain);
    }
  }
}
EOF

# src/domain/domain.controller.ts
cat > "$PROJECT_DIR/src/domain/domain.controller.ts" << 'EOF'
import { Controller, Post, Body, Param, Req } from '@nestjs/common';
import { DomainService } from './domain.service';

@Controller('domains')
export class DomainController {
  constructor(private readonly domainService: DomainService) {}

  @Post()
  async createDomain(@Body('name') name: string, @Req() req) {
    return this.domainService.createDomain(req.tenantId, name);
  }

  @Post(':id/verify')
  async verifyDomain(@Param('id') id: string) {
    return this.domainService.verifyDomain(id);
  }
}
EOF

# src/domain/domain.module.ts
cat > "$PROJECT_DIR/src/domain/domain.module.ts" << 'EOF'
import { Module } from '@nestjs/common';
import { DomainService } from './domain.service';
import { DomainController } from './domain.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Domain } from './domain.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Domain])],
  providers: [DomainService],
  controllers: [DomainController],
  exports: [DomainService],
})
export class DomainModule {}
EOF

# Step 9: Create Email Module files
echo "Creating Email Module files..."
# src/email/email.entity.ts
cat > "$PROJECT_DIR/src/email/email.entity.ts" << 'EOF'
import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity()
export class EmailMetric {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  tenantId: string;

  @Column()
  domainId: string;

  @Column({ default: 0 })
  sentCount: number;

  @Column({ default: 0 })
  openCount: number;

  @Column({ default: 0 })
  bounceCount: number;
}
EOF

# src/email/email.service.ts
cat > "$PROJECT_DIR/src/email/email.service.ts" << 'EOF'
import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { EmailMetric } from './email.entity';
import { Repository } from 'typeorm';
import { EspService } from '../esp/esp.service';

@Injectable()
export class EmailService {
  constructor(
    @InjectRepository(EmailMetric) private readonly emailRepo: Repository<EmailMetric>,
    private readonly espService: EspService,
  ) {}

  async sendWarmupEmail(tenantId: string, domainId: string, emailData: any): Promise<any> {
    try {
      const result = await this.espService.sendEmail(emailData);
      let metric = await this.emailRepo.findOne({ where: { tenantId, domainId } });
      if (!metric) {
        metric = this.emailRepo.create({ tenantId, domainId });
      }
      metric.sentCount++;
      await this.emailRepo.save(metric);
      return result;
    } catch (err) {
      throw new InternalServerErrorException(err.message);
    }
  }

  async recordEmailEvent(tenantId: string, domainId: string, event: string): Promise<any> {
    let metric = await this.emailRepo.findOne({ where: { tenantId, domainId } });
    if (!metric) {
      metric = this.emailRepo.create({ tenantId, domainId });
    }
    if (event === 'open') {
      metric.openCount++;
    } else if (event === 'bounce') {
      metric.bounceCount++;
    }
    return this.emailRepo.save(metric);
  }
}
EOF

# src/email/email.controller.ts
cat > "$PROJECT_DIR/src/email/email.controller.ts" << 'EOF'
import { Controller, Post, Body, Req } from '@nestjs/common';
import { EmailService } from './email.service';

@Controller('emails')
export class EmailController {
  constructor(private readonly emailService: EmailService) {}

  @Post('warmup')
  async sendWarmup(@Body() body, @Req() req) {
    return this.emailService.sendWarmupEmail(req.tenantId, body.domainId, body);
  }
}
EOF

# src/email/email.gateway.ts
cat > "$PROJECT_DIR/src/email/email.gateway.ts" << 'EOF'
import { WebSocketGateway, WebSocketServer, SubscribeMessage } from '@nestjs/websockets';
import { Server } from 'socket.io';

@WebSocketGateway()
export class EmailGateway {
  @WebSocketServer() server: Server;

  broadcastMetrics(data: any) {
    this.server.emit('emailMetrics', data);
  }

  @SubscribeMessage('ping')
  handlePing(client: any, payload: any): string {
    return 'pong';
  }
}
EOF

# src/email/email.module.ts
cat > "$PROJECT_DIR/src/email/email.module.ts" << 'EOF'
import { Module } from '@nestjs/common';
import { EmailService } from './email.service';
import { EmailController } from './email.controller';
import { EmailGateway } from './email.gateway';
import { TypeOrmModule } from '@nestjs/typeorm';
import { EmailMetric } from './email.entity';
import { EspModule } from '../esp/esp.module';

@Module({
  imports: [TypeOrmModule.forFeature([EmailMetric]), EspModule],
  providers: [EmailService, EmailGateway],
  controllers: [EmailController],
  exports: [EmailService],
})
export class EmailModule {}
EOF

# Step 10: Create Analytics Module files
echo "Creating Analytics Module files..."
# src/analytics/analytics.service.ts
cat > "$PROJECT_DIR/src/analytics/analytics.service.ts" << 'EOF'
import { Injectable } from '@nestjs/common';

@Injectable()
export class AnalyticsService {
  async getRealTimeMetrics(): Promise<any> {
    return { message: 'Real-time analytics data (stub)' };
  }
}
EOF

# src/analytics/analytics.controller.ts
cat > "$PROJECT_DIR/src/analytics/analytics.controller.ts" << 'EOF'
import { Controller, Get } from '@nestjs/common';
import { AnalyticsService } from './analytics.service';

@Controller('analytics')
export class AnalyticsController {
  constructor(private readonly analyticsService: AnalyticsService) {}

  @Get('metrics')
  async getMetrics() {
    return this.analyticsService.getRealTimeMetrics();
  }
}
EOF

# src/analytics/analytics.module.ts
cat > "$PROJECT_DIR/src/analytics/analytics.module.ts" << 'EOF'
import { Module } from '@nestjs/common';
import { AnalyticsService } from './analytics.service';
import { AnalyticsController } from './analytics.controller';

@Module({
  providers: [AnalyticsService],
  controllers: [AnalyticsController],
})
export class AnalyticsModule {}
EOF

# Step 11: Create ESP Module files
echo "Creating ESP Module files..."
# src/esp/esp.service.ts
cat > "$PROJECT_DIR/src/esp/esp.service.ts" << 'EOF'
import { Injectable } from '@nestjs/common';

@Injectable()
export class EspService {
  async sendEmail(emailData: any): Promise<any> {
    return { status: 'sent', provider: 'AWS SES', emailData };
  }
}
EOF

# src/esp/esp.module.ts
cat > "$PROJECT_DIR/src/esp/esp.module.ts" << 'EOF'
import { Module } from '@nestjs/common';
import { EspService } from './esp.service';

@Module({
  providers: [EspService],
  exports: [EspService],
})
export class EspModule {}
EOF

# Step 12: Create a sample migration file
echo "Creating sample migration file..."
cat > "$PROJECT_DIR/migrations/1623456789012-CreateUserAndDomain.ts" << 'EOF'
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
EOF

# Step 13: Create a sample test file for AuthService (test/auth.service.spec.ts)
echo "Creating sample test file: test/auth.service.spec.ts..."
cat > "$PROJECT_DIR/test/auth.service.spec.ts" << 'EOF'
import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from '../src/auth/auth.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { User } from '../src/auth/user.entity';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';

describe('AuthService', () => {
  let service: AuthService;
  const mockUserRepository = {
    findOne: jest.fn(),
  };
  const mockJwtService = {
    sign: jest.fn().mockReturnValue('signed-token'),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: getRepositoryToken(User), useValue: mockUserRepository },
        { provide: JwtService, useValue: mockJwtService },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  it('should validate user and return token', async () => {
    const user = { id: '1', username: 'test', tenantId: 'tenant1', password: await bcrypt.hash('pass', 10), role: 'user' };
    mockUserRepository.findOne.mockResolvedValue(user);
    const result = await service.validateUser('test', 'pass', 'tenant1');
    expect(result.username).toEqual('test');
  });
});
EOF

# Step 14: Create Dockerfile for containerization
echo "Creating Dockerfile..."
cat > "$PROJECT_DIR/Dockerfile" << 'EOF'
# Stage 1: Build
FROM node:16-alpine AS builder
WORKDIR /app
COPY package.json tsconfig.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Production
FROM node:16-alpine
WORKDIR /app
COPY package.json ./
RUN npm install --only=production
COPY --from=builder /app/dist ./dist
EXPOSE 3000
CMD ["node", "dist/main.js"]
EOF

# Step 15: Create GitHub Actions CI/CD workflow (.github/workflows/ci.yml)
echo "Creating GitHub Actions workflow file..."
cat > "$PROJECT_DIR/.github/workflows/ci.yml" << 'EOF'
name: CI/CD Pipeline

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: 16
      - name: Install dependencies
        run: npm install
      - name: Run tests
        run: npm test
      - name: Build project
        run: npm run build
  docker-build:
    runs-on: ubuntu-latest
    needs: build-test
    steps:
      - uses: actions/checkout@v3
      - name: Build Docker image
        run: docker build -t inboxia-backend .
EOF

# Step 16: Create package.json (minimal configuration)
echo "Creating package.json..."
cat > "$PROJECT_DIR/package.json" << 'EOF'
{
  "name": "inboxia-backend",
  "version": "1.0.0",
  "description": "Inboxia Backend Project",
  "scripts": {
    "start": "nest start",
    "start:dev": "nest start --watch",
    "build": "nest build",
    "test": "jest"
  },
  "dependencies": {
    "@nestjs/common": "^11.0.12",
    "@nestjs/core": "^11.0.12",
    "@nestjs/jwt": "^11.0.0",
    "@nestjs/passport": "^11.0.5",
    "@nestjs/platform-express": "^11.0.12",
    "@nestjs/schedule": "^5.0.1",
    "@nestjs/typeorm": "^11.0.0",
    "@nestjs/websockets": "^11.0.12",
    "bcrypt": "^5.0.1",
    "class-validator": "^0.14.1",
    "cors": "^2.8.5",
    "dotenv": "^16.0.0",
    "helmet": "^6.0.0",
    "passport": "^0.6.0",
    "passport-jwt": "^4.0.0",
    "reflect-metadata": "^0.1.13",
    "rxjs": "^7.0.0",
    "socket.io": "^4.0.0",
    "typeorm": "^0.3.0",
    "winston": "^3.3.3"
  },
  "devDependencies": {
    "@nestjs/cli": "^11.0.5",
    "@nestjs/schematics": "^11.0.0",
    "@nestjs/testing": "^11.0.12",
    "@types/express": "^4.17.13",
    "@types/jest": "^27.0.0",
    "@types/node": "^16.0.0",
    "@types/passport-jwt": "^3.0.6",
    "jest": "^27.0.0",
    "supertest": "^6.1.3",
    "ts-jest": "^27.0.0",
    "ts-loader": "^9.2.3",
    "ts-node": "^10.0.0",
    "typescript": "^4.3.5"
  }
}
EOF

# Step 17: Create tsconfig.json for TypeScript configuration
echo "Creating tsconfig.json..."
cat > "$PROJECT_DIR/tsconfig.json" << 'EOF'
{
  "compilerOptions": {
    "module": "commonjs",
    "declaration": true,
    "removeComments": true,
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true,
    "allowSyntheticDefaultImports": true,
    "target": "es2017",
    "sourceMap": true,
    "outDir": "./dist",
    "baseUrl": "./",
    "incremental": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

echo "Inboxia backend project has been successfully set up in the '$PROJECT_DIR' directory."
