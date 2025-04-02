import { Test, TestingModule } from '@nestjs/testing';
import { EmailService } from '../src/email/email.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { EmailMetric } from '../src/email/email.entity';
import { EspService } from '../src/esp/esp.service';

describe('EmailService', () => {
  let service: EmailService;
  const mockEmailRepository = {
    findOne: jest.fn(),
    create: jest.fn().mockImplementation(dto => dto),
    save: jest.fn().mockImplementation(email => Promise.resolve({ id: '1', ...email })),
  };

  const mockEspService = {
    sendEmail: jest.fn().mockResolvedValue({ status: 'sent', provider: 'AWS SES', emailData: {} }),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        EmailService,
        { provide: getRepositoryToken(EmailMetric), useValue: mockEmailRepository },
        { provide: EspService, useValue: mockEspService },
      ],
    }).compile();

    service = module.get<EmailService>(EmailService);
  });

  it('should send a warmup email and increment sentCount', async () => {
    const result = await service.sendWarmupEmail('tenant1', 'domain1', { subject: 'Test', body: 'Hello' });
    expect(result.status).toEqual('sent');
    expect(mockEmailRepository.findOne).toHaveBeenCalled();
    expect(mockEmailRepository.save).toHaveBeenCalled();
  });
});
