import { DomainService } from './domain.service';
export declare class DomainController {
    private readonly domainService;
    constructor(domainService: DomainService);
    createDomain(name: string, req: any): Promise<import("./domain.entity").Domain>;
    verifyDomain(id: string): Promise<import("./domain.entity").Domain>;
}
