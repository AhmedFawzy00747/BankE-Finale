namespace BankE.Application.DTOs
{
    public record AccountInfoResponse(string AccountNumber, decimal Balance, string OwnerName, DateTime CreatedAt, string? AvatarUrl = null);

    public record DashboardStatsResponse(
        decimal Balance,
        decimal MonthlyIncome,
        decimal MonthlyExpense,
        decimal TotalSavings,
        int ActiveCardsCount,
        int TotalLoansCount,
        decimal TotalLoanAmount,
        IEnumerable<CategorySpendingDto> SpendingByCategory,
        IEnumerable<TransactionResponse> RecentTransactions);

    public record CategorySpendingDto(string Category, decimal Amount);
}
