using BankE.Domain.Entities;

namespace BankE.Domain.Interfaces
{
    public interface IBudgetRepository : IRepository<Budget>
    {
        Task<IEnumerable<Budget>> GetByUserIdAsync(int userId);
        Task<Budget?> GetByCategoryAsync(int userId, string category, int month, int year);
    }
}
