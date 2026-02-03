# 🎯 C-DAC Food Delivery Project — Interview Questions & Answers

**SunBeam Institute of Information Technology, Pune-Karad**

---

## Q1. Can you explain your C-DAC project? Draw block diagrams as appropriate.

**Answer:**
Our project is a **Full-Stack Food Delivery Web Application** built using **Microservices Architecture**. It enables customers to browse restaurants, view menus, add items to a cart, make online payments via Razorpay, and track orders. It also includes an Admin panel for managing restaurants/orders/users and a Rider panel for delivery management.

### Block Diagram — System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT (Browser)                          │
└──────────────────────────┬──────────────────────────────────────┘
                           │ HTTPS
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                  NGINX REVERSE PROXY (SSL/TLS)                   │
│           Routes: /* → Frontend | /api/* → API Gateway           │
└──────────────────────────┬──────────────────────────────────────┘
               ┌───────────┴───────────┐
               ▼                       ▼
┌──────────────────────┐  ┌──────────────────────────────────────┐
│  FRONTEND (React 18) │  │   API GATEWAY (Spring Cloud Gateway) │
│  Vite Build Tool      │  │   Port: 8080                        │
│  Port: 80 (prod)      │  └──────────────┬─────────────────────┘
└──────────────────────┘     ┌────────────┼────────────┐
                             ▼            ▼            ▼
                    ┌────────────┐ ┌────────────┐ ┌──────────────┐
                    │Auth Service│ │Hotel Service│ │Admin-Rider   │
                    │(Java/Spring│ │(Java/Spring)│ │(.NET Core 8) │
                    │Port: 9081) │ │Port: 9082)  │ │Port: 9086)   │
                    └─────┬──────┘ └──────┬──────┘ └──────┬───────┘
                          │        ┌──────┴──────┐        │
                          │        │Menu Service │        │
                          │        │(Java/Spring)│        │
                          │        │Port: 9083)  │        │
                          │        └──────┬──────┘        │
                          ▼               ▼               ▼
                    ┌─────────────────────────────────────────────┐
                    │          MySQL 8.0 (4 Databases)            │
                    │ fooddelivery_auth | fooddelivery_hotel       │
                    │ fooddelivery_menu | fooddelivery_admin_rider │
                    └─────────────────────────────────────────────┘

         ┌──────────────────────┐
         │  EUREKA DISCOVERY    │ ◄── All services register here
         │  SERVER (Port: 8761) │
         └──────────────────────┘
```

**Key Features:** User/Admin/Rider authentication (JWT), restaurant browsing, menu management, cart (localStorage), Razorpay payments, order tracking, admin dashboard with insights.

---

## Q2. Explain how OOPs concepts are implemented in your project?

**Answer:**

| OOP Concept | Implementation in Project |
|---|---|
| **Encapsulation** | Entity classes (`User`, `Hotel`, `Order`) use `private` fields with public getters/setters via Lombok `@Data`. Business logic is encapsulated inside service classes (e.g., `AuthService`, `HotelServiceImpl`). |
| **Abstraction** | Service interfaces like `HotelService` (interface) and `HotelServiceImpl` (implementation) hide complex logic from controllers. `JpaRepository` abstracts all database operations. |
| **Inheritance** | `HotelRepository extends JpaRepository<Hotel, Long>` inherits all CRUD operations. In .NET, `AdminController : ControllerBase` inherits HTTP handling. |
| **Polymorphism** | Method overloading in DTOs and service methods. Spring's `DaoAuthenticationProvider` polymorphically provides authentication via `UserDetailsService`. OpenFeign's `@FeignClient` creates proxy implementations at runtime. |

**Code Example — Encapsulation + Inheritance:**
```java
@Entity
@Data  // Lombok: auto-generates getters, setters, toString
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    @Column(unique = true)
    private String email;
    private String password;
    private String role;
}

// Inheritance — inherits all CRUD methods from JpaRepository
@Repository
public interface HotelRepository extends JpaRepository<Hotel, Long> {
    List<Hotel> findTop3ByOrderByRatingDesc();
}
```

**Code Example — Abstraction (Service Interface):**
```java
public interface HotelService {
    List<Hotel> getAllHotels();
    Hotel getHotelById(Long id);
    Hotel createHotel(Hotel hotel);
}

@Service
public class HotelServiceImpl implements HotelService {
    @Override
    public List<Hotel> getAllHotels() { return hotelRepository.findAll(); }
}
```

---

## Q3. Draw Use-Case, Class, and ER Diagrams of your project.

### Use-Case Diagram

```
                    ┌──────────────────────────────┐
                    │     Food Delivery System      │
                    │                                │
  ┌──────┐          │  ○ Browse Restaurants          │
  │      │──────────│  ○ View Menu                   │
  │ User │──────────│  ○ Add to Cart                 │
  │      │──────────│  ○ Place Order                 │
  │      │──────────│  ○ Make Payment (Razorpay)     │
  │      │──────────│  ○ Register / Login            │
  └──────┘          │  ○ Track Orders                │
                    │                                │
  ┌──────┐          │  ○ Login (Admin)               │
  │      │──────────│  ○ Manage Restaurants (CRUD)   │
  │Admin │──────────│  ○ Manage Menu Items (CRUD)    │
  │      │──────────│  ○ View All Orders             │
  │      │──────────│  ○ View Users                  │
  │      │──────────│  ○ View Insights/Reports       │
  └──────┘          │                                │
                    │                                │
  ┌──────┐          │  ○ Register / Login (Rider)    │
  │Rider │──────────│  ○ View Assigned Orders        │
  │      │──────────│  ○ Update Delivery Status      │
  └──────┘          └──────────────────────────────┘
```

### Class Diagram (Simplified)

```
┌─────────────────────┐    ┌─────────────────────┐
│       User          │    │       Hotel          │
├─────────────────────┤    ├─────────────────────┤
│ -id: Long           │    │ -id: Long            │
│ -name: String       │    │ -name: String        │
│ -email: String      │    │ -cuisine: String     │
│ -password: String   │    │ -location: String    │
│ -phone: String      │    │ -rating: Double      │
│ -role: String       │    │ -price: Integer      │
│ -address: String    │    │ -imageUrl: String    │
└─────────────────────┘    └──────────┬──────────┘
                                      │ 1
                                      │
                                      │ *
                            ┌─────────┴──────────┐
┌─────────────────────┐     │       Menu          │
│    Order             │     ├────────────────────┤
├─────────────────────┤     │ -id: Long           │
│ -id: Long            │     │ -hotelId: Long      │
│ -userEmail: String   │     │ -name: String       │
│ -totalAmount: Double │     │ -price: Double      │
│ -status: String      │     │ -category: String   │
│ -paymentMethod: String│    │ -foodType: FoodType  │
│ -orderDate: DateTime │     │ -isAvailable: Bool   │
│ -items: List<OrderItem>│   └────────────────────┘
└──────────┬──────────┘
           │ 1
           │ *
┌──────────┴──────────┐
│    OrderItem         │
├─────────────────────┤
│ -id: Long            │
│ -name: String        │
│ -price: Double       │
│ -quantity: Integer   │
└─────────────────────┘
```

### ER Diagram

```
┌──── fooddelivery_auth ────┐   ┌──── fooddelivery_hotel ──────────────┐
│  USERS                    │   │  HOTELS              CUSTOMER_ORDERS │
│  ├── id (PK)              │   │  ├── id (PK)    ──►  ├── id (PK)    │
│  ├── name                 │   │  ├── name            ├── hotel_id(FK)│
│  ├── email (UNIQUE)       │   │  ├── cuisine         ├── user_email  │
│  ├── password             │   │  ├── location        ├── total_amount│
│  ├── phone                │   │  ├── rating          ├── status      │
│  ├── address              │   │  ├── price           ├── order_date  │
│  ├── role                 │   │  └── image_url       │               │
│  └── pincode              │   │                      │  ORDER_ITEMS  │
└───────────────────────────┘   │                      ├── id (PK)     │
                                │                      ├── order_id(FK)│
┌──── fooddelivery_menu ────┐   │                      ├── name        │
│  MENU                     │   │                      ├── price       │
│  ├── id (PK)              │   │                      └── quantity    │
│  ├── hotel_id (FK→Hotels) │   │                                      │
│  ├── name                 │   │  PAYMENT_DETAILS                     │
│  ├── description          │   │  ├── id (PK)                        │
│  ├── price                │   │  ├── order_id, payment_id, signature │
│  ├── image_url            │   │  ├── status, amount, user_email     │
│  ├── category             │   └──────────────────────────────────────┘
│  ├── food_type (ENUM)     │
│  └── is_available         │   ┌──── fooddelivery_admin_rider ────────┐
└───────────────────────────┘   │  USERS                               │
                                │  ├── id, name, email, password, role │
                                └──────────────────────────────────────┘
```

---

## Q4. Explain the N-tier architecture of your project.

**Answer:**
Our project follows a **4-Tier Architecture**:

| Tier | Responsibility | Technology |
|---|---|---|
| **Presentation Tier** | UI rendering, user interaction | React 18, Vite, Bootstrap 5, Axios |
| **API Gateway Tier** | Routing, load balancing, CORS | Spring Cloud Gateway |
| **Business Logic Tier** | Core services, validation, auth | Spring Boot (Java), ASP.NET Core (C#) |
| **Data Access Tier** | ORM, database queries | JPA/Hibernate (Java), EF Core (.NET), MySQL |

```
┌─────────────────────────────────────────┐
│  PRESENTATION TIER (React + Vite)       │  ← Components, Pages, Context API
├─────────────────────────────────────────┤
│  API GATEWAY TIER (Spring Cloud Gateway)│  ← Routing, CORS, Load Balancing
├─────────────────────────────────────────┤
│  BUSINESS LOGIC TIER                    │  ← AuthService, HotelServiceImpl,
│  (Spring Boot + ASP.NET Core)           │     MenuServiceImpl, AdminController
├─────────────────────────────────────────┤
│  DATA ACCESS TIER                       │  ← JpaRepository, DbContext,
│  (JPA/Hibernate + EF Core)             │     SQL via ORM
├─────────────────────────────────────────┤
│  DATABASE (MySQL 8.0 — 4 databases)     │
└─────────────────────────────────────────┘
```

---

## Q5. Which advanced features have you used in your project?

**Answer:**

1. **Microservices Architecture** — 6 independently deployable services
2. **Service Discovery** — Netflix Eureka for dynamic service registration
3. **API Gateway Pattern** — Spring Cloud Gateway as single entry point
4. **JWT Authentication** — Stateless auth with HS256 signing
5. **Polyglot Microservices** — Java (Spring Boot) + C# (ASP.NET Core) in same system
6. **Payment Gateway Integration** — Razorpay SDK with signature verification
7. **Inter-service Communication** — OpenFeign (Java) and HttpClient (.NET)
8. **Docker Containerization** — All 8 containers orchestrated via Docker Compose
9. **Nginx Reverse Proxy** — SSL termination, static file serving, request routing
10. **React Context API** — Global state management for auth, cart, wishlist
11. **Database-per-Service Pattern** — 4 separate MySQL databases for loose coupling
12. **BCrypt Password Hashing** — Salted one-way hashes for password security
13. **Steeltoe (.NET Eureka Client)** — .NET service registered with Java Eureka server
14. **Data Seeding** — Automatic seed data on startup via `DataLoader` classes

---

## Q6. What was your role in your project and explain what you did in it?

**Answer:**
I was a **Full-Stack Developer** responsible for:

- **Backend Development:** Designed and implemented microservices (Auth Service, Hotel Service, Menu Service) using Spring Boot with JPA/Hibernate for data persistence
- **Frontend Development:** Built the React.js UI with React Router, Context API for state management, and Axios for API integration
- **Security Implementation:** Implemented JWT-based authentication and BCrypt password hashing in both Java and .NET services
- **Inter-service Communication:** Configured OpenFeign clients for Java-to-Java service calls and HttpClient for .NET-to-Java service calls
- **Payment Integration:** Integrated Razorpay payment gateway with order creation, checkout, and signature verification
- **DevOps:** Dockerized all services, wrote Docker Compose configuration, and set up Nginx reverse proxy for production deployment
- **Database Design:** Designed the database schema following Database-per-Service pattern with MySQL

---

## Q7. Which software development methodology have you used? Explain its process.

**Answer:**
We used **Agile methodology** with iterative development sprints.

**Process:**
1. **Sprint Planning** — Defined features for each 1-2 week sprint (e.g., Sprint 1: Auth + Hotel Service, Sprint 2: Menu + Orders, Sprint 3: Admin Panel, Sprint 4: Payments + Docker)
2. **Development** — Each team member worked on assigned microservices independently
3. **Daily Standups** — Quick sync on progress and blockers
4. **Sprint Review** — Demonstrated completed features, integrated services
5. **Sprint Retrospective** — Identified improvements for next sprint
6. **Continuous Integration** — Regular testing and integration of all services

Microservices architecture naturally aligns with Agile because services can be developed, tested, and deployed independently by different team members.

---

## Q8. Which Design Patterns are used in your project?

**Answer:**

| Design Pattern | Where Used | Example |
|---|---|---|
| **Repository Pattern** | Data access layer | `HotelRepository extends JpaRepository<Hotel, Long>` |
| **DTO Pattern** | API responses | `HotelListResponseDTO`, `MenuResponseDTO` |
| **Builder Pattern** | Object construction | `OrderResponse.builder().orderId(id).build()` |
| **Singleton Pattern** | Spring Beans | `@Service`, `@Component` are singletons by default |
| **Proxy Pattern** | Inter-service calls | OpenFeign creates proxy of `HotelServiceClient` at runtime |
| **Provider Pattern** | Frontend state | React Context — `AuthProvider`, `CartProvider` |
| **API Gateway Pattern** | Request routing | Spring Cloud Gateway routes all `/api/*` requests |
| **Service Registry Pattern** | Service discovery | Eureka Server maintains registry of all running services |
| **Database per Service** | Data isolation | Each microservice owns its own MySQL database |
| **MVC Pattern** | Architecture | Controller → Service → Repository in all services |

---

## Q9. What difficulties did you face and how did you overcome them?

**Answer:**

| Difficulty | Solution |
|---|---|
| **CORS Errors** | Configured CORS at API Gateway level (`CorsConfig` class allows all origins). In production, Nginx serves both frontend and API on same origin eliminating CORS. |
| **Docker Networking** | Services use container names (e.g., `mysql:3306`) instead of `localhost`. Configured environment variables in `docker-compose.yml` for service URLs. |
| **Database Startup Order** | Added health checks to Docker Compose — services wait for MySQL to be healthy before starting. Used `depends_on` with `condition: service_healthy`. |
| **Inter-service DTO Mismatch** | .NET service uses `JsonProperty` annotations to match Java's response format. Created matching DTO classes in C#. |
| **Razorpay Integration** | Built a mock mode for development. If Razorpay keys are dummy values, the service simulates payment instead of calling the API. |
| **JWT Between Java and .NET** | Both services use the same secret key and HS256 algorithm. The .NET service independently generates/validates JWTs for admin users with matching configuration. |

---

## Q10. Which database is used? Why? Explain database design.

**Answer:**
We use **MySQL 8.0** because:
- Open-source and widely supported
- ACID-compliant for transactional integrity (important for orders/payments)
- Strong support in both Spring Boot (JPA/Hibernate) and .NET (EF Core via Pomelo connector)
- Relational model fits our structured data well

**Database Design — Database-per-Service Pattern:**

| Database | Tables | Service |
|---|---|---|
| `fooddelivery_auth` | `users` (id, name, email, password, phone, address, pincode, location, role) | Auth Service |
| `fooddelivery_hotel` | `hotels`, `customer_orders`, `order_items`, `payment_details` | Hotel Service |
| `fooddelivery_menu` | `menu` (id, hotel_id, name, description, price, image_url, category, food_type, is_available) | Menu Service |
| `fooddelivery_admin_rider` | `users` (id, name, email, password, role, phone, address, pincode, location) | Admin-Rider Service |

**Key Relationships:**
- `customer_orders` → `order_items`: **One-to-Many** (one order has many items)
- `hotels` → `menu`: **One-to-Many** (cross-service via `hotel_id`)
- `customer_orders` → `payment_details`: **One-to-One** (one payment per order)

Schema is auto-generated using `spring.jpa.hibernate.ddl-auto=update` (Java) and `EnsureCreated()` (.NET).

---

## Q11. Explain the data access layer with code.

**Answer:**
We use two ORM technologies:

### Java — Spring Data JPA (Repository Pattern)
```java
// Repository interface — inherits all CRUD operations
@Repository
public interface HotelRepository extends JpaRepository<Hotel, Long> {
    List<Hotel> findTop3ByOrderByRatingDesc();  // Custom query method
}

// Service layer uses the repository
@Service
public class HotelServiceImpl implements HotelService {
    @Autowired
    private HotelRepository hotelRepository;

    public List<Hotel> getAllHotels() {
        return hotelRepository.findAll();  // Inherited from JpaRepository
    }
    public Hotel createHotel(Hotel hotel) {
        return hotelRepository.save(hotel);  // save() handles INSERT/UPDATE
    }
}
```

### .NET — Entity Framework Core (DbContext)
```csharp
// DbContext — maps entities to database tables
public class AppDbContext : DbContext {
    public DbSet<User> Users { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder) {
        modelBuilder.Entity<User>().HasIndex(u => u.Email).IsUnique();
    }
}

// Usage in Controller
var users = await _context.Users
    .OrderBy(u => u.Name)
    .Select(u => new { u.Id, u.Name, u.Email, u.Role })
    .ToListAsync();
```

---

## Q12. Have you used AJAX in your project? How?

**Answer:**
Yes. All frontend-to-backend communication is **asynchronous** using **Axios** (AJAX library for React).

```javascript
// Example: Fetching restaurants (AJAX call via Axios)
import axios from 'axios';
import { API_ENDPOINTS } from '../config/api';

const fetchHotels = async () => {
    const response = await axios.get(API_ENDPOINTS.HOTELS.BASE);
    setHotels(response.data);  // Update React state with response
};

// Example: Login (POST AJAX call)
const handleLogin = async (email, password) => {
    const response = await axios.post(API_ENDPOINTS.AUTH.LOGIN, { email, password });
    localStorage.setItem("token", response.data.token);  // Store JWT
};
```

All API calls are non-blocking — the UI remains responsive while data loads. Axios sends requests with appropriate headers including `Authorization: Bearer <JWT>` for authenticated endpoints.

---

## Q13. Which frontend technology is used in your project?

**Answer:**

| Technology | Purpose |
|---|---|
| **React 18** | Component-based UI library |
| **Vite** | Fast development build tool (replaces Create React App) |
| **React Router v6** | Client-side routing (13 routes) |
| **Context API** | State management (AuthContext, CartContext, WishlistContext) |
| **Axios** | HTTP client for API calls |
| **Bootstrap 5** | CSS framework for responsive design |
| **React Toastify** | Toast notification popups |
| **Razorpay JS SDK** | Payment checkout modal |

**Folder Structure:**
```
frontend/src/
├── config/api.js          → Centralized API endpoint URLs
├── context/               → AuthContext, CartContext, WishlistContext
├── components/            → Navbar, HotelCard, ProductCard, ProtectedRoute
├── pages/                 → SignIn, HotelPage, ProductsPage, Payment, AdminDashboard
└── layout/MainLayout.jsx  → Layout wrapper with Navbar + Sidebars
```

---

## Q14. Explain configuration files used in your project.

**Answer:**

| File | Service | Purpose |
|---|---|---|
| `application.properties` | All Java services | Server port, DB connection, Eureka URL, JWT secret, routes |
| `appsettings.json` | Admin-Rider (.NET) | DB connection, JWT settings, service URLs |
| `docker-compose.yml` | Root | Container definitions, ports, environment variables, health checks |
| `nginx.conf` | Nginx | Reverse proxy rules, SSL config, security headers |
| `.env` | Root | Environment variables (DB passwords, Razorpay keys, domain) |
| `pom.xml` | Java services | Maven dependencies (Spring Boot, JPA, JWT, Eureka) |
| `vite.config.js` | Frontend | Vite build configuration, proxy settings |
| `Dockerfile` | Each service | Docker image build instructions |

**Example — API Gateway `application.properties`:**
```properties
spring.application.name=api-gateway
server.port=8080
eureka.client.service-url.defaultZone=http://localhost:8761/eureka/

# Route: /api/auth/** → Auth Service (load balanced via Eureka)
spring.cloud.gateway.routes[0].id=auth-service
spring.cloud.gateway.routes[0].uri=lb://auth-service
spring.cloud.gateway.routes[0].predicates[0]=Path=/api/auth/**
```

---

## Q15. Explain security implementation of your project.

**Answer:**
Security is implemented at **4 layers**:

**1. Network Layer** — Only ports 80/443 exposed externally via Nginx. All services isolated in Docker network.

**2. Authentication (JWT)** — Stateless token-based auth:
```java
// JWT token generation (AuthService)
private String createToken(Map<String, Object> claims, String subject) {
    return Jwts.builder()
        .setSubject(subject)  // user email
        .setIssuedAt(new Date())
        .setExpiration(new Date(System.currentTimeMillis() + jwtExpiration))
        .signWith(getSignKey(), SignatureAlgorithm.HS256)
        .compact();
}
```

**3. Password Hashing (BCrypt):**
```java
credential.setPassword(passwordEncoder.encode(credential.getPassword()));
```

**4. Authorization (Role-Based Access Control):**
```csharp
// .NET — Only ADMIN role can access this controller
[Authorize(Roles = "ADMIN")]
public class AdminController : ControllerBase { }
```

**5. Spring Security Filter Chain:**
```java
http.csrf(AbstractHttpConfigurer::disable)
    .authorizeHttpRequests(auth -> auth
        .requestMatchers("/auth/register", "/auth/login").permitAll()
        .anyRequest().permitAll());
```

**6. Frontend Protection** — `ProtectedRoute` component redirects unauthenticated users to the login page.

---

## Q16. How to build a CI/CD pipeline for the project?

**Answer:**
A CI/CD pipeline for this project can be built using **GitHub Actions** or **Jenkins**:

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│  Code    │───▶│  Build   │───▶│  Test    │───▶│ Docker   │───▶│ Deploy   │
│  Push    │    │  (Maven/ │    │  (Unit/  │    │  Build   │    │  (Docker │
│  (Git)   │    │   npm)   │    │  Integ.) │    │  & Push  │    │ Compose) │
└──────────┘    └──────────┘    └──────────┘    └──────────┘    └──────────┘
```

**Steps:**
1. **Source** — Developer pushes code to GitHub
2. **Build** — Maven builds Java services (`mvn clean package`), npm builds frontend (`npm run build`)
3. **Test** — Run unit tests and integration tests
4. **Dockerize** — Build Docker images for each service (`docker compose build`)
5. **Push** — Push images to Docker Hub/Container Registry
6. **Deploy** — SSH into production server, pull latest images, run `docker compose up -d`
7. **Verify** — Run health checks on all services (`/actuator/health`)

The project already has deployment scripts (`deploy.sh`, `setup.sh`, `verify.sh`) that automate steps 4-7.

---

## Q17. Are you aware of Separation of Concerns (SoC)?

**Answer:**
Yes. SoC is a design principle where each module handles **one specific responsibility**. Our project implements SoC at every level:

| Level | Separation |
|---|---|
| **Architecture** | Each microservice handles one business domain (Auth, Hotels, Menu, Admin) |
| **Backend Layers** | Controller (HTTP) → Service (business logic) → Repository (data access) |
| **Frontend** | Components (UI) → Context (state) → Config (API URLs) → Pages (routing) |
| **Database** | Each service has its own database — no shared tables |
| **Config** | Environment-specific settings separated into `.env` files, `application.properties` |

**Example — Backend Layered Separation:**
```
Controller (HotelController)  → Handles HTTP requests/responses
    ↓
Service (HotelServiceImpl)    → Contains business validation logic
    ↓
Repository (HotelRepository)  → Handles database queries via JPA
    ↓
Entity (Hotel)                → Maps to database table
```

---

## Q18. How did you implement session management?

**Answer:**
We use **stateless session management** via **JWT (JSON Web Tokens)** instead of server-side sessions.

**Flow:**
1. User logs in → server generates JWT containing email + expiry → returns to client
2. Client stores JWT in `localStorage`
3. Every subsequent request sends JWT in `Authorization: Bearer <token>` header
4. Server decodes JWT to identify the user — **no session stored on server**

```javascript
// Frontend — storing and using JWT
const login = async (tokenData) => {
    localStorage.setItem("token", token);  // Store JWT
    await fetchUser();  // Fetch profile using the token
};

// Sending JWT with every request
const response = await axios.get(url, {
    headers: { Authorization: `Bearer ${token}` }
});
```

**Why Stateless?** In microservices, each service is independent. Server-side sessions don't work well because a request might go to any service instance. JWT is self-contained and can be verified by any service.

---

## Q19. What is the difference between Authentication and Authorization?

**Answer:**

| Aspect | Authentication | Authorization |
|---|---|---|
| **Definition** | Verifying **who** the user is | Determining **what** they can access |
| **Question** | "Are you who you claim to be?" | "Do you have permission to do this?" |
| **When** | During login | After login, on every request |
| **How (our project)** | Email/password verification + JWT token generation | Role-based checks: USER, ADMIN, RIDER |
| **Example** | `POST /api/auth/login` verifies credentials and returns JWT | `[Authorize(Roles = "ADMIN")]` allows only admins to access admin APIs |
| **Technology** | Spring Security `AuthenticationManager`, BCrypt | `@PreAuthorize`, `[Authorize]` attributes, role claims in JWT |

---

## Q20. Explain the authentication flow. Did you use JWT?

**Answer:**
Yes, we use **JWT (JSON Web Token)** with **HS256** algorithm.

### Authentication Flow:
```
┌────────┐                    ┌──────────┐                    ┌────────────┐
│ Client │── POST /login ────▶│ Gateway  │── forwards ───────▶│Auth Service│
│        │   {email, pass}    │ (8080)   │                    │  (9081)    │
│        │                    └──────────┘                    │            │
│        │                                                    │ 1. Load user│
│        │                                                    │    by email │
│        │                                                    │ 2. BCrypt   │
│        │                                                    │    verify   │
│        │◀────────── JWT Token ─────────────────────────────│ 3. Generate │
│        │                                                    │    JWT      │
│        │                                                    └────────────┘
│        │── GET /api/hotels ──▶ (sends JWT in header)
│        │   Authorization:
│        │   Bearer eyJhbG...
└────────┘
```

**JWT Structure:**
- **Header:** `{"alg": "HS256", "typ": "JWT"}`
- **Payload:** `{"sub": "user@email.com", "iat": 1706..., "exp": 1706...}`
- **Signature:** `HMACSHA256(base64(header) + "." + base64(payload), secretKey)`

**JWT Generation Code:**
```java
public String generateToken(String username) {
    return Jwts.builder()
        .setSubject(username)       // email as subject
        .setIssuedAt(new Date())
        .setExpiration(new Date(System.currentTimeMillis() + jwtExpiration))
        .signWith(getSignKey(), SignatureAlgorithm.HS256)
        .compact();
}
```

---

## Q21. How is Authorization implemented? Which roles are present?

**Answer:**

### Roles in the Project:
| Role | Access | Login Endpoint |
|---|---|---|
| **USER** | Browse restaurants, order food, make payments | `/api/auth/login` |
| **ADMIN** | Manage restaurants, menus, view all orders/users/insights | `/api/admin/login` |
| **RIDER** | View assigned orders, update delivery status | `/api/riders/login` |

### Authorization Implementation:

**Backend (.NET — Role-Based):**
```csharp
// Entire controller restricted to ADMIN role
[Route("api/admin")]
[Authorize(Roles = "ADMIN")]
public class AdminController : ControllerBase
{
    [HttpGet("orders")]
    public async Task<IActionResult> GetAllOrders() { ... }

    [HttpGet("restaurants")]
    public async Task<IActionResult> GetAllRestaurants() { ... }
}
```

**Frontend — Protected Routes:**
```jsx
// ProtectedRoute component blocks unauthenticated users
<Route path="/home" element={<ProtectedRoute><MainLayout /></ProtectedRoute>}>
<Route path="/adminDashboard" element={<ProtectedRoute><AdminDashboardPage /></ProtectedRoute>} />
```

**Role-to-Resource Mapping:**
| Resource | USER | ADMIN | RIDER |
|---|:---:|:---:|:---:|
| Browse restaurants/menu | ✅ | ✅ | ❌ |
| Place orders | ✅ | ❌ | ❌ |
| CRUD restaurants | ❌ | ✅ | ❌ |
| CRUD menu items | ❌ | ✅ | ❌ |
| View all orders | ❌ | ✅ | ❌ |
| View assigned deliveries | ❌ | ❌ | ✅ |

---

## Q22. How to host an application online? Did you try to host your project?

**Answer:**
Yes, the project is designed for production deployment on a **cloud VPS (Virtual Private Server)**.

**Hosting Steps:**
1. Provision a VPS (e.g., AWS EC2, DigitalOcean Droplet) with Ubuntu 22.04
2. Point your domain's DNS A record to the server's IP address
3. Run `deploy/setup.sh` — installs Docker, configures firewall (UFW allows 22, 80, 443)
4. Run `deploy/configure.sh` — creates `.env` file from `.env.example`, configures secrets
5. Run `deploy/build.sh` — builds Docker images for all services
6. Run `deploy/deploy.sh` — starts all containers via Docker Compose
7. Run `deploy/setup-ssl.sh` — obtains SSL certificate from Let's Encrypt via Certbot
8. Run `deploy/verify.sh` — checks health of all services

**Production Stack:** Nginx (reverse proxy + SSL) → API Gateway → Microservices → MySQL, all running in Docker containers on a single server.

---

## Q23. What is DNS? Explain how a request to "www.google.co.in" reaches Google servers.

**Answer:**
**DNS (Domain Name System)** translates human-readable domain names into IP addresses that computers use.

**Request Flow:**
```
1. User types www.google.co.in in browser

2. Browser checks LOCAL CACHE → "Do I know this IP?" → If yes, use it

3. If not, asks OS DNS RESOLVER (configured DNS server, e.g., 8.8.8.8)

4. Resolver asks ROOT DNS SERVER → "Who handles .in domains?"
   → Returns: .in TLD server address

5. Resolver asks .IN TLD SERVER → "Who handles google.co.in?"
   → Returns: Google's authoritative nameserver address

6. Resolver asks GOOGLE'S NAMESERVER → "What's the IP of www.google.co.in?"
   → Returns: 142.250.195.36 (example)

7. Resolver caches the IP and returns it to browser

8. Browser opens TCP connection to 142.250.195.36:443 (HTTPS)

9. TLS handshake → HTTP request sent → Google server responds with page
```

In our project, the domain's DNS A record points to our server's IP. Nginx receives the request and routes it to `frontend` (for pages) or `api-gateway` (for API calls).

---

## Q24. What is Scaling? Explain strategies for scaling the project.

**Answer:**
**Scaling** means increasing the capacity of an application to handle more load (users/requests).

### Two Types:
| Type | Description | Example |
|---|---|---|
| **Vertical Scaling** | Add more CPU/RAM to existing server | Upgrade VPS from 4GB to 16GB RAM |
| **Horizontal Scaling** | Add more instances of a service | Run 3 instances of Hotel Service behind a load balancer |

### Strategies for Our Project:

1. **Service-Level Horizontal Scaling** (Docker Compose):
```bash
docker compose up -d --scale hotel-service=3 --scale menu-service=2
```
Eureka automatically discovers all instances. API Gateway uses `lb://` (load-balanced) URIs.

2. **Database Scaling** — Add MySQL read replicas for heavy read operations. Write operations go to primary, reads distributed across replicas.

3. **Caching** — Add **Redis** to cache frequently accessed data (restaurant lists, menus) to reduce database load.

4. **CDN** — Serve React frontend static files via a CDN (CloudFront, Cloudflare) for faster global delivery.

5. **Message Queues** — Use **RabbitMQ/Kafka** for async operations (order notifications, email alerts) to decouple services.

6. **Container Orchestration** — Migrate from Docker Compose to **Kubernetes** for auto-scaling, self-healing, and rolling deployments in production.

---

## Q25. What are Microservices? Have you implemented them?

**Answer:**
**Microservices** is an architectural style where an application is composed of **small, independent, loosely-coupled services** that communicate over the network (typically HTTP/REST).

### Yes, we implemented microservices. Our system has 6 services:

| Service | Technology | Port | Responsibility |
|---|---|---|---|
| Discovery Server | Spring Cloud Eureka | 8761 | Service registry |
| API Gateway | Spring Cloud Gateway | 8080 | Request routing, CORS |
| Auth Service | Spring Boot (Java) | 9081 | User registration, login, JWT |
| Hotel Service | Spring Boot (Java) | 9082 | Restaurants, orders, payments |
| Menu Service | Spring Boot (Java) | 9083 | Menu items, food categories |
| Admin-Rider Service | ASP.NET Core (C#) | 9086 | Admin dashboard, rider management |

### Monolithic vs Microservices:
| Aspect | Monolithic | Our Microservices |
|---|---|---|
| Deployment | Single WAR/JAR | 6 Docker containers |
| Scaling | Scale entire app | Scale individual services |
| Tech Stack | Single technology | Java + C# (polyglot) |
| Database | Shared database | 4 separate databases |
| Failure | Entire app crashes | Only affected service fails |
| Team | All work on same codebase | Each service developed independently |

### Inter-Service Communication:
```java
// Java — OpenFeign (declarative REST client)
@FeignClient(name = "hotel-service")
public interface HotelServiceClient {
    @GetMapping("/api/hotels/{id}")
    Object getHotelById(@PathVariable("id") Long id);
}
```

```csharp
// .NET — HttpClient (programmatic REST calls)
public async Task<List<HotelDTO>> GetAllHotelsAsync() {
    var response = await _httpClient.GetAsync($"{_baseUrl}/api/hotels");
    return await response.Content.ReadFromJsonAsync<List<HotelDTO>>();
}
```

---

*Document prepared for C-DAC Project Interview Preparation*
*SunBeam Institute of Information Technology, Pune-Karad*
