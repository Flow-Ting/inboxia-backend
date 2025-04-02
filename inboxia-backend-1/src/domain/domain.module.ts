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
