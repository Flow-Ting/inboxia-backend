import { Test, TestingModule } from '@nestjs/testing';
import { DomainService } from '../src/domain/domain.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Domain } from '../src/domain/domain.entity';

describe('DomainService', () => {
  let service: DomainService;
  const mockDomainRepository = {
    create: jest.fn().mockImplementation(dto => dto),
    save: jest.fn().mockImplementation(domain => Promise.resolve({ id: '1', ...domain })),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        DomainService,
        { provide: getRepositoryToken(Domain), useValue: mockDomainRepository },
      ],
    }).compile();

    service = module.get<DomainService>(DomainService);
  });

  it('should create a domain with the correct tenantId and name', async () => {
    const result = await service.createDomain('tenant1', 'example.com');
    expect(result.tenantId).toEqual('tenant1');
    expect(result.name).toEqual('example.com');
    expect(result.id).toBeDefined();
  });
});
