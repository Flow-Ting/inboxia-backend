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
    // Database configuration using PostgreSQL via TypeORM
    TypeOrmModule.forRoot({
      type: 'postgres',
      url: process.env.DATABASE_URL,
      autoLoadEntities: true,
      synchronize: false, // Use migrations for schema changes
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
    // Apply tenant middleware globally to enforce multi-tenancy
    consumer.apply(TenantMiddleware).forRoutes('*');
  }
}
