export interface SupportRecord {
  id: string;
  amount: number;
  tierName: string;
  paidAt: string;
  transactionId: string;
}

export enum SupportPaymentStatus {
  SUCCESS = 'success',
  CANCELLED = 'cancelled',
  FAILED = 'failed',
  PENDING = 'pending',
  UNAVAILABLE = 'unavailable'
}

export interface SupportPaymentResult {
  status: SupportPaymentStatus;
  transactionId: string;
  message: string;
}
