using BankE.Domain.Entities;
using BankE.Domain.Interfaces;
using BankE.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace BankE.Infrastructure.Repositories
{
    public class ScheduledTransferRepository : Repository<ScheduledTransfer>, IScheduledTransferRepository
    {
        public ScheduledTransferRepository(BankEDbContext context) : base(context) { }

        public async Task<IEnumerable<ScheduledTransfer>> GetActiveScheduledTransfersAsync()
        {
            return await _dbSet
                .Include(s => s.SenderAccount)
                .ThenInclude(a => a.User)
                .Where(s => s.IsActive && s.NextExecutionDate <= DateTime.UtcNow)
                .ToListAsync();
        }

        public async Task<IEnumerable<ScheduledTransfer>> GetByAccountIdAsync(int accountId)
        {
            return await _dbSet
                .Where(s => s.SenderAccountId == accountId)
                .ToListAsync();
        }
    }
}
