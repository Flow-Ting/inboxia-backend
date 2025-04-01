import { Injectable } from '@nestjs/common';

@Injectable()
export class AnalyticsService {
  async getRealTimeMetrics(): Promise<any> {
    return { message: 'Real-time analytics data (stub)' };
  }
}
