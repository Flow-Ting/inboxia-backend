import { Controller, Post, Body, Param, Req } from '@nestjs/common';
import { DomainService } from './domain.service';

@Controller('domains')
export class DomainController {
  constructor(private readonly domainService: DomainService) {}

  @Post()
  async createDomain(@Body('name') name: string, @Req() req) {
    return this.domainService.createDomain(req.tenantId, name);
  }

  @Post(':id/verify')
  async verifyDomain(@Param('id') id: string) {
    return this.domainService.verifyDomain(id);
  }
}
