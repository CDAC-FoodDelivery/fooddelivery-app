using System.ComponentModel.DataAnnotations.Schema;

namespace AdminService.Models
{
    [Table("hotels")]
    public class Restaurant
    {
        public int Id { get; set; }
        public string Name { get; set; }
        
        [Column("location")]
        public string City { get; set; } 
        
        // This column might not exist in hotels, admin needs to add it or ignore it
        // We will assume user will add it via SQL
        public string Status { get; set; } = "Open";

        public string Cuisine { get; set; } = "Multicuisine";
        
        [Column("image_url")]
        public string ImageUrl { get; set; } = "https://placehold.co/600x400";
        
        public int Price { get; set; } = 500;
        
        public double Rating { get; set; } = 4.0;
    }
}
