import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity()
export class EmailMetric {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  tenantId: string;

  @Column()
  domainId: string;

  @Column({ default: 0 })
  sentCount: number;

  @Column({ default: 0 })
  openCount: number;

  @Column({ default: 0 })
  bounceCount: number;
}
