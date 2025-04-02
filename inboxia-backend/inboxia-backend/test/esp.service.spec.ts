import { Test, TestingModule } from '@nestjs/testing';
import { EspService } from '../src/esp/esp.service';

describe('EspService', () => {
  let service: EspService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [EspService],
    }).compile();
    service = module.get<EspService>(EspService);
  });

  it('should simulate sending an email', async () => {
    const result = await service.sendEmail({ subject: 'Test', body: 'Hello' });
    expect(result.status).toEqual('sent');
    expect(result.provider).toEqual('AWS SES');
  });
});
