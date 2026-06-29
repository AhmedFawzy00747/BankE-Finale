using BankE.Application.Common;
using BankE.Application.DTOs;

namespace BankE.Application.Interfaces
{
    public interface IAccountService
    {
        Task<ApiResponse<AccountInfoResponse>> GetInfoAsync(int userId);
        Task<ApiResponse<IEnumerable<TransactionResponse>>> GetTransactionsAsync(int userId);
        Task<ApiResponse<TransactionResponse>> GetTransactionByIdAsync(int userId, int transactionId);
        Task<ApiResponse<byte[]>> GenerateStatementPdfAsync(int userId, DateTime startDate, DateTime endDate);
        Task<ApiResponse<DashboardStatsResponse>> GetDashboardStatsAsync(int userId);
    }
}
