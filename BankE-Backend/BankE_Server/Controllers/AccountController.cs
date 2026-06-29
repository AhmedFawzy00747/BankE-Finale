using System.Security.Claims;
using BankE.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BankE.API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class AccountController : ControllerBase
    {
        private readonly IAccountService _accountService;

        public AccountController(IAccountService accountService) => _accountService = accountService;

        private int CurrentUserId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        [HttpGet("info")]
        public async Task<IActionResult> GetInfo()
        {
            var result = await _accountService.GetInfoAsync(CurrentUserId);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }

        [HttpGet("transactions")]
        public async Task<IActionResult> GetTransactions()
        {
            var result = await _accountService.GetTransactionsAsync(CurrentUserId);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }

        [HttpGet("transactions/{id}")]
        public async Task<IActionResult> GetTransactionById(int id)
        {
            var result = await _accountService.GetTransactionByIdAsync(CurrentUserId, id);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }

        [HttpGet("statement")]
        public async Task<IActionResult> GetStatement([FromQuery] DateTime startDate, [FromQuery] DateTime endDate)
        {
            var result = await _accountService.GenerateStatementPdfAsync(CurrentUserId, startDate, endDate);
            if (!result.Success) return BadRequest(result);
            return File(result.Data!, "application/pdf", $"Statement_{startDate:yyyyMMdd}_{endDate:yyyyMMdd}.pdf");
        }

        [HttpGet("dashboard")]
        public async Task<IActionResult> GetDashboardStats()
        {
            var result = await _accountService.GetDashboardStatsAsync(CurrentUserId);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }
    }
}
