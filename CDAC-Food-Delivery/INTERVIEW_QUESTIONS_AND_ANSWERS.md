# 🎯 CDAC Food Delivery App — Interview Questions & Answers

---

## Section 1: Project Overview Questions

### Q1. What is your project about?
**A:** It is a **Food Delivery Web Application** built using **Microservices Architecture**. Users can browse restaurants, view menus, add items to cart, and pay online using Razorpay. It also has an Admin panel to manage restaurants, orders, and users, and a Rider panel for delivery management.

### Q2. What technologies did you use?
**A:**
- **Frontend:** React.js 18, Vite, React Router, Axios, Bootstrap 5
- **Backend (Java):** Spring Boot, Spring Cloud Gateway, Netflix Eureka, Spring Security, JPA/Hibernate
- **Backend (.NET):** ASP.NET Core 8, Entity Framework Core, Steeltoe (Eureka client)
- **Database:** MySQL 8.0
- **Payment:** Razorpay
- **Containerization:** Docker, Docker Compose

### Q3. Why did you use Microservices instead of Monolithic architecture?
**A:** Microservices allow us to:
- **Develop independently** — different teams can work on different services
- **Scale individually** — if orders increase, we scale only the Order service
- **Use different technologies** — we used Java for some services and .NET for others
- **Deploy independently** — one service update doesn't require redeploying everything
- **Fault isolation** — if one service fails, others keep working

### Q4. How many microservices does your project have?
**A:** **6 microservices:**
1. Discovery Server (Eureka) — service registry
2. API Gateway — single entry point for frontend
3. Auth Service — user authentication
4. Hotel Service — restaurants, orders, payments
5. Menu Service — food menu items
6. Admin-Rider Service — admin dashboard and rider management

---

## Section 2: Backend Questions

### Q5. What is Eureka Server? Why did you use it?
**A:** Eureka is a **Service Discovery Server** from Netflix. Each microservice registers itself with Eureka at startup. When the API Gateway needs to forward a request, it asks Eureka for the service's address. This means we don't need to hardcode service URLs — services can change ports dynamically.

### Q6. What is an API Gateway? Why do you need it?
**A:** The API Gateway is a **single entry point** for all frontend requests. Instead of the frontend knowing all service URLs, it sends everything to the Gateway (port 8080). The Gateway routes requests to the correct service based on URL patterns. It also provides cross-cutting concerns like CORS handling and load balancing.

### Q7. How does authentication work in your project?
**A:**
1. User sends email/password to `/api/auth/login`
2. Spring Security's `AuthenticationManager` validates credentials using `DaoAuthenticationProvider`
3. Password is compared using **BCrypt** hashing
4. If valid, a **JWT token** is generated using HS256 algorithm
5. Token is returned to frontend and stored in `localStorage`
6. For protected requests, the token is sent in the `Authorization: Bearer <token>` header
7. Backend decodes the token to extract the user email

### Q8. What is JWT? How did you implement it?
**A:** JWT (JSON Web Token) is a **stateless authentication** method. The token has 3 parts:
- **Header** — algorithm (HS256) and type (JWT)
- **Payload** — user email, issued time, expiry time
- **Signature** — HMAC-SHA256 of header+payload using a secret key

I used the `io.jsonwebtoken` library. The `JwtUtils` class handles token generation, extraction of claims, and validation.

### Q9. What is BCrypt? Why not store passwords directly?
**A:** BCrypt is a **password hashing algorithm**. Storing plain passwords is dangerous — if the database is hacked, all passwords are exposed. BCrypt generates a **salted hash** that is one-way (cannot be reversed). Even two identical passwords produce different hashes because of the random salt.

### Q10. How does Razorpay payment work?
**A:**
1. Frontend sends amount to `POST /api/payments/create-order`
2. Backend creates a Razorpay order using the Razorpay SDK (amount in paise = ₹ × 100)
3. Razorpay returns an `order_id`
4. Frontend opens Razorpay checkout popup with this `order_id`
5. User pays → Razorpay returns `payment_id` and `signature`
6. Frontend sends these to `POST /api/payments/verify`
7. Backend verifies the signature using `Utils.verifyPaymentSignature()`
8. If valid, payment details saved to database with status "SUCCESS"

### Q11. How do microservices communicate with each other?
**A:** Two approaches are used:
- **OpenFeign** (Java) — Menu Service uses `@FeignClient` to call Hotel Service. Feign creates a proxy at compile time, making HTTP calls look like method calls.
- **HttpClient** (.NET) — Admin-Rider Service uses `HttpClient` to call Hotel Service and Menu Service directly via HTTP.

