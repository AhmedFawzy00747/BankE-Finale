using BankE.Application.Common;
using BankE.Application.DTOs;
using BankE.Application.Interfaces;
using BankE.Domain.Entities;
using BankE.Domain.Interfaces;
using PdfSharp.Pdf;
using PdfSharp.Drawing;

namespace BankE.Application.Services
{
    public class AccountService : IAccountService
    {
        private readonly IUnitOfWork _unitOfWork;
        public AccountService(IUnitOfWork unitOfWork) => _unitOfWork = unitOfWork;

        public async Task<ApiResponse<AccountInfoResponse>> GetInfoAsync(int userId)
        {
            var account = await _unitOfWork.Accounts.GetByUserIdAsync(userId);
            if (account == null) return ApiResponse<AccountInfoResponse>.Fail("Account not found");

            var user = await _unitOfWork.Users.GetByIdAsync(userId);

            return ApiResponse<AccountInfoResponse>.Ok(new AccountInfoResponse(
                account.AccountNumber,
                account.Balance,
                user?.FullName ?? "",
                account.CreatedAt,
                user?.AvatarUrl
            ));
        }

        public async Task<ApiResponse<IEnumerable<TransactionResponse>>> GetTransactionsAsync(int userId)
        {
            var account = await _unitOfWork.Accounts.GetByUserIdAsync(userId);
            if (account == null) return ApiResponse<IEnumerable<TransactionResponse>>.Fail("Account not found");

            var transactions = await _unitOfWork.Transactions.GetByAccountIdAsync(account.Id);
            var response = transactions.Select(t => new TransactionResponse(
                t.Id,
                t.SenderAccount?.User?.FullName ?? "System",
                t.ReceiverAccount?.User?.FullName ?? "System",
                t.Amount,
                t.Description ?? string.Empty,
                t.Status,
                GetTransactionType(t, account.Id),
                t.CreatedAt
            ));

            return ApiResponse<IEnumerable<TransactionResponse>>.Ok(response);
        }

        public async Task<ApiResponse<TransactionResponse>> GetTransactionByIdAsync(int userId, int transactionId)
        {
            var account = await _unitOfWork.Accounts.GetByUserIdAsync(userId);
            if (account == null) return ApiResponse<TransactionResponse>.Fail("Account not found");

            var transaction = await _unitOfWork.Transactions.GetByIdWithDetailsAsync(transactionId);
            if (transaction == null) return ApiResponse<TransactionResponse>.Fail("Transaction not found");

            if (transaction.SenderAccountId != account.Id && transaction.ReceiverAccountId != account.Id)
                return ApiResponse<TransactionResponse>.Fail("Access denied");

            if (transaction.Status != "Completed")
                return ApiResponse<TransactionResponse>.Fail("Access denied");

            var response = new TransactionResponse(
                transaction.Id,
                transaction.SenderAccount?.User?.FullName ?? "System",
                transaction.ReceiverAccount?.User?.FullName ?? "System",
                transaction.Amount,
                transaction.Description ?? string.Empty,
                transaction.Status,
                GetTransactionType(transaction, account.Id),
                transaction.CreatedAt
            );

            return ApiResponse<TransactionResponse>.Ok(response);
        }

        private static string GetTransactionType(Transaction transaction, int accountId)
        {
            if (transaction.Description?.StartsWith("ATM Deposit", StringComparison.OrdinalIgnoreCase) == true)
                return "Credit";

            if (transaction.Description?.StartsWith("ATM Withdrawal", StringComparison.OrdinalIgnoreCase) == true)
                return "Debit";

            return transaction.SenderAccountId == accountId ? "Debit" : "Credit";
        }

