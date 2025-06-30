using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using EcommerceAI.Data;
using EcommerceAI.Models;

namespace EcommerceAI.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<ProductsController> _logger;

    public ProductsController(ApplicationDbContext context, ILogger<ProductsController> logger)
    {
        _context = context;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Product>>> GetProducts()
    {
        return await _context.Products
            .Where(p => p.IsActive)
            .OrderByDescending(p => p.CreatedAt)
            .Take(100)
            .ToListAsync();
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Product>> GetProduct(int id)
    {
        var product = await _context.Products.FindAsync(id);

        if (product == null)
        {
            return NotFound();
        }

        return product;
    }

    [HttpPost("bulk-import")]
    public async Task<IActionResult> BulkImportProducts([FromBody] List<ProductImportDto> productDtos)
    {
        try
        {
            _logger.LogInformation($"Bulk importing {productDtos.Count} products");
            
            var productsToAdd = new List<Product>();
            
            foreach (var dto in productDtos)
            {
                var existingProduct = await _context.Products
                    .FirstOrDefaultAsync(p => p.SourceProductId == dto.SourceProductId && p.SourceSite == dto.SourceSite);
                
                if (existingProduct != null)
                {
                    existingProduct.Title = dto.Title;
                    existingProduct.Description = dto.Description;
                    existingProduct.SourcePrice = dto.SourcePrice;
                    existingProduct.Images = dto.Images;
                    existingProduct.Category = dto.Category;
                    existingProduct.Availability = dto.Availability;
                    existingProduct.SupplierInfo = dto.SupplierInfo;
                    existingProduct.Specifications = dto.Specifications;
                    existingProduct.ReviewsCount = dto.ReviewsCount;
                    existingProduct.Rating = dto.Rating;
                    existingProduct.ShippingInfo = dto.ShippingInfo;
                    existingProduct.InventoryLevel = dto.InventoryLevel;
                    existingProduct.UpdatedAt = DateTime.UtcNow;
                    existingProduct.MarketPrice = dto.SourcePrice * 1.20m;
                }
                else
                {
                    var product = new Product
                    {
                        SourceProductId = dto.SourceProductId,
                        SourceSite = dto.SourceSite,
                        Title = dto.Title,
                        Description = dto.Description,
                        SourcePrice = dto.SourcePrice,
                        MarketPrice = dto.SourcePrice * 1.20m,
                        Currency = dto.Currency,
                        Images = dto.Images,
                        Category = dto.Category,
                        Availability = dto.Availability,
                        SupplierInfo = dto.SupplierInfo,
                        Specifications = dto.Specifications,
                        ReviewsCount = dto.ReviewsCount,
                        Rating = dto.Rating,
                        ShippingInfo = dto.ShippingInfo,
                        InventoryLevel = dto.InventoryLevel,
                        ScrapedAt = DateTime.Parse(dto.ScrapedAt),
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow,
                        IsActive = true
                    };
                    
                    productsToAdd.Add(product);
                }
            }
            
            if (productsToAdd.Any())
            {
                _context.Products.AddRange(productsToAdd);
            }
            
            await _context.SaveChangesAsync();
            
            _logger.LogInformation($"Successfully imported {productsToAdd.Count} new products and updated {productDtos.Count - productsToAdd.Count} existing products");
            
            return Ok(new { 
                Message = "Products imported successfully", 
                NewProducts = productsToAdd.Count,
                UpdatedProducts = productDtos.Count - productsToAdd.Count
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error importing products");
            return StatusCode(500, new { Message = "Error importing products", Error = ex.Message });
        }
    }
}

public class ProductImportDto
{
    public string SourceProductId { get; set; } = string.Empty;
    public string SourceSite { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal SourcePrice { get; set; }
    public string Currency { get; set; } = "USD";
    public List<string> Images { get; set; } = new();
    public string Category { get; set; } = string.Empty;
    public bool Availability { get; set; } = true;
    public Dictionary<string, object> SupplierInfo { get; set; } = new();
    public string ScrapedAt { get; set; } = DateTime.UtcNow.ToString("O");
    public Dictionary<string, object> Specifications { get; set; } = new();
    public int ReviewsCount { get; set; }
    public decimal Rating { get; set; }
    public Dictionary<string, object> ShippingInfo { get; set; } = new();
    public string InventoryLevel { get; set; } = "In Stock";
    public List<Dictionary<string, object>> CompetitorPrices { get; set; } = new();
}
