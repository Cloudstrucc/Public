namespace EcommerceBlazor.Services;

public interface ICartService
{
    Task AddToCartAsync(int productId, int quantity = 1);
    Task RemoveFromCartAsync(int productId);
    Task<List<CartItemDto>> GetCartItemsAsync();
    Task ClearCartAsync();
    Task<decimal> GetCartTotalAsync();
}

public class CartService : ICartService
{
    private readonly List<CartItemDto> _cartItems = new();

    public Task AddToCartAsync(int productId, int quantity = 1)
    {
        var existingItem = _cartItems.FirstOrDefault(x => x.ProductId == productId);
        if (existingItem != null)
        {
            existingItem.Quantity += quantity;
        }
        else
        {
            _cartItems.Add(new CartItemDto
            {
                ProductId = productId,
                Quantity = quantity
            });
        }
        return Task.CompletedTask;
    }

    public Task RemoveFromCartAsync(int productId)
    {
        _cartItems.RemoveAll(x => x.ProductId == productId);
        return Task.CompletedTask;
    }

    public Task<List<CartItemDto>> GetCartItemsAsync()
    {
        return Task.FromResult(_cartItems.ToList());
    }

    public Task ClearCartAsync()
    {
        _cartItems.Clear();
        return Task.CompletedTask;
    }

    public Task<decimal> GetCartTotalAsync()
    {
        return Task.FromResult(_cartItems.Sum(x => x.Quantity * 10.00m));
    }
}

public class CartItemDto
{
    public int ProductId { get; set; }
    public int Quantity { get; set; }
    public string ProductTitle { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public string ImageUrl { get; set; } = string.Empty;
}
