using BankE.Application.Common;
using BankE.Application.DTOs;

namespace BankE.Application.Interfaces
{
    public interface ISearchService
    {
        Task<ApiResponse<SearchResponse>> GlobalSearchAsync(int userId, string query, int page, int pageSize);
    }
}
