using BankE.Domain.Entities;

namespace BankE.Domain.Interfaces
{
    public interface IScheduledTransferRepository : IRepository<ScheduledTransfer>
    {
        Task<IEnumerable<ScheduledTransfer>> GetActiveScheduledTransfersAsync();
        Task<IEnumerable<ScheduledTransfer>> GetByAccountIdAsync(int accountId);
    }
}
