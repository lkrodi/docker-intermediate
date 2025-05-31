import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';

import { AuthModule } from './auth/auth.module';
import { TasksModule } from './tasks/task.module';
import { UsersModule } from './users/users.module';
import { HealthModule } from './health/health.module';

import { User } from './users/user.entity';
import { Task } from './tasks/task.entity';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT) || 5433,
      username: process.env.DB_USERNAME || 'postgres',
      password: process.env.DB_PASSWORD || 'password',
      database: process.env.DB_NAME || 'taskmanager',
      entities: [User, Task],
      synchronize: process.env.NODE_ENV !== 'production',
      logging: process.env.NODE_ENV === 'development',
    }),
    AuthModule,
    TasksModule,
    UsersModule,
    HealthModule,
  ],
})
export class AppModule {}
