namespace BankE.Application.DTOs
{
    public record BudgetRequest(
        string Category,
        decimal Amount,
        int Month,
        int Year,
        decimal? SpentAmount = null);

    public record BudgetResponse(
        int Id,
        string Category,
        decimal Amount,
        int Month,
        int Year,
        DateTime CreatedAt,
        decimal SpentAmount);

    public record BudgetProgressResponse(
        string Category,
        decimal BudgetAmount,
        decimal SpentAmount,
        decimal RemainingAmount,
        bool ExceedsBudget,
        int? BudgetId = null);
}
