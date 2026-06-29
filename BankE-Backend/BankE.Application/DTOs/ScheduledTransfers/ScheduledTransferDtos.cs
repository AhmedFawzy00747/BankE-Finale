namespace BankE.Application.DTOs
{
    public record ScheduledTransferRequest(
        string ReceiverAccountNumber,
        decimal Amount,
        string? Description,
        DateTime ScheduledDate,
        string Frequency); // Once, Daily, Weekly, Monthly

    public record ScheduledTransferResponse(
        int Id,
        string ReceiverAccountNumber,
        decimal Amount,
        string? Description,
        DateTime ScheduledDate,
        string Frequency,
        bool IsActive,
        DateTime CreatedAt,
        DateTime? LastExecutedAt,
        DateTime NextExecutionDate);
}
