using System.Text.Json;

namespace AdminRiderService.Services
{
    public class HotelServiceClient
    {
        private readonly HttpClient _httpClient;
        private readonly ILogger<HotelServiceClient> _logger;
        private readonly string _hotelsBaseUrl;
        private readonly string _ordersBaseUrl;

        public HotelServiceClient(HttpClient httpClient, IConfiguration configuration, ILogger<HotelServiceClient> logger)
        {
            _httpClient = httpClient;
            _logger = logger;
            _hotelsBaseUrl = configuration["Services:HotelService:HotelsUrl"] ?? "http://localhost:8080/api/hotels";
            _ordersBaseUrl = configuration["Services:HotelService:OrdersUrl"] ?? "http://localhost:8080/api/orders";
        }

        public async Task<List<HotelDTO>> GetAllHotelsAsync()
        {
            try
            {
                var response = await _httpClient.GetAsync(_hotelsBaseUrl);
                response.EnsureSuccessStatusCode();
                
                var content = await response.Content.ReadAsStringAsync();
                var hotels = JsonSerializer.Deserialize<List<HotelDTO>>(content, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });
                
                return hotels ?? new List<HotelDTO>();
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(ex, "Error fetching hotels from Hotel-Service");
                return new List<HotelDTO>();
            }
        }

        public async Task<HotelDTO?> GetHotelByIdAsync(long id)
        {
            try
            {
                var response = await _httpClient.GetAsync($"{_hotelsBaseUrl}/{id}");
                response.EnsureSuccessStatusCode();
                
                var content = await response.Content.ReadAsStringAsync();
                return JsonSerializer.Deserialize<HotelDTO>(content, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(ex, $"Error fetching hotel {id} from Hotel-Service");
                return null;
            }
        }

        public async Task<HotelDTO?> CreateHotelAsync(HotelDTO hotel)
        {
            try
            {
                var jsonOptions = new JsonSerializerOptions
                {
                    PropertyNamingPolicy = JsonNamingPolicy.CamelCase
                };
                
                var json = JsonSerializer.Serialize(hotel, jsonOptions);
                _logger.LogInformation($"Sending hotel data to Hotel-Service: {json}");
                _logger.LogInformation($"Target URL: {_hotelsBaseUrl}");
                
                var content = new StringContent(json, System.Text.Encoding.UTF8, "application/json");
                
                var response = await _httpClient.PostAsync(_hotelsBaseUrl, content);
                
                var responseContent = await response.Content.ReadAsStringAsync();
                
                if (!response.IsSuccessStatusCode)
                {
                    _logger.LogError($"Hotel-Service returned error {(int)response.StatusCode}: {responseContent}");
                    throw new HttpRequestException($"Hotel-Service error: {responseContent}");
                }
                
                _logger.LogInformation($"Received response from Hotel-Service: {responseContent}");
                
                return JsonSerializer.Deserialize<HotelDTO>(responseContent, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(ex, "Error creating hotel in Hotel-Service");
                throw;
            }
        }

        public async Task<HotelDTO?> UpdateHotelAsync(long id, HotelDTO hotel)
        {
            try
            {
                var jsonOptions = new JsonSerializerOptions
                {
                    PropertyNamingPolicy = JsonNamingPolicy.CamelCase
                };
                
                var json = JsonSerializer.Serialize(hotel, jsonOptions);
                var content = new StringContent(json, System.Text.Encoding.UTF8, "application/json");
                
                var response = await _httpClient.PutAsync($"{_hotelsBaseUrl}/{id}", content);
                response.EnsureSuccessStatusCode();
                
                var responseContent = await response.Content.ReadAsStringAsync();
                return JsonSerializer.Deserialize<HotelDTO>(responseContent, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(ex, $"Error updating hotel {id} in Hotel-Service");
                return null;
            }
        }

        public async Task<bool> DeleteHotelAsync(long id)
        {
            try
            {
                var response = await _httpClient.DeleteAsync($"{_hotelsBaseUrl}/{id}");
                return response.IsSuccessStatusCode;
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(ex, $"Error deleting hotel {id} from Hotel-Service");
                return false;
            }
        }

        public async Task<List<OrderDTO>> GetAllOrdersAsync()
        {
            try
            {
                var response = await _httpClient.GetAsync(_ordersBaseUrl);
                response.EnsureSuccessStatusCode();
                
                var content = await response.Content.ReadAsStringAsync();
                var orders = JsonSerializer.Deserialize<List<OrderDTO>>(content, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });
                
                return orders ?? new List<OrderDTO>();
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(ex, "Error fetching orders from Hotel-Service");
                return new List<OrderDTO>();
            }
        }

        public async Task<OrderDTO?> GetOrderByIdAsync(long id)
        {
            try
            {
                var response = await _httpClient.GetAsync($"{_ordersBaseUrl}/{id}");
                response.EnsureSuccessStatusCode();
                
                var content = await response.Content.ReadAsStringAsync();
                return JsonSerializer.Deserialize<OrderDTO>(content, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(ex, $"Error fetching order {id} from Hotel-Service");
                return null;
            }
        }

        public async Task<OrderDTO?> UpdateOrderStatusAsync(long id, string status)
        {
            try
            {
                var json = JsonSerializer.Serialize(new { status });
                var content = new StringContent(json, System.Text.Encoding.UTF8, "application/json");
                
                var response = await _httpClient.PatchAsync($"{_ordersBaseUrl}/{id}/status", content);
                response.EnsureSuccessStatusCode();
                
                var responseContent = await response.Content.ReadAsStringAsync();
                return JsonSerializer.Deserialize<OrderDTO>(responseContent, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(ex, $"Error updating order {id} status in Hotel-Service");
                return null;
            }
        }

        public async Task<int> GetOrderCountAsync()
        {
            try
            {
                var orders = await GetAllOrdersAsync();
                return orders.Count;
            }
            catch
            {
                return 0;
            }
        }

        public async Task<decimal> GetTotalRevenueAsync()
        {
            try
            {
                var orders = await GetAllOrdersAsync();
                return (decimal)orders.Sum(o => o.TotalAmount);
            }
            catch
            {
                return 0;
            }
        }
    }

    public class HotelDTO
    {
        public long Id { get; set; }
        public string? Name { get; set; }
        public string? Cuisine { get; set; }
        public string? Location { get; set; }
        public double? Rating { get; set; }
        public int? Price { get; set; }
        public string? ImageUrl { get; set; }
    }

    public class OrderDTO
    {
        public long Id { get; set; }
        public string? UserEmail { get; set; }
        public double TotalAmount { get; set; }
        public string? Status { get; set; }
        public string? PaymentMethod { get; set; }
        public string? DeliveryAddress { get; set; }
        public DateTime OrderDate { get; set; }
        public List<OrderItemDTO>? Items { get; set; }
    }

    public class OrderItemDTO
    {
        public long Id { get; set; }
        public long OrderId { get; set; }
        public string? ItemName { get; set; }
        public int Quantity { get; set; }
        public double Price { get; set; }
    }
}
