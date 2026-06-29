using BankE.Application.Common;
using BankE.Application.DTOs;

namespace BankE.Application.Interfaces
{
    public interface ICardsService
    {
        Task<ApiResponse<IEnumerable<CardResponse>>> GetCardsAsync(int userId);
        Task<ApiResponse<CardResponse>> AddCardAsync(int userId, AddCardRequest request);
        Task<ApiResponse> ToggleFreezeAsync(int userId, int cardId);
        Task<ApiResponse> DeleteCardAsync(int userId, int cardId);
        Task<ApiResponse> UpdateControlsAsync(int userId, int cardId, UpdateCardControlsRequest request);
        Task<ApiResponse> ChangePinAsync(int userId, int cardId, ChangeCardPinRequest request);
    }
}
