namespace AdminService.Models
{
    public class Order
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Status { get; set; }
        public decimal Amount { get; set; }
    }
}
