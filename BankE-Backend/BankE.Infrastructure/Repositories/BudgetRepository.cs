using BankE.Domain.Entities;
using BankE.Domain.Interfaces;
using BankE.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace BankE.Infrastructure.Repositories
{
    public class BudgetRepository : Repository<Budget>, IBudgetRepository
    {
        public BudgetRepository(BankEDbContext context) : base(context) { }

        public async Task<IEnumerable<Budget>> GetByUserIdAsync(int userId)
        {
            return await _dbSet
                .Where(b => b.UserId == userId)
                .ToListAsync();
        }

        public async Task<Budget?> GetByCategoryAsync(int userId, string category, int month, int year)
        {
            return await _dbSet
                .FirstOrDefaultAsync(b => b.UserId == userId &&
                                          b.Category == category &&
                                          b.Month == month &&
                                          b.Year == year);
        }
    }
}
