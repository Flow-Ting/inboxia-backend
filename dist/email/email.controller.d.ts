import { EmailService } from './email.service';
export declare class EmailController {
    private readonly emailService;
    constructor(emailService: EmailService);
    sendWarmup(body: any, req: any): Promise<any>;
}
