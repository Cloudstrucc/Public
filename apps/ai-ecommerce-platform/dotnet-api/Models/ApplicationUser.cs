using Microsoft.AspNetCore.Identity;

namespace EcommerceAI.Models;

public class ApplicationUser : IdentityUser
{
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation properties
    public virtual ICollection<Order> Orders { get; set; } = new List<Order>();
}
