using BankE.Application.Common;
using BankE.Application.DTOs;
using BankE.Application.Interfaces;
using BankE.Domain.Interfaces;
using System.Globalization;

namespace BankE.Application.Services
{
    public class SearchService : ISearchService
    {
        private readonly IUnitOfWork _unitOfWork;

        public SearchService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<ApiResponse<SearchResponse>> GlobalSearchAsync(int userId, string query, int page, int pageSize)
        {
            if (string.IsNullOrWhiteSpace(query))
            {
                return ApiResponse<SearchResponse>.Ok(new SearchResponse(new List<SearchResultItem>(), 0, false));
            }

            var account = await _unitOfWork.Accounts.GetByUserIdAsync(userId);
            if (account == null) return ApiResponse<SearchResponse>.Fail("Account not found");

            var queryLower = query.ToLower();
            var results = new List<SearchResultItem>();

            // 1. Search Transactions
            var transactions = await _unitOfWork.Transactions.GetByAccountIdAsync(account.Id);
            var matchedTransactions = transactions.Where(t =>
                (t.Description != null && t.Description.ToLower().Contains(queryLower)) ||
                t.Amount.ToString(CultureInfo.InvariantCulture).Contains(queryLower)
            );
            foreach (var tx in matchedTransactions)
            {
                var type = tx.SenderAccountId == account.Id ? "Debit" : "Credit";
                results.Add(new SearchResultItem(
                    "Transaction",
                    tx.Id,
                    tx.Description ?? "Transfer",
                    $"Amount: {(type == "Credit" ? "+" : "-")}{tx.Amount:N2} | Status: {tx.Status}",
                    type,
                    tx.CreatedAt
                ));
            }

            // 2. Search Beneficiaries
            var beneficiaries = await _unitOfWork.Beneficiaries.FindAsync(b => b.UserId == userId);
            var matchedBeneficiaries = beneficiaries.Where(b =>
                b.Name.ToLower().Contains(queryLower) ||
                b.AccountNumber.ToLower().Contains(queryLower)
            );
            foreach (var b in matchedBeneficiaries)
            {
                results.Add(new SearchResultItem(
                    "Beneficiary",
                    b.Id,
                    b.Name,
                    $"Acc Number: {b.AccountNumber}",
                    null,
                    b.CreatedAt
                ));
            }

            // 3. Search Bills
            var bills = await _unitOfWork.BillPayments.FindAsync(b => b.AccountId == account.Id);
            var matchedBills = bills.Where(b =>
                b.BillType.ToLower().Contains(queryLower) ||
                b.ServiceProvider.ToLower().Contains(queryLower) ||
                b.AccountReference.ToLower().Contains(queryLower)
            );
            foreach (var b in matchedBills)
            {
                results.Add(new SearchResultItem(
                    "Bill",
                    b.Id,
                    $"{b.BillType} - {b.ServiceProvider}",
                    $"Ref: {b.AccountReference} | Amount: {b.Amount:N2}",
                    b.Status,
                    b.PaidAt
                ));
            }

            // 4. Search Notifications
            var notifications = await _unitOfWork.Notifications.FindAsync(n => n.UserId == userId);
            var matchedNotifications = notifications.Where(n =>
                n.Title.ToLower().Contains(queryLower) ||
                n.Message.ToLower().Contains(queryLower)
            );
            foreach (var n in matchedNotifications)
            {
                results.Add(new SearchResultItem(
                    "Notification",
                    n.Id,
                    n.Title,
                    n.Message,
                    n.IsRead ? "Read" : "Unread",
                    n.CreatedAt
                ));
            }

            // 5. Search Cards
            var cards = await _unitOfWork.Cards.FindAsync(c => c.AccountId == account.Id);
            var matchedCards = cards.Where(c =>
                c.Brand.ToLower().Contains(queryLower) ||
                c.CardType.ToLower().Contains(queryLower) ||
                c.Last4.Contains(queryLower)
            );
            foreach (var c in matchedCards)
            {
                results.Add(new SearchResultItem(
                    "Card",
                    c.Id,
                    $"{c.Brand} {c.CardType}",
                    $"Card ending in: {c.Last4} | Status: {c.Status}",
                    c.IsFrozen ? "Frozen" : "Active",
                    c.CreatedAt
                ));
            }

            // Order combined results by date descending
            var sortedResults = results.OrderByDescending(r => r.Date).ToList();

            // Pagination
            var totalCount = sortedResults.Count;
            var items = sortedResults.Skip((page - 1) * pageSize).Take(pageSize).ToList();
            var hasMore = (page * pageSize) < totalCount;

            return ApiResponse<SearchResponse>.Ok(new SearchResponse(items, totalCount, hasMore));
        }
    }
}
