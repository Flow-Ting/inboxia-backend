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
      // Example: Check SPF records via DNS lookup
      const spfRecords = await dns.resolveTxt(domain.name);
      domain.spfVerified = spfRecords.some(rec => rec.join('').includes('v=spf1'));
      // DKIM and DMARC verifications are placeholders for now
      domain.dkimVerified = true;
      domain.dmarcVerified = true;
      return this.domainRepo.save(domain);
    } catch (err) {
      domain.verificationError = err.message;
      return this.domainRepo.save(domain);
    }
  }
}
