export interface LabelingOptions {
    justification?: string;
    metadata?: Record<string, string>;
    watermarkText?: string;
}
export interface LabelingResult {
    success: boolean;
    labelId: string;
    protectedContent: Buffer;
    metadata: Record<string, any>;
}
