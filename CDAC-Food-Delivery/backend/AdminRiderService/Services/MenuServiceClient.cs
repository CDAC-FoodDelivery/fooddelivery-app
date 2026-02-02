using System.Text.Json;

namespace AdminRiderService.Services
{
    public class MenuServiceClient
    {
        private readonly HttpClient _httpClient;
        private readonly ILogger<MenuServiceClient> _logger;
        private readonly string _baseUrl;
        private readonly JsonSerializerOptions _jsonOptions;

        public MenuServiceClient(HttpClient httpClient, IConfiguration configuration, ILogger<MenuServiceClient> logger)
        {
            _httpClient = httpClient;
            _logger = logger;
            _baseUrl = configuration["Services:MenuService:BaseUrl"] ?? "http://localhost:8080/api/menu";
            
            // Configure JSON options for Java interoperability
            _jsonOptions = new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                PropertyNameCaseInsensitive = true
            };
        }

        public async Task<List<MenuItemDTO>> GetMenuByHotelIdAsync(long hotelId)
        {
            try
            {
                var response = await _httpClient.GetAsync($"{_baseUrl}?hotelId={hotelId}");
                response.EnsureSuccessStatusCode();
                
                var content = await response.Content.ReadAsStringAsync();
                var menuItems = JsonSerializer.Deserialize<List<MenuItemDTO>>(content, _jsonOptions);
                
                return menuItems ?? new List<MenuItemDTO>();
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(ex, $"Error fetching menu for hotel {hotelId} from Menu-Service");
                return new List<MenuItemDTO>();
            }
        }

        public async Task<MenuItemDTO?> GetMenuItemByIdAsync(long id)
        {
            try
            {
                var response = await _httpClient.GetAsync($"{_baseUrl}/{id}");
                response.EnsureSuccessStatusCode();
                
                var content = await response.Content.ReadAsStringAsync();
                return JsonSerializer.Deserialize<MenuItemDTO>(content, _jsonOptions);
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(ex, $"Error fetching menu item {id} from Menu-Service");
                return null;
            }
        }

        public async Task<MenuItemDTO?> CreateMenuItemAsync(MenuItemDTO menuItem)
        {
            try
            {
                var json = JsonSerializer.Serialize(menuItem, _jsonOptions);
                _logger.LogInformation($"Sending menu item to Menu-Service: {json}");
                
                var content = new StringContent(json, System.Text.Encoding.UTF8, "application/json");
                
                var response = await _httpClient.PostAsync(_baseUrl, content);
                
                if (!response.IsSuccessStatusCode)
                {
                    var errorContent = await response.Content.ReadAsStringAsync();
                    _logger.LogError($"Menu-Service returned error: {response.StatusCode} - {errorContent}");
                    return null;
                }
                
                var responseContent = await response.Content.ReadAsStringAsync();
                _logger.LogInformation($"Received response from Menu-Service: {responseContent}");
                
                return JsonSerializer.Deserialize<MenuItemDTO>(responseContent, _jsonOptions);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating menu item in Menu-Service");
                return null;
            }
        }

        public async Task<MenuItemDTO?> UpdateMenuItemAsync(long id, MenuItemDTO menuItem)
        {
            try
            {
                var json = JsonSerializer.Serialize(menuItem, _jsonOptions);
                var content = new StringContent(json, System.Text.Encoding.UTF8, "application/json");
                
                var response = await _httpClient.PutAsync($"{_baseUrl}/{id}", content);
                response.EnsureSuccessStatusCode();
                
                var responseContent = await response.Content.ReadAsStringAsync();
                return JsonSerializer.Deserialize<MenuItemDTO>(responseContent, _jsonOptions);
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(ex, $"Error updating menu item {id} in Menu-Service");
                return null;
            }
        }

        public async Task<bool> DeleteMenuItemAsync(long id)
        {
            try
            {
                var response = await _httpClient.DeleteAsync($"{_baseUrl}/{id}");
                return response.IsSuccessStatusCode;
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(ex, $"Error deleting menu item {id} from Menu-Service");
                return false;
            }
        }
    }

    public class MenuItemDTO
    {
        public long Id { get; set; }
        public long HotelId { get; set; }
        public string? Name { get; set; }
        public string? Description { get; set; }
        public int Price { get; set; }
        public string? ImageUrl { get; set; }
        public string? Category { get; set; }
        public string? FoodType { get; set; }
        public bool IsAvailable { get; set; }
    }
}
