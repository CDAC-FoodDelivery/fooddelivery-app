using AdminRiderService.Data;
using AdminRiderService.Models;
using AdminRiderService.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AdminRiderService.Controllers
{
    [Route("api/admin")]
    [ApiController]
    [Authorize(Roles = "ADMIN")]
    public class AdminController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly MenuServiceClient _menuClient;
        private readonly HotelServiceClient _hotelClient;
        private readonly ILogger<AdminController> _logger;

        public AdminController(
            AppDbContext context,
            MenuServiceClient menuClient,
            HotelServiceClient hotelClient,
            ILogger<AdminController> logger)
        {
            _context = context;
            _menuClient = menuClient;
            _hotelClient = hotelClient;
            _logger = logger;
        }


        [HttpGet("orders")]
        public async Task<IActionResult> GetAllOrders()
        {
            try
            {
                var orders = await _hotelClient.GetAllOrdersAsync();
                return Ok(orders);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching orders from Hotel-Service");
                return StatusCode(500, new { message = "Error fetching orders", error = ex.Message });
            }
        }

        [HttpGet("orders/{id}")]
        public async Task<IActionResult> GetOrder(long id)
        {
            try
            {
                var order = await _hotelClient.GetOrderByIdAsync(id);
                
                if (order == null)
                    return NotFound(new { message = "Order not found" });

                return Ok(order);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error fetching order {id} from Hotel-Service");
                return StatusCode(500, new { message = "Error fetching order", error = ex.Message });
            }
        }

        [HttpPut("orders/{id}/status")]
        public async Task<IActionResult> UpdateOrderStatus(long id, [FromBody] UpdateStatusRequest request)
        {
            try
            {
                var updatedOrder = await _hotelClient.UpdateOrderStatusAsync(id, request.Status!);
                
                if (updatedOrder == null)
                    return NotFound(new { message = "Order not found or update failed" });

                return Ok(new { message = "Order status updated successfully", order = updatedOrder });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error updating order {id} status in Hotel-Service");
                return StatusCode(500, new { message = "Error updating order status", error = ex.Message });
            }
        }

        [HttpGet("restaurants")]
        public async Task<IActionResult> GetAllRestaurants()
        {
            try
            {
                var restaurants = await _hotelClient.GetAllHotelsAsync();
                return Ok(restaurants);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching restaurants from Hotel-Service");
                return StatusCode(500, new { message = "Error fetching restaurants", error = ex.Message });
            }
        }

        [HttpGet("restaurants/{id}")]
        public async Task<IActionResult> GetRestaurant(long id)
        {
            try
            {
                var restaurant = await _hotelClient.GetHotelByIdAsync(id);
                
                if (restaurant == null)
                    return NotFound(new { message = "Restaurant not found" });

                return Ok(restaurant);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error fetching restaurant {id} from Hotel-Service");
                return StatusCode(500, new { message = "Error fetching restaurant", error = ex.Message });
            }
        }

        [HttpPost("restaurants")]
        public async Task<IActionResult> CreateRestaurant([FromBody] HotelDTO restaurant)
        {
            try
            {
                var createdRestaurant = await _hotelClient.CreateHotelAsync(restaurant);
                
                if (createdRestaurant == null)
                    return StatusCode(500, new { message = "Failed to create restaurant" });

                return CreatedAtAction(nameof(GetRestaurant), new { id = createdRestaurant.Id }, createdRestaurant);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating restaurant in Hotel-Service");
                return StatusCode(500, new { message = "Error creating restaurant", error = ex.Message });
            }
        }

        [HttpPut("restaurants/{id}")]
        public async Task<IActionResult> UpdateRestaurant(long id, [FromBody] HotelDTO updatedRestaurant)
        {
            try
            {
                var restaurant = await _hotelClient.UpdateHotelAsync(id, updatedRestaurant);
                
                if (restaurant == null)
                    return NotFound(new { message = "Restaurant not found or update failed" });

                return Ok(new { message = "Restaurant updated successfully", restaurant });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error updating restaurant {id} in Hotel-Service");
                return StatusCode(500, new { message = "Error updating restaurant", error = ex.Message });
            }
        }

        [HttpDelete("restaurants/{id}")]
        public async Task<IActionResult> DeleteRestaurant(long id)
        {
            try
            {
                var success = await _hotelClient.DeleteHotelAsync(id);
                
                if (!success)
                    return NotFound(new { message = "Restaurant not found or delete failed" });

                return Ok(new { message = "Restaurant deleted successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error deleting restaurant {id} from Hotel-Service");
                return StatusCode(500, new { message = "Error deleting restaurant", error = ex.Message });
            }
        }

        [HttpGet("users")]
        public async Task<IActionResult> GetAllUsers()
        {
            try
            {
                var users = await _context.Users
                    .OrderBy(u => u.Name)
                    .Select(u => new
                    {
                        u.Id,
                        u.Name,
                        u.Email,
                        u.Role,
                        u.Phone,
                        u.Location
                    })
                    .ToListAsync();

                return Ok(users);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching users from database");
                return StatusCode(500, new { message = "Error fetching users", error = ex.Message });
            }
        }

        [HttpGet("users/{email}")]
        public async Task<IActionResult> GetUserByEmail(string email)
        {
            try
            {
                var user = await _context.Users
                    .Where(u => u.Email == email)
                    .Select(u => new
                    {
                        u.Id,
                        u.Name,
                        u.Email,
                        u.Role,
                        u.Phone,
                        u.Address,
                        u.Location,
                        u.Pincode
                    })
                    .FirstOrDefaultAsync();

                if (user == null)
                    return NotFound(new { message = "User not found" });

                return Ok(user);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error fetching user {email} from database");
                return StatusCode(500, new { message = "Error fetching user", error = ex.Message });
            }
        }

        [HttpGet("insights")]
        public async Task<IActionResult> GetInsights()
        {
            try
            {
                var totalUsers = await _context.Users.CountAsync();
                
                var totalOrders = await _hotelClient.GetOrderCountAsync();
                var totalRestaurants = (await _hotelClient.GetAllHotelsAsync()).Count;
                var totalRevenue = await _hotelClient.GetTotalRevenueAsync();

                return Ok(new
                {
                    totalOrders,
                    totalRestaurants,
                    totalUsers,
                    totalRevenue
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching insights from multiple services");
                return StatusCode(500, new { message = "Error fetching insights", error = ex.Message });
            }
        }

        [HttpGet("restaurants/{restaurantId}/menu")]
        public async Task<IActionResult> GetRestaurantMenu(long restaurantId)
        {
            try
            {
                var menuItems = await _menuClient.GetMenuByHotelIdAsync(restaurantId);
                return Ok(menuItems);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error fetching menu for restaurant {restaurantId} from Menu-Service");
                return StatusCode(500, new { message = "Error fetching menu", error = ex.Message });
            }
        }

        [HttpGet("menu/{id}")]
        public async Task<IActionResult> GetMenuItem(long id)
        {
            try
            {
                var menuItem = await _menuClient.GetMenuItemByIdAsync(id);
                
                if (menuItem == null)
                    return NotFound(new { message = "Menu item not found" });

                return Ok(menuItem);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error fetching menu item {id} from Menu-Service");
                return StatusCode(500, new { message = "Error fetching menu item", error = ex.Message });
            }
        }

        [HttpPost("restaurants/{restaurantId}/menu")]
        public async Task<IActionResult> CreateMenuItem(long restaurantId, [FromBody] MenuItemDTO menuItem)
        {
            try
            {
                menuItem.HotelId = restaurantId;
                var createdMenuItem = await _menuClient.CreateMenuItemAsync(menuItem);
                
                if (createdMenuItem == null)
                    return StatusCode(500, new { message = "Failed to create menu item" });

                return CreatedAtAction(nameof(GetMenuItem), new { id = createdMenuItem.Id }, createdMenuItem);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating menu item in Menu-Service");
                return StatusCode(500, new { message = "Error creating menu item", error = ex.Message });
            }
        }

        [HttpPut("menu/{id}")]
        public async Task<IActionResult> UpdateMenuItem(long id, [FromBody] MenuItemDTO updatedMenuItem)
        {
            try
            {
                var menuItem = await _menuClient.UpdateMenuItemAsync(id, updatedMenuItem);
                
                if (menuItem == null)
                    return NotFound(new { message = "Menu item not found or update failed" });

                return Ok(new { message = "Menu item updated successfully", menuItem });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error updating menu item {id} in Menu-Service");
                return StatusCode(500, new { message = "Error updating menu item", error = ex.Message });
            }
        }

        [HttpDelete("menu/{id}")]
        public async Task<IActionResult> DeleteMenuItem(long id)
        {
            try
            {
                var success = await _menuClient.DeleteMenuItemAsync(id);
                
                if (!success)
                    return NotFound(new { message = "Menu item not found or delete failed" });

                return Ok(new { message = "Menu item deleted successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error deleting menu item {id} from Menu-Service");
                return StatusCode(500, new { message = "Error deleting menu item", error = ex.Message });
            }
        }
    }

    public class UpdateStatusRequest
    {
        public string? Status { get; set; }
    }
}
