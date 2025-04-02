import { Module } from '@nestjs/common';
import { EspService } from './esp.service';

@Module({
  providers: [EspService],
  exports: [EspService],
})
export class EspModule {}
