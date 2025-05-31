import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Task, TaskStatus } from './task.entity';
import { User } from '../users/user.entity';

export interface CreateTaskDto {
  title: string;
  description?: string;
  dueDate?: Date;
}

export interface UpdateTaskDto {
  title?: string;
  description?: string;
  status?: TaskStatus;
  dueDate?: Date;
}

@Injectable()
export class TasksService {
  constructor(
    @InjectRepository(Task)
    private tasksRepository: Repository<Task>,
  ) {}

  async create(createTaskDto: CreateTaskDto, user: User): Promise<Task> {
    const task = this.tasksRepository.create({
      ...createTaskDto,
      userId: user.id,
    });

    return this.tasksRepository.save(task);
  }

  async findAll(user: User): Promise<Task[]> {
    return this.tasksRepository.find({
      where: { userId: user.id },
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: string, user: User): Promise<Task> {
    const task = await this.tasksRepository.findOne({
      where: { id, userId: user.id },
    });

    if (!task) {
      throw new NotFoundException('Task not found');
    }

    return task;
  }

  async update(
    id: string,
    updateTaskDto: UpdateTaskDto,
    user: User,
  ): Promise<Task> {
    const task = await this.findOne(id, user);

    Object.assign(task, updateTaskDto);
    return this.tasksRepository.save(task);
  }

  async remove(id: string, user: User): Promise<void> {
    const task = await this.findOne(id, user);
    await this.tasksRepository.remove(task);
  }

  async getStats(user: User) {
    const totalTasks = await this.tasksRepository.count({
      where: { userId: user.id },
    });

    const completedTasks = await this.tasksRepository.count({
      where: { userId: user.id, status: TaskStatus.COMPLETED },
    });

    const pendingTasks = await this.tasksRepository.count({
      where: { userId: user.id, status: TaskStatus.PENDING },
    });

    const inProgressTasks = await this.tasksRepository.count({
      where: { userId: user.id, status: TaskStatus.IN_PROGRESS },
    });

    return {
      total: totalTasks,
      completed: completedTasks,
      pending: pendingTasks,
      inProgress: inProgressTasks,
      completionRate: totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0,
    };
  }
}
