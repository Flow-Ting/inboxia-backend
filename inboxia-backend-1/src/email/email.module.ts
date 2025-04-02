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
