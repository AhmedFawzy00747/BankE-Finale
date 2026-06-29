using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BankE.Domain.Entities
{
    public class ScheduledTransfer
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int SenderAccountId { get; set; }

        [ForeignKey("SenderAccountId")]
        public virtual Account SenderAccount { get; set; } = null!;

        [Required]
        [MaxLength(50)]
        public string ReceiverAccountNumber { get; set; } = string.Empty;

        [Column(TypeName = "decimal(18,2)")]
        public decimal Amount { get; set; }

        [MaxLength(200)]
        public string? Description { get; set; }

        [Required]
        public DateTime ScheduledDate { get; set; }

        [Required]
        [MaxLength(20)]
        public string Frequency { get; set; } = "Once"; // Once, Daily, Weekly, Monthly

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? LastExecutedAt { get; set; }

        public DateTime NextExecutionDate { get; set; }
    }
}
