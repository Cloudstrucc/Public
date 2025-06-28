using System.ComponentModel.DataAnnotations;

namespace EcommerceAI.Models;

public class Product
{
    public int Id { get; set; }
    
    [Required]
    public string SourceProductId { get; set; } = string.Empty;
    
    [Required]
    public string SourceSite { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(500)]
    public string Title { get; set; } = string.Empty;
    
    public string Description { get; set; } = string.Empty;
    
    [Required]
    public decimal SourcePrice { get; set; }
    
    public decimal MarketPrice { get; set; }
    
    [Required]
    public string Currency { get; set; } = "CAD";
    
    public List<string> Images { get; set; } = new();
    
    [Required]
    public string Category { get; set; } = string.Empty;
    
    public bool IsActive { get; set; } = true;
    public bool Availability { get; set; } = true;
    
    public string SupplierInfo { get; set; } = string.Empty; // JSON
    public string Specifications { get; set; } = string.Empty; // JSON
    public string ShippingInfo { get; set; } = string.Empty; // JSON
    
    public int ReviewsCount { get; set; }
    public decimal Rating { get; set; }
    public string InventoryLevel { get; set; } = "In Stock";
    
    public DateTime ScrapedAt { get; set; } = DateTime.UtcNow;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation properties
    public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
    public virtual ICollection<ProductAnalytics> Analytics { get; set; } = new List<ProductAnalytics>();
}
