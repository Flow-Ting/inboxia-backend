import { EmailMetric } from './email.entity';
import { Repository } from 'typeorm';
import { EspService } from '../esp/esp.service';
export declare class EmailService {
    private readonly emailRepo;
    private readonly espService;
    constructor(emailRepo: Repository<EmailMetric>, espService: EspService);
    sendWarmupEmail(tenantId: string, domainId: string, emailData: any): Promise<any>;
    recordEmailEvent(tenantId: string, domainId: string, event: string): Promise<any>;
}
