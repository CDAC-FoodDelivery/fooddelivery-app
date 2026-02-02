using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using AdminRiderService.Data;
using AdminRiderService.DTOs;
using AdminRiderService.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

namespace AdminRiderService.Controllers
{
    [Route("api/admin")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _config;

        public AuthController(AppDbContext context, IConfiguration config)
        {
            _context = context;
            _config = config;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == request.Email);
            Console.WriteLine("User" + user);
            if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.Password))
            {
                return Unauthorized(new { message = "Invalid email or password" });
            }

            if (user.Role != "ADMIN" && user.Role != "RIDER")
            {
                return Unauthorized(new { message = "Unauthorized: Portal for Admins/Riders only." });
            }
            Console.WriteLine("User" + user);
            return Ok(GenerateToken(user));
        }

        [HttpPost("register-rider")]
        public async Task<IActionResult> RegisterRider([FromBody] User rider)
        {
            if (await _context.Users.AnyAsync(u => u.Email == rider.Email))
            {
                return BadRequest(new { message = "Email already exists" });
            }

            rider.Password = BCrypt.Net.BCrypt.HashPassword(rider.Password);
            rider.Role = "RIDER";
            
            _context.Users.Add(rider);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Rider registered successfully" });
        }

        [Authorize]
        [HttpGet("profile")]
        public async Task<IActionResult> GetProfile()
        {
            var email = User.FindFirstValue(ClaimTypes.Email);
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == email);
            if (user == null) return NotFound();
            return Ok(user);
        }

        private string GenerateToken(User user)
        {
            var jwtSettings = _config.GetSection("Jwt");
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSettings["Key"]!));
            
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(ClaimTypes.Email, user.Email!),
                new Claim(ClaimTypes.Role, user.Role!),
                new Claim("name", user.Name ?? "")
            };

            var token = new JwtSecurityToken(
                issuer: jwtSettings["Issuer"],
                audience: jwtSettings["Audience"],
                claims: claims,
                expires: DateTime.Now.AddDays(1),
                signingCredentials: new SigningCredentials(key, SecurityAlgorithms.HmacSha256)
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}
