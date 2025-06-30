using System.ComponentModel.DataAnnotations;

namespace EcommerceAI.Models;

public class Order
{
    public int Id { get; set; }
    
    [Required]
    public string UserId { get; set; } = string.Empty;
    
    public ApplicationUser User { get; set; } = null!;
    
    [Required]
    [EmailAddress]
    public string CustomerEmail { get; set; } = string.Empty;
    
    public string CustomerName { get; set; } = string.Empty;
    
    [Required]
    public decimal TotalAmount { get; set; }
    
    [MaxLength(3)]
    public string Currency { get; set; } = "CAD";
    
    public OrderStatus Status { get; set; } = OrderStatus.Pending;
    
    public string PaymentIntentId { get; set; } = string.Empty;
    public string ShippingAddressJson { get; set; } = "{}";
    public string BillingAddressJson { get; set; } = "{}";
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation properties
    public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
}

public class OrderItem
{
    public int Id { get; set; }
    
    public int OrderId { get; set; }
    public int ProductId { get; set; }
    
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal TotalPrice { get; set; }
    
    // Navigation properties
    public virtual Order Order { get; set; } = null!;
    public virtual Product Product { get; set; } = null!;
}

public enum OrderStatus
{
    Pending,
    Paid,
    Processing,
    Shipped,
    Delivered,
    Cancelled,
    Refunded
}
