import { Controller, Post, Body, Req } from '@nestjs/common';
import { EmailService } from './email.service';

@Controller('emails')
export class EmailController {
  constructor(private readonly emailService: EmailService) {}

  @Post('warmup')
  async sendWarmup(@Body() body, @Req() req) {
    return this.emailService.sendWarmupEmail(req.tenantId, body.domainId, body);
  }
}
