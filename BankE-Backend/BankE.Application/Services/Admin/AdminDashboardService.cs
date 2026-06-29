using BankE.Application.Common;
using BankE.Application.Interfaces;
using BankE.Domain.Interfaces;

namespace BankE.Application.Services
{
    public class AdminDashboardService : IAdminDashboardService
    {
        private readonly IUnitOfWork _unitOfWork;

        public AdminDashboardService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<ApiResponse<object>> GetDashboardStatsAsync()
        {
            var users = await _unitOfWork.Users.GetAllAsync();
            var loans = await _unitOfWork.Loans.GetAllAsync();
            var transactions = await _unitOfWork.Transactions.GetAllAsync();
            var cards = await _unitOfWork.Cards.GetAllAsync();

            var activeCards = cards.Count(c => c.Status.Equals("active", StringComparison.OrdinalIgnoreCase));

            // Monthly statistics: Group users, transactions, and loans by month (last 6 months)
            var last6Months = Enumerable.Range(0, 6)
                .Select(i => DateTime.UtcNow.AddMonths(-i))
                .Select(d => new { d.Year, d.Month })
                .Reverse()
                .ToList();

            var monthlyStats = last6Months.Select(m => new
            {
                Month = $"{m.Year}-{m.Month:D2}",
                UserRegistrations = users.Count(u => u.CreatedAt.Year == m.Year && u.CreatedAt.Month == m.Month),
                TransactionCount = transactions.Count(t => t.CreatedAt.Year == m.Year && t.CreatedAt.Month == m.Month),
                LoanApplications = loans.Count(l => l.AppliedAt.Year == m.Year && l.AppliedAt.Month == m.Month)
            }).ToList();

            return ApiResponse<object>.Ok(new
            {
                TotalUsers = users.Count(),
                TotalTransactions = transactions.Count(),
                TotalLoans = loans.Count(),
                ActiveCards = activeCards,
                MonthlyStatistics = monthlyStats
            });
        }
    }
}
