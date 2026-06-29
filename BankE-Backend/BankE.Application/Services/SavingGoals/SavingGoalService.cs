using BankE.Application.Common;
using BankE.Application.DTOs;
using BankE.Application.Interfaces;
using BankE.Domain.Entities;
using BankE.Domain.Interfaces;

namespace BankE.Application.Services
{
    public class SavingGoalService : ISavingGoalService
    {
        private readonly IUnitOfWork _unitOfWork;

        public SavingGoalService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<ApiResponse<SavingGoalResponse>> CreateSavingGoalAsync(int userId, SavingGoalRequest request)
        {
            var user = await _unitOfWork.Users.GetByIdAsync(userId);
            if (user == null) return ApiResponse<SavingGoalResponse>.Fail("User not found");

            if (request.TargetAmount <= 0) return ApiResponse<SavingGoalResponse>.Fail("Target amount must be greater than zero");

            var savingGoal = new SavingGoal
            {
                UserId = userId,
                Name = request.Name,
                TargetAmount = request.TargetAmount,
                CurrentAmount = request.CurrentAmount,
                TargetDate = request.TargetDate?.ToUniversalTime(),
                CreatedAt = DateTime.UtcNow
            };

            await _unitOfWork.SavingGoals.AddAsync(savingGoal);
            await _unitOfWork.SaveChangesAsync();

            return ApiResponse<SavingGoalResponse>.Ok(MapToResponse(savingGoal));
        }

        public async Task<ApiResponse<IEnumerable<SavingGoalResponse>>> GetSavingGoalsAsync(int userId)
        {
            var goals = await _unitOfWork.SavingGoals.GetByUserIdAsync(userId);
            return ApiResponse<IEnumerable<SavingGoalResponse>>.Ok(goals.Select(MapToResponse));
        }

        public async Task<ApiResponse<SavingGoalResponse>> EditSavingGoalAsync(int userId, int id, SavingGoalRequest request)
        {
            var goal = await _unitOfWork.SavingGoals.GetByIdAsync(id);
            if (goal == null || goal.UserId != userId) return ApiResponse<SavingGoalResponse>.Fail("Saving goal not found");

            if (request.TargetAmount <= 0) return ApiResponse<SavingGoalResponse>.Fail("Target amount must be greater than zero");

            goal.Name = request.Name;
            goal.TargetAmount = request.TargetAmount;
            goal.TargetDate = request.TargetDate?.ToUniversalTime();

            _unitOfWork.SavingGoals.Update(goal);
            await _unitOfWork.SaveChangesAsync();

            return ApiResponse<SavingGoalResponse>.Ok(MapToResponse(goal));
        }

        public async Task<ApiResponse<SavingGoalResponse>> AddFundsAsync(int userId, int id, decimal amount)
        {
            if (amount <= 0) return ApiResponse<SavingGoalResponse>.Fail("Amount must be greater than zero");

            var account = await _unitOfWork.Accounts.GetByUserIdAsync(userId);
            if (account == null) return ApiResponse<SavingGoalResponse>.Fail("Account not found");

            if (account.Balance < amount) return ApiResponse<SavingGoalResponse>.Fail("Insufficient balance");

            var goal = await _unitOfWork.SavingGoals.GetByIdAsync(id);
            if (goal == null || goal.UserId != userId) return ApiResponse<SavingGoalResponse>.Fail("Saving goal not found");

            await _unitOfWork.BeginTransactionAsync();
            try
            {
                account.Balance -= amount;
                goal.CurrentAmount += amount;

                // Create a transaction to reflect this transfer to savings
                var transaction = new Transaction
                {
                    SenderAccountId = account.Id,
                    ReceiverAccountId = account.Id, // Self transaction for transfer to savings goal
                    Amount = amount,
                    Description = $"Savings Goal Deposit: {goal.Name}",
                    Status = "Completed",
                    CreatedAt = DateTime.UtcNow
                };

                await _unitOfWork.Transactions.AddAsync(transaction);
                _unitOfWork.Accounts.Update(account);
                _unitOfWork.SavingGoals.Update(goal);

                await _unitOfWork.SaveChangesAsync();
                await _unitOfWork.CommitTransactionAsync();
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync();
                return ApiResponse<SavingGoalResponse>.Fail("Error adding funds: " + ex.Message);
            }

            return ApiResponse<SavingGoalResponse>.Ok(MapToResponse(goal));
        }

        public async Task<ApiResponse<SavingGoalResponse>> WithdrawFundsAsync(int userId, int id, decimal amount)
        {
            if (amount <= 0) return ApiResponse<SavingGoalResponse>.Fail("Amount must be greater than zero");

            var account = await _unitOfWork.Accounts.GetByUserIdAsync(userId);
            if (account == null) return ApiResponse<SavingGoalResponse>.Fail("Account not found");

            var goal = await _unitOfWork.SavingGoals.GetByIdAsync(id);
            if (goal == null || goal.UserId != userId) return ApiResponse<SavingGoalResponse>.Fail("Saving goal not found");

            if (goal.CurrentAmount < amount) return ApiResponse<SavingGoalResponse>.Fail("Requested amount exceeds the current saved amount.");

            await _unitOfWork.BeginTransactionAsync();
            try
            {
                account.Balance += amount;
                goal.CurrentAmount -= amount;

                // Create a transaction to reflect this transfer from savings
                var transaction = new Transaction
                {
                    SenderAccountId = account.Id,
                    ReceiverAccountId = account.Id, // Self transaction
                    Amount = amount,
                    Description = $"Savings Goal Withdrawal: {goal.Name}",
                    Status = "Completed",
                    CreatedAt = DateTime.UtcNow
                };

                await _unitOfWork.Transactions.AddAsync(transaction);
                _unitOfWork.Accounts.Update(account);
                _unitOfWork.SavingGoals.Update(goal);

                await _unitOfWork.SaveChangesAsync();
                await _unitOfWork.CommitTransactionAsync();
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync();
                return ApiResponse<SavingGoalResponse>.Fail("Error withdrawing funds: " + ex.Message);
            }

            return ApiResponse<SavingGoalResponse>.Ok(MapToResponse(goal));
        }

        public async Task<ApiResponse> DeleteSavingGoalAsync(int userId, int id)
        {
            var goal = await _unitOfWork.SavingGoals.GetByIdAsync(id);
            if (goal == null || goal.UserId != userId) return ApiResponse.Fail("Saving goal not found");

            _unitOfWork.SavingGoals.Remove(goal);
            await _unitOfWork.SaveChangesAsync();
            return ApiResponse.Ok();
        }

        private static SavingGoalResponse MapToResponse(SavingGoal g)
        {
            double pct = 0;
            if (g.TargetAmount > 0)
            {
                pct = (double)(g.CurrentAmount / g.TargetAmount) * 100;
                if (pct > 100) pct = 100;
            }
            return new SavingGoalResponse(
                g.Id,
                g.Name,
                g.TargetAmount,
                g.CurrentAmount,
                g.TargetDate,
                g.CreatedAt,
                pct
            );
        }
    }
}
