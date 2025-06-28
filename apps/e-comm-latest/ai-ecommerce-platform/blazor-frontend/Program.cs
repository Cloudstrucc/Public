using EcommerceBlazor.Services;
using MudBlazor.Services;
using Microsoft.AspNetCore.Authentication.Cookies;
using Blazored.LocalStorage;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor();

// Add MudBlazor services
builder.Services.AddMudServices();

// Add Blazored LocalStorage
builder.Services.AddBlazoredLocalStorage();

// Add Authentication
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.LoginPath = "/login";
        options.LogoutPath = "/logout";
        options.ExpireTimeSpan = TimeSpan.FromDays(30);
    });

builder.Services.AddAuthorization();

// Register HTTP clients and services
builder.Services.AddHttpClient<IProductApiService, ProductApiService>(client =>
{
    client.BaseAddress = new Uri(builder.Configuration["ApiSettings:BaseUrl"] ?? "http://dotnet-api:80");
});

// Register services
builder.Services.AddScoped<ICartService, CartService>();
builder.Services.AddScoped<IProductApiService, ProductApiService>();

// Health checks
builder.Services.AddHealthChecks();

var app = builder.Build();

// Configure the HTTP request pipeline
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();

app.UseAuthentication();
app.UseAuthorization();

// Health check
app.MapHealthChecks("/health");

app.MapRazorPages();
app.MapBlazorHub();
app.MapFallbackToPage("/_Host");

app.Run();

// Placeholder service interfaces and implementations
namespace EcommerceBlazor.Services
{
    public interface IProductApiService { }
    public class ProductApiService : IProductApiService 
    {
        public ProductApiService(HttpClient httpClient) { }
    }
    
    public interface ICartService { }
    public class CartService : ICartService { }
}
