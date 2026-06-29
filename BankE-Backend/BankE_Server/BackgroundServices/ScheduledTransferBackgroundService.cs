using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using BankE.Domain.Interfaces;
using BankE.Application.Interfaces;
using BankE.Application.DTOs;
using BankE.Application.Common;
using BankE.Application.Services;

namespace BankE.API.BackgroundServices
{
    public class ScheduledTransferBackgroundService : BackgroundService
    {
        private readonly IServiceScopeFactory _serviceScopeFactory;
        private readonly ILogger<ScheduledTransferBackgroundService> _logger;

        public ScheduledTransferBackgroundService(IServiceScopeFactory serviceScopeFactory, ILogger<ScheduledTransferBackgroundService> logger)
        {
            _serviceScopeFactory = serviceScopeFactory;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("Scheduled Transfer Background Service is starting.");

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    await ProcessScheduledTransfersAsync();
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error occurred while processing scheduled transfers.");
                }

                // Check every 60 seconds
                await Task.Delay(TimeSpan.FromSeconds(60), stoppingToken);
            }

            _logger.LogInformation("Scheduled Transfer Background Service is stopping.");
        }

        private async Task ProcessScheduledTransfersAsync()
        {
            using var scope = _serviceScopeFactory.CreateScope();
            var unitOfWork = scope.ServiceProvider.GetRequiredService<IUnitOfWork>();
            var transferService = scope.ServiceProvider.GetRequiredService<ITransferService>();
            var notificationService = scope.ServiceProvider.GetRequiredService<INotificationService>();

            var dueTransfers = await unitOfWork.ScheduledTransfers.GetActiveScheduledTransfersAsync();

            foreach (var transfer in dueTransfers)
            {
                var senderUserId = transfer.SenderAccount.UserId;
                _logger.LogInformation("Executing scheduled transfer {Id} from User {UserId} to Account {Receiver}", transfer.Id, senderUserId, transfer.ReceiverAccountNumber);

                var transferRequest = new TransferRequest(transfer.ReceiverAccountNumber, transfer.Amount, transfer.Description ?? "Scheduled Transfer");
                var result = await transferService.TransferAsync(senderUserId, transferRequest);

                if (result.Success)
                {
                    transfer.LastExecutedAt = DateTime.UtcNow;
                    UpdateNextExecutionDate(transfer);
                }
                else
                {
                    _logger.LogWarning("Scheduled transfer {Id} failed: {Message}", transfer.Id, result.Message);
                    // Deactivate and notify user
                    transfer.IsActive = false;
                    await NotificationDispatch.TrySendAsync(notificationService, senderUserId, "Scheduled Transfer Failed", $"Your scheduled transfer of {transfer.Amount:N2} to {transfer.ReceiverAccountNumber} failed: {result.Message}", "Transfer", 0, "Sender");
                }

                unitOfWork.ScheduledTransfers.Update(transfer);
            }

            if (dueTransfers.Any())
            {
                await unitOfWork.SaveChangesAsync();
            }
        }

        private static void UpdateNextExecutionDate(Domain.Entities.ScheduledTransfer s)
        {
            switch (s.Frequency.ToLower())
            {
                case "daily":
                    s.NextExecutionDate = s.NextExecutionDate.AddDays(1);
                    break;
                case "weekly":
                    s.NextExecutionDate = s.NextExecutionDate.AddDays(7);
                    break;
                case "monthly":
                    s.NextExecutionDate = s.NextExecutionDate.AddMonths(1);
                    break;
                default:
                    s.IsActive = false; // Once or unknown
                    break;
            }
        }
    }
}
