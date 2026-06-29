using BankE.Application.Common;
using BankE.Application.DTOs;
using BankE.Application.Interfaces;
using BankE.Domain.Entities;
using BankE.Domain.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BankE.Application.Services
{
    public class CardsService : ICardsService
    {
        private readonly IUnitOfWork _unitOfWork;

        public CardsService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<ApiResponse<IEnumerable<CardResponse>>> GetCardsAsync(int userId)
        {
            var account = await _unitOfWork.Accounts.GetByUserIdAsync(userId);
            if (account == null) return ApiResponse<IEnumerable<CardResponse>>.Fail("Account not found");

            var cards = await _unitOfWork.Cards.FindAsync(c => c.AccountId == account.Id);
            return ApiResponse<IEnumerable<CardResponse>>.Ok(cards.Select(c => new CardResponse(
                c.Id, 
                c.StripeCardId, 
                c.CardNumber.Length > 4 ? new string('*', c.CardNumber.Length - 4) + c.Last4 : c.Last4,
                "", // Never return CVV in any response
                c.Last4, 
                c.Brand, 
                c.ExpiryMonth, 
                c.ExpiryYear, 
                c.CardHolderName, 
                c.CardType, 
                c.Status, 
                c.IsFrozen, 
                c.IsVirtual,
                c.Pin,
                c.OnlinePaymentsEnabled,
                c.AtmWithdrawalsEnabled,
                c.InternationalTransactionsEnabled)));
        }

        public async Task<ApiResponse<CardResponse>> AddCardAsync(int userId, AddCardRequest request)
        {
            var account = await _unitOfWork.Accounts.GetByUserIdAsync(userId);
            if (account == null) return ApiResponse<CardResponse>.Fail("Account not found");

            var user = await _unitOfWork.Users.GetByIdAsync(userId);
            if (user == null) return ApiResponse<CardResponse>.Fail("User not found");

            // 1. Validation
            if (string.IsNullOrWhiteSpace(request.CardHolderName))
            {
                return ApiResponse<CardResponse>.Fail("Card holder name is required.");
            }

            if (string.IsNullOrWhiteSpace(request.CardNumber) || !request.CardNumber.All(char.IsDigit) || request.CardNumber.Length < 12 || request.CardNumber.Length > 19)
            {
                return ApiResponse<CardResponse>.Fail("Card number must be numeric and between 12 and 19 digits.");
            }

            if (request.ExpiryMonth < 1 || request.ExpiryMonth > 12)
            {
                return ApiResponse<CardResponse>.Fail("Expiry month must be between 1 and 12.");
            }

            var currentYear = DateTime.UtcNow.Year;
            var currentMonth = DateTime.UtcNow.Month;
            var expiryYear = request.ExpiryYear < 100 ? 2000 + request.ExpiryYear : request.ExpiryYear;

            if (expiryYear < currentYear || (expiryYear == currentYear && request.ExpiryMonth < currentMonth))
            {
                return ApiResponse<CardResponse>.Fail("The card has expired.");
            }

            if (string.IsNullOrWhiteSpace(request.Cvv) || !request.Cvv.All(char.IsDigit) || request.Cvv.Length < 3 || request.Cvv.Length > 4)
            {
                return ApiResponse<CardResponse>.Fail("CVV must be 3 or 4 digits.");
            }

            var normalizedCardType = request.CardType?.Trim();
            if (string.IsNullOrWhiteSpace(normalizedCardType) || 
                (!normalizedCardType.Equals("Visa", StringComparison.OrdinalIgnoreCase) && 
                 !normalizedCardType.Equals("Mastercard", StringComparison.OrdinalIgnoreCase)))
            {
                return ApiResponse<CardResponse>.Fail("Card type must be either 'Visa' or 'Mastercard'.");
            }

            // 2. Check for duplicate cards for the same user
            var existingCards = await _unitOfWork.Cards.FindAsync(c => c.AccountId == account.Id);
            if (existingCards.Any(c => c.CardNumber == request.CardNumber))
            {
                return ApiResponse<CardResponse>.Fail("This card is already linked to your account.");
            }

            // 3. Store CVV directly for demo purposes
            // TODO: PCI DSS does not allow storing CVV in production.
            var last4 = request.CardNumber.Substring(request.CardNumber.Length - 4);
            var brand = normalizedCardType.Equals("Mastercard", StringComparison.OrdinalIgnoreCase) ? "Mastercard" : "Visa";

            var card = new Card
            {
                AccountId = account.Id,
                StripeCardId = "linked_" + Guid.NewGuid().ToString("N"),
                CardNumber = request.CardNumber,
                Cvv = request.Cvv,
                Last4 = last4,
                Brand = brand,
                ExpiryMonth = request.ExpiryMonth,
                ExpiryYear = expiryYear,
                CardHolderName = request.CardHolderName,
                CardType = brand,
                Status = "active",
                IsVirtual = request.IsVirtual,
                IsFrozen = false
            };

            try
            {
                await _unitOfWork.Cards.AddAsync(card);
                await _unitOfWork.SaveChangesAsync();
            }
            catch (Exception ex)
            {
                Console.WriteLine("====================================");
                Console.WriteLine(ex.ToString());
                Console.WriteLine("====================================");
                throw;
            }

            return ApiResponse<CardResponse>.Ok(new CardResponse(
                card.Id, 
                card.StripeCardId, 
                new string('*', card.CardNumber.Length - 4) + card.Last4,
                "", // Never return CVV in any response
                card.Last4, 
                card.Brand, 
                card.ExpiryMonth, 
                card.ExpiryYear, 
                card.CardHolderName, 
                card.CardType, 
                card.Status, 
                card.IsFrozen, 
                card.IsVirtual,
                card.Pin,
                card.OnlinePaymentsEnabled,
                card.AtmWithdrawalsEnabled,
                card.InternationalTransactionsEnabled));
        }

        public async Task<ApiResponse> ToggleFreezeAsync(int userId, int cardId)
        {
            var card = await _unitOfWork.Cards.GetByIdAsync(cardId);
            if (card == null) return ApiResponse.Fail("Card not found");

            card.IsFrozen = !card.IsFrozen;
            card.Status = card.IsFrozen ? "inactive" : "active";

            _unitOfWork.Cards.Update(card);
            await _unitOfWork.SaveChangesAsync();
            return ApiResponse.Ok(card.IsFrozen ? "Card frozen successfully" : "Card unfrozen successfully");
        }

        public async Task<ApiResponse> DeleteCardAsync(int userId, int cardId)
        {
            var card = await _unitOfWork.Cards.GetByIdAsync(cardId);
            if (card == null) return ApiResponse.Fail("Card not found");

            _unitOfWork.Cards.Remove(card);
            await _unitOfWork.SaveChangesAsync();
            return ApiResponse.Ok("Card deleted successfully");
        }

        public async Task<ApiResponse> UpdateControlsAsync(int userId, int cardId, UpdateCardControlsRequest request)
        {
            var card = await _unitOfWork.Cards.GetByIdAsync(cardId);
            if (card == null) return ApiResponse.Fail("Card not found");

            card.OnlinePaymentsEnabled = request.OnlinePaymentsEnabled;
            card.AtmWithdrawalsEnabled = request.AtmWithdrawalsEnabled;
            card.InternationalTransactionsEnabled = request.InternationalTransactionsEnabled;

            _unitOfWork.Cards.Update(card);
            await _unitOfWork.SaveChangesAsync();
            return ApiResponse.Ok("Card controls updated successfully");
        }

        public async Task<ApiResponse> ChangePinAsync(int userId, int cardId, ChangeCardPinRequest request)
        {
            var card = await _unitOfWork.Cards.GetByIdAsync(cardId);
            if (card == null) return ApiResponse.Fail("Card not found");

            if (string.IsNullOrEmpty(request.NewPin) || request.NewPin.Length != 4 || !request.NewPin.All(char.IsDigit))
            {
                return ApiResponse.Fail("PIN must be exactly 4 digits");
            }

            card.Pin = request.NewPin;

            _unitOfWork.Cards.Update(card);
            await _unitOfWork.SaveChangesAsync();
            return ApiResponse.Ok("Card PIN changed successfully");
        }

    }
}
