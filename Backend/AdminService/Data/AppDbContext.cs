using AdminService.Models;
using Microsoft.EntityFrameworkCore;

namespace AdminService.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<Order> Orders { get; set; }
        public DbSet<Restaurant> Restaurants { get; set; }
        public DbSet<AppUser> AppUsers { get; set; }


    }
}
