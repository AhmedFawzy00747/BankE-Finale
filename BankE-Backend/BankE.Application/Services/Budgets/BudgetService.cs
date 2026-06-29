using BankE.Application.Common;
using BankE.Application.DTOs;
using BankE.Application.Interfaces;
using BankE.Domain.Entities;
using BankE.Domain.Interfaces;

namespace BankE.Application.Services
{
    public class BudgetService : IBudgetService
    {
        private readonly IUnitOfWork _unitOfWork;

        public BudgetService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<ApiResponse<BudgetResponse>> SetBudgetAsync(int userId, BudgetRequest request)
        {
            var user = await _unitOfWork.Users.GetByIdAsync(userId);
            if (user == null) return ApiResponse<BudgetResponse>.Fail("User not found");

            if (request.Amount <= 0) return ApiResponse<BudgetResponse>.Fail("Budget amount must be greater than zero");

            var existingBudget = await _unitOfWork.Budgets.GetByCategoryAsync(userId, request.Category, request.Month, request.Year);
            if (existingBudget != null)
            {
                existingBudget.Amount = request.Amount;
                existingBudget.SpentAmount = request.SpentAmount ?? existingBudget.SpentAmount;
                _unitOfWork.Budgets.Update(existingBudget);
            }
            else
            {
                existingBudget = new Budget
                {
                    UserId = userId,
                    Category = request.Category,
                    Amount = request.Amount,
                    SpentAmount = request.SpentAmount ?? 0,
                    Month = request.Month,
                    Year = request.Year,
                    CreatedAt = DateTime.UtcNow
                };
                await _unitOfWork.Budgets.AddAsync(existingBudget);
            }

            await _unitOfWork.SaveChangesAsync();
            return ApiResponse<BudgetResponse>.Ok(new BudgetResponse(
                existingBudget.Id,
                existingBudget.Category,
                existingBudget.Amount,
                existingBudget.Month,
                existingBudget.Year,
                existingBudget.CreatedAt,
                existingBudget.SpentAmount
            ));
        }

        public async Task<ApiResponse<IEnumerable<BudgetResponse>>> GetBudgetsAsync(int userId)
        {
            var budgets = await _unitOfWork.Budgets.GetByUserIdAsync(userId);
            var response = budgets.Select(b => new BudgetResponse(
                b.Id,
                b.Category,
                b.Amount,
                b.Month,
                b.Year,
                b.CreatedAt,
                b.SpentAmount
            ));
            return ApiResponse<IEnumerable<BudgetResponse>>.Ok(response);
        }

        public async Task<ApiResponse<IEnumerable<BudgetProgressResponse>>> GetBudgetProgressAsync(int userId, int month, int year)
        {
            var account = await _unitOfWork.Accounts.GetByUserIdAsync(userId);
            if (account == null) return ApiResponse<IEnumerable<BudgetProgressResponse>>.Fail("Account not found");

            var budgets = await _unitOfWork.Budgets.GetByUserIdAsync(userId);
            var activeBudgets = budgets.Where(b => b.Month == month && b.Year == year).ToList();

            var transactions = await _unitOfWork.Transactions.GetByAccountIdAsync(account.Id);
            var monthlyExpenses = transactions
                .Where(t => t.CreatedAt.Month == month && t.CreatedAt.Year == year && t.SenderAccountId == account.Id)
                .ToList();

            var progressList = new List<BudgetProgressResponse>();

            // Categories defined in Budget or derived from transactions
            var categories = activeBudgets.Select(b => b.Category).Union(
                monthlyExpenses.Select(t => Categorize(t.Description)).Distinct()
            ).ToList();

            foreach (var cat in categories)
            {
                var budget = activeBudgets.FirstOrDefault(b => b.Category.Equals(cat, StringComparison.OrdinalIgnoreCase));
                var budgetAmount = budget?.Amount ?? 0;

                var spentAmount = budget != null ? budget.SpentAmount : monthlyExpenses
                    .Where(t => Categorize(t.Description).Equals(cat, StringComparison.OrdinalIgnoreCase))
                    .Sum(t => t.Amount);

                progressList.Add(new BudgetProgressResponse(
                    cat,
                    budgetAmount,
                    spentAmount,
                    budgetAmount - spentAmount,
                    budgetAmount > 0 && spentAmount > budgetAmount,
                    budget?.Id
                ));
            }

            return ApiResponse<IEnumerable<BudgetProgressResponse>>.Ok(progressList);
        }

        public async Task<ApiResponse<BudgetResponse>> UpdateBudgetAsync(int userId, int id, BudgetRequest request)
        {
            var budget = await _unitOfWork.Budgets.GetByIdAsync(id);
            if (budget == null || budget.UserId != userId) return ApiResponse<BudgetResponse>.Fail("Budget not found");

            if (request.Amount <= 0) return ApiResponse<BudgetResponse>.Fail("Budget amount must be greater than zero");

            budget.Category = request.Category;
            budget.Amount = request.Amount;
            budget.SpentAmount = request.SpentAmount ?? budget.SpentAmount;
            budget.Month = request.Month;
            budget.Year = request.Year;

            _unitOfWork.Budgets.Update(budget);
            await _unitOfWork.SaveChangesAsync();

            return ApiResponse<BudgetResponse>.Ok(new BudgetResponse(
                budget.Id,
                budget.Category,
                budget.Amount,
                budget.Month,
                budget.Year,
                budget.CreatedAt,
                budget.SpentAmount
            ));
        }

        public async Task<ApiResponse> DeleteBudgetAsync(int userId, int id)
        {
            var budget = await _unitOfWork.Budgets.GetByIdAsync(id);
            if (budget == null || budget.UserId != userId) return ApiResponse.Fail("Budget not found");

            _unitOfWork.Budgets.Remove(budget);
            await _unitOfWork.SaveChangesAsync();
            return ApiResponse.Ok();
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