### Q12. What databases do you use? Why separate databases?
**A:** We use **MySQL** with 4 separate databases (one per service):
- `fooddelivery_auth` — user accounts
- `fooddelivery_hotel` — hotels, orders, payments
- `fooddelivery_menu` — menu items
- `fooddelivery_admin_rider` — admin and rider accounts

Separate databases follow the **Database per Service** pattern, ensuring services are independent and don't share database tables.

### Q13. What is the difference between the Auth Service (Java) and Admin Auth (C#)?
**A:** They handle **different user types**:
- **Auth Service (Java):** For regular customers who order food. Uses Spring Security.
- **Admin Auth (C#):** For admins and delivery riders. Uses ASP.NET with its own JWT and BCrypt implementation. They have separate databases and separate login pages.

### Q14. What ORM did you use?
**A:**
- **Java services:** JPA (Java Persistence API) with Hibernate as the implementation. Used `@Entity`, `@Repository`, `@OneToMany` annotations.
- **.NET service:** Entity Framework Core with `DbContext`. Used `UseMySql()` connector and `EnsureCreated()` for auto-migration.

### Q15. What is Spring Security? How did you configure it?
**A:** Spring Security is a framework for authentication and authorization. In our project:
- We configured `SecurityFilterChain` to allow public access to `/auth/register`, `/auth/login`, `/auth/profile`
- Used `DaoAuthenticationProvider` with `CustomUserDetailsService` to load users from database
- Disabled CSRF (not needed for REST APIs) and CORS (handled by Gateway)
- Used `BCryptPasswordEncoder` for password hashing

---

## Section 3: Frontend Questions

### Q16. What is React Context API? Why did you use it?
**A:** Context API is React's built-in **state management** solution. We used it instead of Redux because:
- The app has limited shared state (auth, cart, wishlist)
- Context is simpler and doesn't need extra libraries
- We created 3 contexts: `AuthContext`, `CartContext`, `WishlistContext`
- Any component can access this state using `useContext()` hook

### Q17. How does the Cart work without a backend?
**A:** The cart is stored entirely in **localStorage** on the browser:
- Each user has a separate cart key: `cart_<email>`
- When user adds an item, it updates React state + saves to localStorage
- Cart persists even after browser refresh
- Cart is cleared after successful order placement
- No API call is needed for cart operations — it's purely client-side

### Q18. What is a Protected Route?
**A:** A `ProtectedRoute` component wraps pages that require login. It checks if the user is authenticated (via `AuthContext`). If not, it redirects to the login page. All `/home/*` routes, admin dashboard, and rider dashboard are protected.

### Q19. What is Vite? Why not Create React App?
**A:** Vite is a **fast build tool** for modern web projects. Compared to CRA:
- **Faster dev server** — uses native ES modules, no bundling during development
- **Faster builds** — uses Rollup for production
- **Hot Module Replacement (HMR)** — instant file changes in browser
- CRA is now considered legacy and no longer maintained

### Q20. How do frontend API calls work?
**A:** All API URLs are centralized in `config/api.js`:
- In development, requests go to `http://localhost:8080` (API Gateway)
- In production (Docker), requests go to the same origin via Nginx reverse proxy
- Components import `API_ENDPOINTS` and use Axios to make HTTP calls
- The `VITE_API_URL` environment variable controls the base URL

---

## Section 4: Architecture & Design Pattern Questions

### Q21. What design patterns did you use?
**A:**
- **Microservices Pattern** — application split into independent services
- **API Gateway Pattern** — single entry point for all clients
- **Service Discovery Pattern** — Eureka for dynamic service registration
- **Database per Service** — each service owns its database
- **DTO Pattern** — `HotelListResponseDTO`, `MenuResponseDTO` to shape API responses
- **Repository Pattern** — `HotelRepository`, `MenuRepository` using Spring Data JPA
- **Provider Pattern** — React Context for state management
- **Builder Pattern** — `OrderResponse.builder()` for object construction

### Q22. What is the DTO pattern? Why did you use it?
**A:** DTO (Data Transfer Object) is a pattern where we create separate classes for API responses instead of sending the entity directly. Benefits:
- **Security** — hide sensitive fields (like password)
- **Performance** — send only required fields
- **Decoupling** — API response format can change without changing the entity
- Example: `HotelListResponseDTO` sends only id, name, cuisine, rating, imageUrl — not all hotel fields

### Q23. What happens if one microservice goes down?
**A:**
- Eureka marks it as unhealthy after missed heartbeats
- API Gateway returns proper error responses to frontend
- Other services continue working normally
- Docker Compose has `restart: on-failure` to auto-restart crashed containers
- The Admin-Rider Service wraps all inter-service calls in try-catch with logging

### Q24. How do you handle CORS?
**A:** CORS (Cross-Origin Resource Sharing) is handled at multiple levels:
- **API Gateway** has a `CorsConfig` class that allows all origins
- **Admin-Rider Service** uses `AddCors("AllowAll")` policy
- **Auth Service** disables CORS at the security filter level (Gateway handles it)
- In production, Nginx serves frontend and proxies API — no CORS issues (same origin)

---

## Section 5: Docker & Deployment Questions

### Q25. What is Docker? Why did you use it?
**A:** Docker is a **containerization** tool that packages an application with its dependencies into a portable container. Benefits:
- **Consistency** — runs the same way on any machine
- **Isolation** — each service has its own container
- **Easy deployment** — just run `docker-compose up`
- **No "works on my machine" problem**

### Q26. What is Docker Compose?
**A:** Docker Compose is a tool to define and run **multi-container** Docker applications. Our `docker-compose.yml` defines 8 containers (MySQL, 6 services, frontend) with their configurations, ports, dependencies, and networking.

### Q27. What is the startup order of services?
**A:** 
1. **MySQL** starts first (other services depend on it)
2. **Discovery Server** starts next (services need to register)
3. **Auth, Hotel, Menu, Admin-Rider services** start after MySQL is healthy and Discovery is up
4. **API Gateway** starts after Discovery Server
5. **Frontend** starts after API Gateway

### Q28. How does Nginx work in production?
**A:** In production, Nginx serves the React build files as static content and acts as a **reverse proxy** — forwarding `/api/*` requests to the API Gateway. This eliminates CORS issues since frontend and API appear to be on the same domain.

---

## Section 6: Database & JPA Questions

### Q29. What is JPA? What is Hibernate?
**A:**
- **JPA** (Java Persistence API) is a **specification** for ORM in Java
- **Hibernate** is the **implementation** of JPA
- JPA provides annotations like `@Entity`, `@Table`, `@Id`, `@OneToMany`
- Hibernate translates these to SQL queries automatically
- We used `spring-boot-starter-data-jpa` which includes both

### Q30. What JPA annotations did you use?
**A:**
- `@Entity` — marks a class as a database table
- `@Table(name="...")` — specifies table name
- `@Id` — marks the primary key field
- `@GeneratedValue(strategy = GenerationType.IDENTITY)` — auto-increment ID
- `@Column(nullable = false)` — NOT NULL constraint
- `@OneToMany(cascade = CascadeType.ALL)` — one order has many items
- `@JoinColumn(name = "order_id")` — foreign key column
- `@Enumerated(EnumType.STRING)` — store enum as string

### Q31. What is `ddl-auto: update`?
**A:** It is a Hibernate property that tells how to handle the schema:
- `update` — creates table if not exists, adds new columns, but never deletes data
- `create` — drops and recreates tables on every restart
- `validate` — only validates schema, doesn't change anything
- `none` — does nothing

We used `update` so tables are created automatically based on entities.

---

## Section 7: Coding & Logic Questions

### Q32. How do you validate data before saving?
**A:** We validate in the service layer. Example in `HotelServiceImpl.createHotel()`:
- Check name is not null or empty → throw `IllegalArgumentException`
- Check cuisine is not null → throw exception
- Check price is greater than 0
- Set default values for optional fields (rating = 0, placeholder image)
- Trim whitespace from string fields

### Q33. How does the Order entity relate to OrderItem?
**A:** It's a **One-to-Many** relationship:
- One `Order` has many `OrderItems`
- Mapped using `@OneToMany(cascade = CascadeType.ALL)` on Order
- `@JoinColumn(name = "order_id")` creates a foreign key in the `order_items` table
- `CascadeType.ALL` means creating an order also creates its items automatically

### Q34. What is Lombok? Why did you use it?
**A:** Lombok is a Java library that reduces boilerplate code using annotations:
- `@Data` — generates getters, setters, toString, equals, hashCode
- `@NoArgsConstructor` — generates no-argument constructor
- `@AllArgsConstructor` — generates constructor with all fields
- `@Builder` — generates builder pattern
- This makes the entity classes much shorter and cleaner

### Q35. How does the Admin Service call other services?
**A:** The Admin-Rider Service (C#) uses `HttpClient` to make HTTP calls:
- `HotelServiceClient` calls Hotel Service for restaurants/orders
- `MenuServiceClient` calls Menu Service for menu items
- Base URLs are configured in `appsettings.json` and passed via Docker environment variables
- All calls are async (`async/await`) for non-blocking execution

---

## Section 8: Security Questions

### Q36. How do you protect admin APIs?
**A:** In the Admin-Rider Service:
- Admin endpoints use `[Authorize(Roles = "ADMIN")]` attribute
- Only users with role "ADMIN" can access these endpoints
- The JWT token contains the user's role in claims
- ASP.NET's middleware validates the JWT and checks the role claim

### Q37. Is storing JWT in localStorage safe?
**A:** It has trade-offs:
- **Pros:** Simple to implement, persists across tabs
- **Cons:** Vulnerable to XSS attacks (JavaScript can read it)
- **Better alternative:** HttpOnly cookies (but requires backend changes)
- For this project, localStorage is acceptable as it's a learning project

### Q38. How do you prevent unauthorized access to pages?
**A:** Using `ProtectedRoute` component:
- It checks `useAuth()` for user state
- Shows a loading spinner while checking
- If user is null (not logged in), redirects to login page
- Only renders the child page if user is authenticated

---

## Section 9: Real-World & Improvement Questions

### Q39. What challenges did you face?
**A:**
- **CORS errors** — resolved by configuring CORS at Gateway and service level
- **Inter-service communication** — .NET service calling Java services required matching DTOs
- **Docker networking** — services inside Docker use container names, not localhost
- **Database initialization** — ensuring MySQL is ready before services start (healthcheck)
- **Razorpay integration** — handling mock mode for development without real keys

### Q40. What improvements would you make?
**A:**
- Add **Redis** for caching restaurant and menu data
- Use **RabbitMQ/Kafka** for async communication (e.g., order notifications)
- Add **Circuit Breaker** (Resilience4j) for handling service failures gracefully
- Implement **proper JWT filter** instead of permitAll for sensitive endpoints
- Add **rate limiting** at API Gateway
- Use **Kubernetes** instead of Docker Compose for production deployment
- Add **unit and integration tests**
- Implement **real-time order tracking** using WebSockets

### Q41. Why did you use both Java and .NET?
**A:** To demonstrate **polyglot microservices** — one of the key benefits of microservices architecture. Different services can use different technologies:
- Java (Spring Boot) for core business services
- .NET (ASP.NET Core) for admin panel
- This shows we are comfortable with multiple tech stacks

### Q42. How would you scale this application?
**A:**
- **Horizontal scaling** — run multiple instances of busy services behind a load balancer
- Eureka automatically handles multiple instances
- API Gateway uses `lb://` (load balanced) URIs
- Use **Docker Swarm or Kubernetes** for container orchestration
- Add **database read replicas** for heavy read operations
- Use **CDN** for serving frontend static files

### Q43. What is the difference between Monolithic and Microservices?
**A:**
| Aspect | Monolithic | Microservices |
|--------|-----------|---------------|
| Deployment | Single deployable unit | Each service deployed independently |
| Scaling | Scale entire application | Scale individual services |
| Technology | Single tech stack | Different tech per service |
| Database | Shared database | Database per service |
| Failure Impact | Entire app can crash | Only one service affected |
| Complexity | Simpler to build | More complex (networking, deployment) |

---

## Section 10: Quick Rapid-Fire Answers

| Question | Answer |
|----------|--------|
| What port does API Gateway run on? | 8080 |
| What port does Eureka run on? | 8761 |
| How many databases? | 4 (auth, hotel, menu, admin_rider) |
| What hashing algorithm for passwords? | BCrypt |
| What JWT algorithm? | HMAC-SHA256 (HS256) |
| What is the default admin? | admin@fooddelivery.com / admin123 |
| Cart stored where? | localStorage (client-side) |
| What payment gateway? | Razorpay |
| Frontend build tool? | Vite |
| CSS framework? | Bootstrap 5 |
| Java version? | Java 17+ |
| .NET version? | .NET 8 |
| MySQL connector for .NET? | Pomelo.EntityFrameworkCore.MySql |
| What state management? | React Context API |
| How many frontend routes? | 13 routes |
| What is the delivery fee logic? | Free if order > ₹500, else ₹29 |

---
