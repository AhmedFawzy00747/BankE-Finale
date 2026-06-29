using BankE.Application.Common;
using BankE.Application.DTOs;

namespace BankE.Application.Interfaces
{
    public interface IScheduledTransferService
    {
        Task<ApiResponse<ScheduledTransferResponse>> CreateScheduledTransferAsync(int userId, ScheduledTransferRequest request);
        Task<ApiResponse<IEnumerable<ScheduledTransferResponse>>> GetScheduledTransfersAsync(int userId);
        Task<ApiResponse<ScheduledTransferResponse>> EditScheduledTransferAsync(int userId, int id, ScheduledTransferRequest request);
        Task<ApiResponse> CancelScheduledTransferAsync(int userId, int id);
    }
}
