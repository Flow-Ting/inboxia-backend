import { Test, TestingModule } from '@nestjs/testing';
import { AnalyticsService } from '../src/analytics/analytics.service';

describe('AnalyticsService', () => {
  let service: AnalyticsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [AnalyticsService],
    }).compile();
    service = module.get<AnalyticsService>(AnalyticsService);
  });

  it('should return stub analytics data', async () => {
    const data = await service.getRealTimeMetrics();
    expect(data).toHaveProperty('message');
  });
});
