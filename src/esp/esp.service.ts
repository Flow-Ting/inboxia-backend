import { Injectable } from '@nestjs/common';

@Injectable()
export class EspService {
  async sendEmail(emailData: any): Promise<any> {
    return { status: 'sent', provider: 'AWS SES', emailData };
  }
}
