import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { UsersService } from '../users/users.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    private usersService: UsersService,
    private configService: ConfigService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey:
        configService.get<string>('JWT_SECRET') ||
        'your-super-secret-jwt-key-change-this-in-production',
    });
  }

  async validate(payload: any) {
    console.log('JWT Strategy - Validating payload:', payload);

    const user = await this.usersService.findById(payload.sub);
    if (!user) {
      console.log('JWT Strategy - User not found for ID:', payload.sub);
      throw new UnauthorizedException('User not found');
    }

    console.log('JWT Strategy - User validated:', user.email);
    return user;
  }
}
