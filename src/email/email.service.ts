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
