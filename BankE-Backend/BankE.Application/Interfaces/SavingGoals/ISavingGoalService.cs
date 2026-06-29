using BankE.Application.Common;
using BankE.Application.DTOs;

namespace BankE.Application.Interfaces
{
    public interface ISavingGoalService
    {
        Task<ApiResponse<SavingGoalResponse>> CreateSavingGoalAsync(int userId, SavingGoalRequest request);
        Task<ApiResponse<IEnumerable<SavingGoalResponse>>> GetSavingGoalsAsync(int userId);
        Task<ApiResponse<SavingGoalResponse>> EditSavingGoalAsync(int userId, int id, SavingGoalRequest request);
        Task<ApiResponse<SavingGoalResponse>> AddFundsAsync(int userId, int id, decimal amount);
        Task<ApiResponse<SavingGoalResponse>> WithdrawFundsAsync(int userId, int id, decimal amount);
        Task<ApiResponse> DeleteSavingGoalAsync(int userId, int id);
    }
}
