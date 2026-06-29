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
    public class ScheduledTransfersController : ControllerBase
    {
        private readonly IScheduledTransferService _scheduledTransferService;

        public ScheduledTransfersController(IScheduledTransferService scheduledTransferService)
        {
            _scheduledTransferService = scheduledTransferService;
        }

        private int CurrentUserId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        [HttpPost]
        public async Task<IActionResult> Create(ScheduledTransferRequest request)
        {
            var result = await _scheduledTransferService.CreateScheduledTransferAsync(CurrentUserId, request);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }

        [HttpGet]
        public async Task<IActionResult> Get()
        {
            var result = await _scheduledTransferService.GetScheduledTransfersAsync(CurrentUserId);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Edit(int id, ScheduledTransferRequest request)
        {
            var result = await _scheduledTransferService.EditScheduledTransferAsync(CurrentUserId, id, request);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Cancel(int id)
        {
            var result = await _scheduledTransferService.CancelScheduledTransferAsync(CurrentUserId, id);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }
    }
}
