namespace BankE.Application.DTOs
{
    public record SearchResultItem(
        string Type, // Transaction, Beneficiary, Bill, Notification, Card
        int Id,
        string Title,
        string Subtitle,
        string? ExtraInfo,
        DateTime Date);

    public record SearchResponse(
        IEnumerable<SearchResultItem> Items,
        int TotalCount,
        bool HasMore);
}
