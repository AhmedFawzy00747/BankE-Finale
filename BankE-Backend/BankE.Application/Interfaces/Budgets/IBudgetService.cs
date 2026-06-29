using BankE.Application.Common;
using BankE.Application.DTOs;

namespace BankE.Application.Interfaces
{
    public interface IBudgetService
    {
        Task<ApiResponse<BudgetResponse>> SetBudgetAsync(int userId, BudgetRequest request);
        Task<ApiResponse<IEnumerable<BudgetResponse>>> GetBudgetsAsync(int userId);
        Task<ApiResponse<IEnumerable<BudgetProgressResponse>>> GetBudgetProgressAsync(int userId, int month, int year);
        Task<ApiResponse<BudgetResponse>> UpdateBudgetAsync(int userId, int id, BudgetRequest request);
        Task<ApiResponse> DeleteBudgetAsync(int userId, int id);
    }
}