        public async Task<ApiResponse<byte[]>> GenerateStatementPdfAsync(int userId, DateTime startDate, DateTime endDate)
        {
            var account = await _unitOfWork.Accounts.GetByUserIdAsync(userId);
            if (account == null) return ApiResponse<byte[]>.Fail("Account not found");

            var user = await _unitOfWork.Users.GetByIdAsync(userId);
            var transactions = await _unitOfWork.Transactions.GetByAccountIdAsync(account.Id);

            // Filter transactions by date range
            var filteredTransactions = transactions
                .Where(t => t.CreatedAt >= startDate.ToUniversalTime() && t.CreatedAt <= endDate.ToUniversalTime())
                .OrderByDescending(t => t.CreatedAt)
                .ToList();

            using var memoryStream = new System.IO.MemoryStream();
            
            // Create PDF Document
            var document = new PdfDocument();
            document.Info.Title = "Account Statement";
            
            var page = document.AddPage();
            var gfx = XGraphics.FromPdfPage(page);
            
            // Fonts (using Standard Font Names compatible with PDFsharp v6)
            var fontTitle = new XFont("Arial", 20, XFontStyleEx.Bold);
            var fontHeader = new XFont("Arial", 12, XFontStyleEx.Bold);
            var fontBody = new XFont("Arial", 10, XFontStyleEx.Regular);
            var fontBold = new XFont("Arial", 10, XFontStyleEx.Bold);

            // Title
            gfx.DrawString("BankE Account Statement", fontTitle, XBrushes.Navy, new XPoint(40, 50));
            
            // Account Details
            gfx.DrawString($"Account Holder: {user?.FullName}", fontBold, XBrushes.Black, new XPoint(40, 90));
            gfx.DrawString($"Account Number: {account.AccountNumber}", fontBody, XBrushes.Black, new XPoint(40, 110));
            gfx.DrawString($"Statement Period: {startDate:yyyy-MM-dd} to {endDate:yyyy-MM-dd}", fontBody, XBrushes.Black, new XPoint(40, 130));
            gfx.DrawString($"Current Balance: {account.Balance:N2}", fontBold, XBrushes.Black, new XPoint(40, 150));

            // Table Headers
            gfx.DrawString("Date", fontHeader, XBrushes.Navy, new XPoint(40, 200));
            gfx.DrawString("Description", fontHeader, XBrushes.Navy, new XPoint(140, 200));
            gfx.DrawString("Type", fontHeader, XBrushes.Navy, new XPoint(360, 200));
            gfx.DrawString("Amount", fontHeader, XBrushes.Navy, new XPoint(460, 200));

            // Line
            gfx.DrawLine(XPens.Navy, 40, 210, 560, 210);

            int y = 230;
            foreach (var tx in filteredTransactions)
            {
                if (y > 750) // Basic pagination
                {
                    page = document.AddPage();
                    gfx = XGraphics.FromPdfPage(page);
                    gfx.DrawLine(XPens.Navy, 40, 40, 560, 40);
                    y = 60;
                }

                var type = GetTransactionType(tx, account.Id);
                gfx.DrawString(tx.CreatedAt.ToString("yyyy-MM-dd HH:mm"), fontBody, XBrushes.Black, new XPoint(40, y));
                
                string desc = tx.Description ?? "Transfer";
                if (desc.Length > 35) desc = desc.Substring(0, 32) + "...";
                gfx.DrawString(desc, fontBody, XBrushes.Black, new XPoint(140, y));
                
                gfx.DrawString(type, fontBody, XBrushes.Black, new XPoint(360, y));
                
                var amountColor = type == "Credit" ? XBrushes.Green : XBrushes.Red;
                var amountText = (type == "Credit" ? "+" : "-") + $"{tx.Amount:N2}";
                gfx.DrawString(amountText, fontBold, amountColor, new XPoint(460, y));
                
                y += 20;
            }

            document.Save(memoryStream);
            return ApiResponse<byte[]>.Ok(memoryStream.ToArray());
        }

        public async Task<ApiResponse<DashboardStatsResponse>> GetDashboardStatsAsync(int userId)
        {
            var account = await _unitOfWork.Accounts.GetByUserIdAsync(userId);
            if (account == null) return ApiResponse<DashboardStatsResponse>.Fail("Account not found");

            var cards = await _unitOfWork.Cards.FindAsync(c => c.AccountId == account.Id);
            var activeCardsCount = cards.Count(c => c.Status.Equals("active", System.StringComparison.OrdinalIgnoreCase));

            var loans = await _unitOfWork.Loans.FindAsync(l => l.UserId == userId);
            var totalLoansCount = loans.Count();
            var totalLoanAmount = loans.Sum(l => l.Amount);

            var savingsGoals = await _unitOfWork.SavingGoals.GetByUserIdAsync(userId);
            var totalSavings = savingsGoals.Sum(s => s.CurrentAmount);

            var transactions = await _unitOfWork.Transactions.GetByAccountIdAsync(account.Id);
            
            var now = DateTime.UtcNow;
            var currentMonthTransactions = transactions
                .Where(t => t.CreatedAt.Month == now.Month && t.CreatedAt.Year == now.Year)
                .ToList();

            var monthlyIncome = currentMonthTransactions
                .Where(t => GetTransactionType(t, account.Id) == "Credit")
                .Sum(t => t.Amount);

            var monthlyExpense = currentMonthTransactions
                .Where(t => GetTransactionType(t, account.Id) == "Debit")
                .Sum(t => t.Amount);

            var recentTransactions = transactions
                .OrderByDescending(t => t.CreatedAt)
                .Take(5)
                .Select(t => new TransactionResponse(
                    t.Id,
                    t.SenderAccount?.User?.FullName ?? "System",
                    t.ReceiverAccount?.User?.FullName ?? "System",
                    t.Amount,
                    t.Description ?? string.Empty,
                    t.Status,
                    GetTransactionType(t, account.Id),
                    t.CreatedAt
                ))
                .ToList();

            var spendingByCategory = currentMonthTransactions
                .Where(t => GetTransactionType(t, account.Id) == "Debit")
                .GroupBy(t => Categorize(t.Description))
                .Select(g => new CategorySpendingDto(g.Key, g.Sum(t => t.Amount)))
                .ToList();

            var response = new DashboardStatsResponse(
                account.Balance,
                monthlyIncome,
                monthlyExpense,
                totalSavings,
                activeCardsCount,
                totalLoansCount,
                totalLoanAmount,
                spendingByCategory,
                recentTransactions
            );

            return ApiResponse<DashboardStatsResponse>.Ok(response);
        }

        private static string Categorize(string? description)
        {
            if (string.IsNullOrEmpty(description)) return "Miscellaneous";
            var desc = description.ToLower();
            if (desc.Contains("bill") || desc.Contains("electricity") || desc.Contains("water") || desc.Contains("gas") || desc.Contains("internet"))
                return "Utilities";
            if (desc.Contains("grocery") || desc.Contains("coffee") || desc.Contains("food") || desc.Contains("restaurant") || desc.Contains("cafe"))
                return "Food & Dining";
            if (desc.Contains("transfer") || desc.Contains("sent"))
                return "Transfers";
            if (desc.Contains("store") || desc.Contains("shop") || desc.Contains("buy") || desc.Contains("market") || desc.Contains("amazon"))
                return "Shopping";
            if (desc.Contains("movie") || desc.Contains("cinema") || desc.Contains("game") || desc.Contains("subscription") || desc.Contains("netflix"))
                return "Entertainment";
            return "Miscellaneous";
        }
    }
}
