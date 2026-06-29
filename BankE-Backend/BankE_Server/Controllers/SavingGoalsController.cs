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
    public class SavingGoalsController : ControllerBase
    {
        private readonly ISavingGoalService _savingGoalService;

        public SavingGoalsController(ISavingGoalService savingGoalService)
        {
            _savingGoalService = savingGoalService;
        }

        private int CurrentUserId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        [HttpPost]
        public async Task<IActionResult> Create(SavingGoalRequest request)
        {
            var result = await _savingGoalService.CreateSavingGoalAsync(CurrentUserId, request);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }

        [HttpGet]
        public async Task<IActionResult> Get()
        {
            var result = await _savingGoalService.GetSavingGoalsAsync(CurrentUserId);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Edit(int id, SavingGoalRequest request)
        {
            var result = await _savingGoalService.EditSavingGoalAsync(CurrentUserId, id, request);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }

        [HttpPost("{id}/add-funds")]
        public async Task<IActionResult> AddFunds(int id, AddFundsRequest request)
        {
            var result = await _savingGoalService.AddFundsAsync(CurrentUserId, id, request.Amount);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }

        [HttpPost("{id}/withdraw-funds")]
        public async Task<IActionResult> WithdrawFunds(int id, WithdrawFundsRequest request)
        {
            var result = await _savingGoalService.WithdrawFundsAsync(CurrentUserId, id, request.Amount);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var result = await _savingGoalService.DeleteSavingGoalAsync(CurrentUserId, id);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }
    }
}
