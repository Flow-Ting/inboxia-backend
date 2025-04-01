import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity()
export class Domain {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  tenantId: string;

  @Column()
  name: string;

  @Column({ default: false })
  spfVerified: boolean;

  @Column({ default: false })
  dkimVerified: boolean;

  @Column({ default: false })
  dmarcVerified: boolean;

  @Column({ nullable: true })
  verificationError: string;
}
