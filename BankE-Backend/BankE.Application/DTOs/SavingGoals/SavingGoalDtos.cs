namespace BankE.Application.DTOs
{
    public record SavingGoalRequest(
        string Name,
        decimal TargetAmount,
        decimal CurrentAmount,
        DateTime? TargetDate);

    public record SavingGoalResponse(
        int Id,
        string Name,
        decimal TargetAmount,
        decimal CurrentAmount,
        DateTime? TargetDate,
        DateTime CreatedAt,
        double CompletionPercentage);

    public record AddFundsRequest(decimal Amount);
    public record WithdrawFundsRequest(decimal Amount);
}
