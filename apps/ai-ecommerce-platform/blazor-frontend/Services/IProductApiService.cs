using System.Text.Json;

namespace EcommerceBlazor.Services;

public interface IProductApiService
{
    Task<List<ProductDto>> GetProductsAsync();
    Task<ProductDto?> GetProductAsync(int id);
}

public class ProductApiService : IProductApiService
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<ProductApiService> _logger;

    public ProductApiService(HttpClient httpClient, ILogger<ProductApiService> logger)
    {
        _httpClient = httpClient;
        _logger = logger;
    }

    public async Task<List<ProductDto>> GetProductsAsync()
    {
        try
        {
            var response = await _httpClient.GetAsync("/api/products");
            if (response.IsSuccessStatusCode)
            {
                var json = await response.Content.ReadAsStringAsync();
                return JsonSerializer.Deserialize<List<ProductDto>>(json, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                }) ?? new List<ProductDto>();
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error fetching products");
        }
        
        return new List<ProductDto>();
    }

    public async Task<ProductDto?> GetProductAsync(int id)
    {
        try
        {
            var response = await _httpClient.GetAsync($"/api/products/{id}");
            if (response.IsSuccessStatusCode)
            {
                var json = await response.Content.ReadAsStringAsync();
                return JsonSerializer.Deserialize<ProductDto>(json, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error fetching product {ProductId}", id);
        }
        
        return null;
    }
}

public class ProductDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal SourcePrice { get; set; }
    public decimal MarketPrice { get; set; }
    public string Currency { get; set; } = "CAD";
    public List<string> Images { get; set; } = new();
    public string Category { get; set; } = string.Empty;
    public bool Availability { get; set; }
    public decimal Rating { get; set; }
    public int ReviewsCount { get; set; }
    public string InventoryLevel { get; set; } = string.Empty;
}
