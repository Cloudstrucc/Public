using System.ComponentModel.DataAnnotations;

namespace EcommerceAI.Models;

public class Customer
{
    public int Id { get; set; }
    
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;
    
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    
    public string DefaultShippingAddress { get; set; } = string.Empty; // JSON
    public string DefaultBillingAddress { get; set; } = string.Empty; // JSON
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime LastLoginAt { get; set; }
    
    public bool IsActive { get; set; } = true;
}

public class ProductAnalytics
{
    public int Id { get; set; }
    public int ProductId { get; set; }
    
    public int Views { get; set; }
    public int CartAdds { get; set; }
    public int Purchases { get; set; }
    public decimal ConversionRate { get; set; }
    
    public DateTime Date { get; set; } = DateTime.UtcNow.Date;
    
    // Navigation properties
    public virtual Product Product { get; set; } = null!;
}

public class MarketInsight
{
    public int Id { get; set; }
    
    public string Keyword { get; set; } = string.Empty;
    public int SearchVolume { get; set; }
    public string Competition { get; set; } = string.Empty;
    public string TrendDirection { get; set; } = string.Empty;
    
    public string RegionalInterest { get; set; } = string.Empty; // JSON
    public string RelatedQueries { get; set; } = string.Empty; // JSON
    
    public decimal PriceSensitivity { get; set; }
    public int DemandScore { get; set; }
    
    public DateTime AnalysisDate { get; set; } = DateTime.UtcNow;
}
