using BankE.Application.Common;
using BankE.Application.DTOs;
using BankE.Application.Interfaces;
using BankE.Domain.Entities;
using BankE.Domain.Interfaces;

namespace BankE.Application.Services
{
    public class ScheduledTransferService : IScheduledTransferService
    {
        private readonly IUnitOfWork _unitOfWork;

        public ScheduledTransferService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<ApiResponse<ScheduledTransferResponse>> CreateScheduledTransferAsync(int userId, ScheduledTransferRequest request)
        {
            var senderAccount = await _unitOfWork.Accounts.GetByUserIdAsync(userId);
            if (senderAccount == null) return ApiResponse<ScheduledTransferResponse>.Fail("Sender account not found");

            if (request.Amount <= 0) return ApiResponse<ScheduledTransferResponse>.Fail("Amount must be greater than zero");

            var receiverAccount = await _unitOfWork.Accounts.GetByAccountNumberAsync(request.ReceiverAccountNumber);
            if (receiverAccount == null)
            {
                var receiverUserByPhone = await _unitOfWork.Users.GetByPhoneAsync(request.ReceiverAccountNumber);
                if (receiverUserByPhone != null)
                {
                    receiverAccount = await _unitOfWork.Accounts.GetByUserIdAsync(receiverUserByPhone.Id);
                }
            }

            if (receiverAccount == null) return ApiResponse<ScheduledTransferResponse>.Fail("Receiver account not found");

            if (senderAccount.Id == receiverAccount.Id)
                return ApiResponse<ScheduledTransferResponse>.Fail("Cannot transfer to the same account");

            var scheduledTransfer = new ScheduledTransfer
            {
                SenderAccountId = senderAccount.Id,
                ReceiverAccountNumber = request.ReceiverAccountNumber,
                Amount = request.Amount,
                Description = request.Description,
                ScheduledDate = request.ScheduledDate.ToUniversalTime(),
                Frequency = request.Frequency,
                IsActive = true,
                CreatedAt = DateTime.UtcNow,
                NextExecutionDate = request.ScheduledDate.ToUniversalTime()
            };

            await _unitOfWork.ScheduledTransfers.AddAsync(scheduledTransfer);
            await _unitOfWork.SaveChangesAsync();

            return ApiResponse<ScheduledTransferResponse>.Ok(MapToResponse(scheduledTransfer));
        }

        public async Task<ApiResponse<IEnumerable<ScheduledTransferResponse>>> GetScheduledTransfersAsync(int userId)
        {
            var account = await _unitOfWork.Accounts.GetByUserIdAsync(userId);
            if (account == null) return ApiResponse<IEnumerable<ScheduledTransferResponse>>.Fail("Account not found");

            var scheduled = await _unitOfWork.ScheduledTransfers.GetByAccountIdAsync(account.Id);
            return ApiResponse<IEnumerable<ScheduledTransferResponse>>.Ok(scheduled.Select(MapToResponse));
        }

        public async Task<ApiResponse<ScheduledTransferResponse>> EditScheduledTransferAsync(int userId, int id, ScheduledTransferRequest request)
        {
            var account = await _unitOfWork.Accounts.GetByUserIdAsync(userId);
            if (account == null) return ApiResponse<ScheduledTransferResponse>.Fail("Account not found");

            var scheduled = await _unitOfWork.ScheduledTransfers.GetByIdAsync(id);
            if (scheduled == null || scheduled.SenderAccountId != account.Id)
                return ApiResponse<ScheduledTransferResponse>.Fail("Scheduled transfer not found");

            scheduled.ReceiverAccountNumber = request.ReceiverAccountNumber;
            scheduled.Amount = request.Amount;
            scheduled.Description = request.Description;
            scheduled.ScheduledDate = request.ScheduledDate.ToUniversalTime();
            scheduled.Frequency = request.Frequency;
            scheduled.NextExecutionDate = request.ScheduledDate.ToUniversalTime();

            _unitOfWork.ScheduledTransfers.Update(scheduled);
            await _unitOfWork.SaveChangesAsync();

            return ApiResponse<ScheduledTransferResponse>.Ok(MapToResponse(scheduled));
        }

        public async Task<ApiResponse> CancelScheduledTransferAsync(int userId, int id)
        {
            var account = await _unitOfWork.Accounts.GetByUserIdAsync(userId);
            if (account == null) return ApiResponse.Fail("Account not found");

            var scheduled = await _unitOfWork.ScheduledTransfers.GetByIdAsync(id);
            if (scheduled == null || scheduled.SenderAccountId != account.Id)
                return ApiResponse.Fail("Scheduled transfer not found");

            scheduled.IsActive = false;
            _unitOfWork.ScheduledTransfers.Update(scheduled);
            await _unitOfWork.SaveChangesAsync();

            return ApiResponse.Ok();
        }

        private static ScheduledTransferResponse MapToResponse(ScheduledTransfer s)
        {
            return new ScheduledTransferResponse(
                s.Id,
                s.ReceiverAccountNumber,
                s.Amount,
                s.Description,
                s.ScheduledDate,
                s.Frequency,
                s.IsActive,
                s.CreatedAt,
                s.LastExecutedAt,
                s.NextExecutionDate
            );
        }
    }
}
