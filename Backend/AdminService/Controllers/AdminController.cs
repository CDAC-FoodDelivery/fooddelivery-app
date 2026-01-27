using AdminService.Data;
using AdminService.Models;
using AdminService.Services;
using AdminService.Dtos;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AdminService.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AdminController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AdminController(AppDbContext context)
        {
            _context = context;
        }


        [HttpGet("orders")]
        public async Task<ActionResult<IEnumerable<Order>>> GetOrders()
        {
            return await _context.Orders.ToListAsync();
        }


        [HttpGet("restaurants")]
        public async Task<ActionResult<IEnumerable<Restaurant>>> GetRestaurants()
        {
            return await _context.Restaurants.ToListAsync();
        }

        [HttpGet("restaurants/{id}")]
        public async Task<ActionResult<Restaurant>> GetRestaurant(int id)
        {
             var restaurant = await _context.Restaurants.FindAsync(id);
             if (restaurant == null) return NotFound();
             return restaurant;
        }

        [HttpPost("restaurants")]
        public async Task<ActionResult> AddRestaurant([FromBody] AddRestaurantDto dto, [FromServices] IEmailService emailService)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var password = dto.Password;
                if (string.IsNullOrEmpty(password))
                {
                    password = Guid.NewGuid().ToString().Substring(0, 8);
                }

                var existingUser = await _context.AppUsers.FirstOrDefaultAsync(u => u.Email == dto.Email);
                if (existingUser != null)
                {
                    return BadRequest("User with this email already exists.");
                }

                var user = new AppUser
                {
                    Name = dto.Name,
                    Email = dto.Email,
                    Role = "HOTEL",
                    Address = dto.City,
                    Phone = dto.Phone,
                    Password = BCrypt.Net.BCrypt.HashPassword(password)
                };

                _context.AppUsers.Add(user);
                await _context.SaveChangesAsync();

                var restaurant = new Restaurant
                {
                    Name = dto.Name,
                    City = dto.City,
                    Status = "Open",
                    Cuisine = string.IsNullOrEmpty(dto.Cuisine) ? "Multi-Cuisine" : dto.Cuisine,
                    Rating = 0,
                    Price = 200,
                    ImageUrl = "https://placehold.co/600x400" // Ensure this is set
                };

                _context.Restaurants.Add(restaurant);
                await _context.SaveChangesAsync();

                await transaction.CommitAsync();

                try
                {
                    var subject = "Welcome to FoodDelivery - Restaurant Partner";
                    var body = $"<h3>Hello {dto.Name},</h3><p>Your restaurant has been registered successfully.</p>" +
                               $"<p><b>Username:</b> {dto.Email}</p>" +
                               $"<p><b>Password:</b> {password}</p>" +
                               $"<p>Please login and change your password.</p>";

                    await emailService.SendEmailAsync(dto.Email, subject, body);
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Failed to send email: {ex.Message}");
                    // Do not fail the request if only email fails, but log it.
                }

                return CreatedAtAction(nameof(GetRestaurant), new { id = restaurant.Id }, restaurant);
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                // Return the detailed error message to help debug
                return StatusCode(500, $"Internal Server Error: {ex.Message} {ex.InnerException?.Message}");
            }
        }

        [HttpPut("restaurants/{id}")]
        public async Task<IActionResult> UpdateRestaurant(int id, Restaurant restaurant)
        {
            if (id != restaurant.Id) return BadRequest("ID mismatch");

            var existing = await _context.Restaurants.FindAsync(id);
            if (existing == null) return NotFound();

            existing.Name = restaurant.Name;
            existing.City = restaurant.City;
            existing.Status = restaurant.Status;
            
            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpDelete("restaurants/{id}")]
        public async Task<IActionResult> DeleteRestaurant(int id)
        {
            var restaurant = await _context.Restaurants.FindAsync(id);
            if (restaurant == null) return NotFound();
            _context.Restaurants.Remove(restaurant);
            await _context.SaveChangesAsync();
            return NoContent();
        }


        [HttpGet("users")]
        public async Task<ActionResult<IEnumerable<AppUser>>> GetUsers()
        {
            return await _context.AppUsers.ToListAsync();
        }


        [HttpGet("insights")]
        public async Task<ActionResult<object>> GetInsights()
        {
            try
            {
                var ordersCount = await _context.Orders.CountAsync();
                var restaurantsCount = await _context.Restaurants.CountAsync();
                var usersCount = await _context.AppUsers.CountAsync();
                var revenue = await _context.Orders.SumAsync(o => (decimal?)o.Amount) ?? 0;

                return new
                {
                    Orders = ordersCount,
                    Restaurants = restaurantsCount,
                    Users = usersCount,
                    Revenue = revenue
                };
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching insights: {ex.Message}");
                return StatusCode(500, $"Internal Server Error: {ex.Message}");
            }
        }
    }
}
