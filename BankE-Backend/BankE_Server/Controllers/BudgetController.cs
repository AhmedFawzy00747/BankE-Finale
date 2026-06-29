using System.Security.Claims;
using BankE.Application.DTOs;
using BankE.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BankE.API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class BudgetController : ControllerBase
    {
        private readonly IBudgetService _budgetService;

        public BudgetController(IBudgetService budgetService)
        {
            _budgetService = budgetService;
        }

        private int CurrentUserId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        [HttpPost]
        public async Task<IActionResult> SetBudget(BudgetRequest request)
        {
            var result = await _budgetService.SetBudgetAsync(CurrentUserId, request);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }

        [HttpGet]
        public async Task<IActionResult> GetBudgets()
        {
            var result = await _budgetService.GetBudgetsAsync(CurrentUserId);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }

        [HttpGet("progress")]
        public async Task<IActionResult> GetProgress([FromQuery] int month, [FromQuery] int year)
        {
            var result = await _budgetService.GetBudgetProgressAsync(CurrentUserId, month, year);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, BudgetRequest request)
        {
            var result = await _budgetService.UpdateBudgetAsync(CurrentUserId, id, request);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var result = await _budgetService.DeleteBudgetAsync(CurrentUserId, id);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }
    }
}
