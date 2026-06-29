using BankE.Domain.Entities;
using BankE.Domain.Interfaces;
using BankE.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace BankE.Infrastructure.Repositories
{
    public class SavingGoalRepository : Repository<SavingGoal>, ISavingGoalRepository
    {
        public SavingGoalRepository(BankEDbContext context) : base(context) { }

        public async Task<IEnumerable<SavingGoal>> GetByUserIdAsync(int userId)
        {
            return await _dbSet
                .Where(s => s.UserId == userId)
                .ToListAsync();
        }
    }
}
