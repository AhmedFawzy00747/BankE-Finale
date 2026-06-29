namespace BankE.Application.DTOs
{
    public record CardResponse(
        int Id,
        string StripeCardId,
        string CardNumber,
        string Cvv,
        string Last4,
        string Brand,
        int ExpiryMonth,
        int ExpiryYear,
        string CardHolderName,
        string CardType,
        string Status,
        bool IsFrozen,
        bool IsVirtual,
        string Pin,
        bool OnlinePaymentsEnabled,
        bool AtmWithdrawalsEnabled,
        bool InternationalTransactionsEnabled);

    public record AddCardRequest(
        string CardHolderName,
        string CardNumber,
        int ExpiryMonth,
        int ExpiryYear,
        string Cvv,
        string CardType,
        bool IsVirtual);

    public record UpdateCardControlsRequest(
        bool OnlinePaymentsEnabled,
        bool AtmWithdrawalsEnabled,
        bool InternationalTransactionsEnabled);

    public record ChangeCardPinRequest(string NewPin);
}
