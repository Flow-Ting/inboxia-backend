import { Domain } from './domain.entity';
import { Repository } from 'typeorm';
export declare class DomainService {
    private readonly domainRepo;
    constructor(domainRepo: Repository<Domain>);
    createDomain(tenantId: string, name: string): Promise<Domain>;
    verifyDomain(domainId: string): Promise<Domain>;
}
