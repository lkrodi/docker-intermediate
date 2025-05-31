import { Controller, Get } from '@nestjs/common';

@Controller('health')
export class HealthController {
  @Get()
  checkHealth() {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      service: 'task-manager-api',
      version: '1.0.0',
    };
  }

  @Get('ready')
  checkReadiness() {
    return {
      status: 'ready',
      timestamp: new Date().toISOString(),
    };
  }

  @Get('live')
  checkLiveness() {
    return {
      status: 'alive',
      timestamp: new Date().toISOString(),
    };
  }
}
