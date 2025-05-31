import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Request,
  ValidationPipe,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { IsString, IsOptional, IsEnum, IsDateString } from 'class-validator';
import { TasksService } from './task.service';
import { TaskStatus } from './task.entity';

class CreateTaskDto {
  @IsString()
  title: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsDateString()
  dueDate?: string;
}

class UpdateTaskDto {
  @IsOptional()
  @IsString()
  title?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsEnum(TaskStatus)
  status?: TaskStatus;

  @IsOptional()
  @IsDateString()
  dueDate?: string;
}

@Controller('tasks')
@UseGuards(AuthGuard('jwt'))
export class TasksController {
  constructor(private readonly tasksService: TasksService) {}

  @Post()
  create(@Body(ValidationPipe) createTaskDto: CreateTaskDto, @Request() req) {
    const taskData = {
      ...createTaskDto,
      dueDate: createTaskDto.dueDate
        ? new Date(createTaskDto.dueDate)
        : undefined,
    };
    return this.tasksService.create(taskData, req.user);
  }

  @Get()
  findAll(@Request() req) {
    return this.tasksService.findAll(req.user);
  }

  @Get('stats')
  getStats(@Request() req) {
    return this.tasksService.getStats(req.user);
  }

  @Get(':id')
  findOne(@Param('id') id: string, @Request() req) {
    return this.tasksService.findOne(id, req.user);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body(ValidationPipe) updateTaskDto: UpdateTaskDto,
    @Request() req,
  ) {
    const taskData = {
      ...updateTaskDto,
      dueDate: updateTaskDto.dueDate
        ? new Date(updateTaskDto.dueDate)
        : undefined,
    };
    return this.tasksService.update(id, taskData, req.user);
  }

  @Delete(':id')
  remove(@Param('id') id: string, @Request() req) {
    return this.tasksService.remove(id, req.user);
  }
}
