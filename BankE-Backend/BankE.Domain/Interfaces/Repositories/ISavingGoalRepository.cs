using BankE.Domain.Entities;

namespace BankE.Domain.Interfaces
{
    public interface ISavingGoalRepository : IRepository<SavingGoal>
    {
        Task<IEnumerable<SavingGoal>> GetByUserIdAsync(int userId);
    }
}
