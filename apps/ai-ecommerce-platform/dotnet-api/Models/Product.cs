using System.ComponentModel.DataAnnotations;
using System.Text.Json;

namespace EcommerceAI.Models;

public class Product
{
    public int Id { get; set; }
    
    [Required]
    [MaxLength(100)]
    public string SourceProductId { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(100)]
    public string SourceSite { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(500)]
    public string Title { get; set; } = string.Empty;
    
    public string Description { get; set; } = string.Empty;
    
    [Required]
    public decimal SourcePrice { get; set; }
    
    public decimal MarketPrice { get; set; }
    
    [Required]
    [MaxLength(3)]
    public string Currency { get; set; } = "CAD";
    
    public string ImagesJson { get; set; } = "[]";
    
    [Required]
    [MaxLength(100)]
    public string Category { get; set; } = string.Empty;
    
    public bool IsActive { get; set; } = true;
    public bool Availability { get; set; } = true;
    
    public string SupplierInfoJson { get; set; } = "{}";
    public string SpecificationsJson { get; set; } = "{}";
    public string ShippingInfoJson { get; set; } = "{}";
    
    public int ReviewsCount { get; set; }
    public decimal Rating { get; set; }
    
    [MaxLength(50)]
    public string InventoryLevel { get; set; } = "In Stock";
    
    public DateTime ScrapedAt { get; set; } = DateTime.UtcNow;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    
    // Helper properties to work with JSON fields
    public List<string> Images
    {
        get => JsonSerializer.Deserialize<List<string>>(ImagesJson) ?? new List<string>();
        set => ImagesJson = JsonSerializer.Serialize(value);
    }
    
    public Dictionary<string, object> SupplierInfo
    {
        get => JsonSerializer.Deserialize<Dictionary<string, object>>(SupplierInfoJson) ?? new Dictionary<string, object>();
        set => SupplierInfoJson = JsonSerializer.Serialize(value);
    }
    
    public Dictionary<string, object> Specifications
    {
        get => JsonSerializer.Deserialize<Dictionary<string, object>>(SpecificationsJson) ?? new Dictionary<string, object>();
        set => SpecificationsJson = JsonSerializer.Serialize(value);
    }
    
    public Dictionary<string, object> ShippingInfo
    {
        get => JsonSerializer.Deserialize<Dictionary<string, object>>(ShippingInfoJson) ?? new Dictionary<string, object>();
        set => ShippingInfoJson = JsonSerializer.Serialize(value);
    }
    
    // Navigation properties
    public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
}
