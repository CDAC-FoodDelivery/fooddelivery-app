# 🍔 CDAC Food Delivery App — Complete Project Flow & Working

---

## 1. Project Overview

This is a **full-stack Food Delivery Application** built using **Microservices Architecture**.

| Layer | Technology |
|-------|-----------|
| **Frontend** | React.js + Vite |
| **Backend (Java)** | Spring Boot (4 services) |
| **Backend (.NET)** | ASP.NET Core 8 (1 service) |
| **Database** | MySQL 8.0 |
| **Payment Gateway** | Razorpay |
| **Service Discovery** | Netflix Eureka |
| **API Gateway** | Spring Cloud Gateway |
| **Containerization** | Docker + Docker Compose |

---

## 2. Architecture Diagram

```
┌─────────────────────────────────────────────────────┐
│                   FRONTEND (React + Vite)            │
│               Runs on Port 5173 (dev) / 3000 (prod)  │
└──────────────────────┬──────────────────────────────┘
                       │ All API calls go to /api/*
                       ▼
┌──────────────────────────────────────────────────────┐
│              API GATEWAY (Spring Cloud Gateway)       │
│                     Port: 8080                        │
│         Routes requests to correct microservice       │
└──────────────────────┬──────────────────────────────┘
                       │
          ┌────────────┼────────────────────┐
          │            │                    │
          ▼            ▼                    ▼
┌─────────────┐ ┌─────────────┐  ┌──────────────────┐
│ Auth Service│ │Hotel Service│  │ Admin-Rider Svc  │
│ (Java)      │ │(Java)       │  │ (.NET C#)        │
│ Port: 9081  │ │Port: 9082   │  │ Port: 9086       │
└──────┬──────┘ └──────┬──────┘  └────────┬─────────┘
       │               │                  │
       │        ┌──────┴──────┐           │
       │        │Menu Service │           │
       │        │(Java)       │           │
       │        │Port: 9083   │           │
       │        └──────┬──────┘           │
       │               │                  │
       ▼               ▼                  ▼
┌──────────────────────────────────────────────────────┐
│                    MySQL Database                     │
│   Databases: fooddelivery_auth, fooddelivery_hotel,   │
│   fooddelivery_menu, fooddelivery_admin_rider          │
└──────────────────────────────────────────────────────┘
```

**Service Discovery:** All services register with **Eureka Server** (Port 8761). The API Gateway uses Eureka to find service locations.

---

## 3. Microservices — What Each Service Does

### 3.1 Discovery Server (Eureka)
- **Tech:** Spring Boot + Netflix Eureka
- **Port:** 8761
- **Purpose:** Acts as a **phone book** for all services. Every microservice registers itself here. The API Gateway looks up this registry to route requests.

### 3.2 API Gateway
- **Tech:** Spring Cloud Gateway
- **Port:** 8080
- **Purpose:** **Single entry point** for the frontend. Routes requests to the correct service.

| URL Pattern | Routed To |
|-------------|-----------|
| `/api/auth/**` | Auth Service (lb://auth-service) |
| `/api/hotels/**` | Hotel Service (lb://hotel-service) |
| `/api/menu/**` | Menu Service (lb://menu-service) |
| `/api/orders/**` | Hotel Service (lb://hotel-service) |
| `/api/payments/**` | Hotel Service (lb://hotel-service) |
| `/api/admin/**` | Admin-Rider Service (http://localhost:9086) |
| `/api/riders/**` | Admin-Rider Service (http://localhost:9086) |

> `lb://` = Load Balanced via Eureka. The Gateway finds the actual IP/port from Eureka.

### 3.3 Auth Service (Java — Spring Boot)
- **Port:** 9081
- **Database:** `fooddelivery_auth`
- **Purpose:** Handles **user registration, login, and profile**.

**How it works:**
1. User registers → password hashed with **BCrypt** → saved to `users` table → JWT token returned
2. User logs in → credentials verified via **AuthenticationManager** → JWT token generated using **HS256** algorithm
3. Token is sent to frontend → stored in **localStorage**
4. Profile fetched by decoding JWT to get email → query database

**Key Classes:**
- `AuthController` → REST endpoints (`/auth/register`, `/auth/login`, `/auth/profile`)
- `AuthService` → Business logic (save user, generate/validate token)
- `JwtUtils` → JWT creation and validation using `io.jsonwebtoken` library
- `AuthConfig` → Spring Security configuration (BCrypt, permitAll on auth endpoints)
- `User` entity → Fields: id, name, email, password, phone, address, pincode, location, role

### 3.4 Hotel Service / fooddelivery_backend (Java — Spring Boot)
- **Port:** 9082
- **Database:** `fooddelivery_hotel`
- **Purpose:** Manages **restaurants (hotels), orders, and payments**.

**Contains 3 sub-modules in one Spring Boot app:**

#### A) Hotel Module
- `HotelController` → CRUD operations for restaurants (`/api/hotels`)
- `Hotel` entity → Fields: id, name, cuisine, location, rating, price, imageUrl
- `DataLoader` → Seeds 12 restaurants in Pune on startup

#### B) Order Module
- `OrderController` → Create order, get orders by user email (`/api/orders`)
- `Order` entity → Fields: id, userEmail, totalAmount, status, paymentMethod, deliveryAddress, orderDate
- `OrderItem` entity → Fields: id, name, price, quantity (linked via `@OneToMany`)
- Order status is set to "SUCCESS" on creation

#### C) Payment Module (Razorpay)
- `PaymentController` → Create Razorpay order, verify payment (`/api/payments`)
- `PaymentService` → Integrates with **Razorpay SDK**
  - Creates order with amount in paise (amount × 100)
  - Verifies payment signature using `Utils.verifyPaymentSignature()`
  - Has **mock mode** — if Razorpay keys are dummy, it simulates payment
- `PaymentDetails` entity → Stores orderId, paymentId, signature, status, amount, userEmail

### 3.5 Menu Service (Java — Spring Boot)
- **Port:** 9083
- **Database:** `fooddelivery_menu`
- **Purpose:** Manages **food menu items** for each restaurant.

**How it works:**
- Each menu item is linked to a hotel via `hotelId` (foreign key)
- Supports filtering by `foodType` (VEG / NON_VEG)
- `DataLoader` seeds menu items for all 12 restaurants on startup

**Key Classes:**
- `MenuController` → CRUD + filter by hotel and food type (`/api/menu`)
- `Menu` entity → Fields: id, hotelId, name, description, price, imageUrl, category, foodType, isAvailable
- `FoodType` enum → VEG, NON_VEG
- Uses **OpenFeign** (`HotelServiceClient`) to call Hotel Service internally

### 3.6 Admin-Rider Service (.NET 8 — ASP.NET Core)
- **Port:** 9086
- **Database:** `fooddelivery_admin_rider`
- **Purpose:** Handles **Admin dashboard and Rider management**.

**Key Features:**
- **Admin login** with BCrypt password verification + JWT (separate from user auth)
- Seeds default admin: `admin@fooddelivery.com` / `admin123`
- Admin can: view/create/update/delete restaurants and menu items, view orders, view users, see insights
- Rider can: register, login, view assigned orders
- Uses **Steeltoe** for Eureka service discovery (the .NET equivalent of Spring Cloud)
- Calls **Hotel Service** and **Menu Service** via HTTP clients for data

**Key Classes:**
- `AdminController` → Admin dashboard endpoints (authorized with `[Authorize(Roles = "ADMIN")]`)
- `AuthController` → Admin/Rider login and registration
- `HotelServiceClient` / `MenuServiceClient` → HTTP clients to call Java services
- `User` model → Fields: Id, Name, Email, Password, Role, Phone, Address, Pincode, Location

---

## 4. Frontend — Structure & Flow

### 4.1 Tech Stack
- **React 18** with **Vite** (fast build tool)
- **React Router v6** for navigation
- **Axios** for HTTP requests
- **Bootstrap 5** + CSS for styling
- **React Toastify** for notifications
- **Razorpay JS SDK** for payment UI

### 4.2 Folder Structure
```
frontend/src/
├── config/api.js          → All API endpoint URLs (centralized)
├── context/
│   ├── AuthContext.jsx     → User auth state (login, logout, token)
│   ├── CartContext.jsx     → Cart state (add, remove, update, clear)
│   └── WishlistContext.jsx → Wishlist state (toggle, check)
├── components/
│   ├── Navbar.jsx          → Top navigation bar
│   ├── LeftSidebar.jsx     → Left menu (Home, Trending, Wishlist, Cart)
│   ├── RightSidebar.jsx    → Right panel (user profile)
│   ├── HotelCard.jsx       → Restaurant card component
│   ├── ProductCard.jsx     → Menu item card component
│   ├── ProtectedRoute.jsx  → Blocks unauthenticated users
│   ├── CartItem.jsx        → Single cart item row
│   └── admin/              → Admin dashboard sub-components
├── pages/
│   ├── SignIn.jsx           → User login page
│   ├── SignUp.jsx           → User registration page
│   ├── AdminRiderLogin.jsx  → Admin/Rider login page
│   ├── RiderSignUp.jsx      → Rider registration page
│   ├── HotelPage.jsx        → Home page (list restaurants)
│   ├── ProductsPage.jsx     → Restaurant menu page
│   ├── CartPage.jsx         → Cart page
│   ├── Payment.jsx          → Payment page (Card/UPI/COD)
│   ├── SearchPage.jsx       → Search restaurants
│   ├── TrendingPage.jsx     → Top-rated restaurants
│   ├── WishlistPage.jsx     → Saved items
│   ├── AdminDashboardPage.jsx → Admin panel
│   └── RiderDashboard.jsx   → Rider panel
└── layout/
    └── MainLayout.jsx       → Layout wrapper (Navbar + Sidebars + Content)
```

### 4.3 Context API (State Management)

**AuthContext** — Manages user authentication
- Stores JWT token in `localStorage`
- On app load, fetches user profile using saved token
- Provides: `user`, `login()`, `logout()`, `loading`

**CartContext** — Manages shopping cart
- Stores cart in `localStorage` per user (`cart_<email>`)
- Provides: `cartItems`, `addToCart()`, `removeFromCart()`, `updateQuantity()`, `clearCart()`, `totalPrice`

**WishlistContext** — Manages wishlist
- Stores wishlist in `localStorage` per user
- Provides: `wishlist`, `toggleWishlist()`, `isInWishlist()`, `removeFromWishlist()`

### 4.4 Routing (App.jsx)

| Route | Page | Auth Required? |
|-------|------|:-:|
| `/` | SignIn | No |
| `/signup` | SignUp | No |
| `/admin-rider-login` | AdminRiderLogin | No |
| `/rider-signup` | RiderSignUp | No |
| `/home` | MainLayout (HotelPage) | Yes |
| `/home/hotel/:hotelId/menu` | ProductsPage | Yes |
| `/home/cart` | CartPage | Yes |
| `/home/payment` | Payment | Yes |
| `/home/wishlist` | WishlistPage | Yes |
| `/home/trending` | TrendingPage | Yes |
| `/home/search` | SearchPage | Yes |
| `/adminDashboard` | AdminDashboard | Yes |
| `/riderDashboard` | RiderDashboard | Yes |

---

## 5. Complete User Flow (Step-by-Step)

### Flow 1: Customer Orders Food 🛒

```
1. User opens app → SignIn page loads
2. User enters email/password → POST /api/auth/login
3. Backend verifies credentials → Returns JWT token
4. Token saved in localStorage → Profile fetched via GET /api/auth/profile
5. Redirected to /home → HotelPage loads
6. GET /api/hotels → Fetches all restaurants from Hotel Service
7. User clicks a restaurant → Navigates to /home/hotel/:id/menu
8. GET /api/menu?hotelId=:id → Fetches menu items from Menu Service
9. User clicks "Add to Cart" → CartContext updates + saved to localStorage
10. User goes to Cart → CartPage shows all items with quantities
11. User clicks "Proceed to Pay" → Payment page loads
12. User selects method (Card/UPI/COD):
    - Card/UPI: POST /api/payments/create-order → Razorpay order created
                → Razorpay checkout opens → User pays
                → POST /api/payments/verify → Signature verified
    - COD: Directly proceeds
13. POST /api/orders → Order saved with items, address, status="SUCCESS"
14. Cart cleared → User redirected to home → Toast: "Order placed! 🍛"
```

### Flow 2: Admin Manages App 👨‍💼

```
1. Admin opens /admin-rider-login
2. Enters admin@fooddelivery.com / admin123
3. POST /api/admin/login → BCrypt verify → JWT returned
4. Redirected to /adminDashboard
5. Dashboard tabs:
   - Orders: GET /api/admin/orders → Shows all customer orders
   - Restaurants: GET /api/admin/restaurants → CRUD restaurants
   - Users: GET /api/admin/users → View registered users
   - Insights: GET /api/admin/insights → Total orders, revenue, users count
   - Menu: GET /api/admin/restaurants/:id/menu → CRUD menu items
```

### Flow 3: Rider Delivery 🛵

```
1. Rider registers at /rider-signup → POST /api/admin/register-rider
2. Rider logs in at /admin-rider-login → POST /api/admin/login
3. Redirected to /riderDashboard
4. Sees assigned orders and delivery status
```

---

## 6. Database Schema

### Auth Service DB (`fooddelivery_auth`)
| Table | Columns |
|-------|---------|
| `users` | id, name, email, password, phone, address, pincode, location, role |

### Hotel Service DB (`fooddelivery_hotel`)
| Table | Columns |
|-------|---------|
| `hotels` | id, name, cuisine, location, rating, price, image_url |
| `customer_orders` | id, user_email, total_amount, status, payment_method, delivery_address, order_date |
| `order_items` | id, order_id, name, price, quantity |
| `payment_details` | id, order_id, payment_id, signature, status, amount, user_email |

### Menu Service DB (`fooddelivery_menu`)
| Table | Columns |
|-------|---------|
| `menu` | id, hotel_id, name, description, price, image_url, category, food_type, is_available |

### Admin-Rider Service DB (`fooddelivery_admin_rider`)
| Table | Columns |
|-------|---------|
| `users` | id, name, email, password, role, phone, address, pincode, location |

---

## 7. Key Technologies & Where They Are Used

| Technology | Where Used | Purpose |
|-----------|------------|---------|
| **Spring Boot** | Auth, Hotel, Menu, Gateway, Discovery | Java backend framework |
| **ASP.NET Core 8** | AdminRiderService | .NET backend framework |
| **Spring Cloud Gateway** | api-gateway | Single entry point, routing |
| **Netflix Eureka** | discovery-server | Service registration & discovery |
| **Steeltoe** | AdminRiderService | .NET Eureka client |
| **Spring Security** | Auth Service | Authentication & authorization |
| **JWT (JSON Web Token)** | Auth Service, Admin Service | Stateless authentication |
| **BCrypt** | Auth Service, Admin Service | Password hashing |
| **JPA/Hibernate** | All Java services | ORM for database access |
| **Entity Framework Core** | AdminRiderService | .NET ORM for database |
| **OpenFeign** | Menu Service | Inter-service HTTP calls (Java) |
| **HttpClient** | AdminRiderService | Inter-service HTTP calls (.NET) |
| **Razorpay SDK** | Payment module | Payment processing |
| **React.js 18** | Frontend | UI library |
| **Vite** | Frontend | Fast build tool |
| **React Router v6** | Frontend | Client-side routing |
| **Context API** | Frontend | State management |
| **Axios** | Frontend | HTTP client |
| **Bootstrap 5** | Frontend | CSS framework |
| **Docker** | All services | Containerization |
| **Docker Compose** | Root | Multi-container orchestration |
| **Nginx** | Frontend (prod) | Static file serving & reverse proxy |
| **MySQL 8.0** | All services | Relational database |
| **Lombok** | Java services | Boilerplate code reduction |

---

## 8. Docker & Deployment

All services are containerized using Docker. The `docker-compose.yml` defines:

| Container | Build Context | Port |
|-----------|--------------|------|
| `mysql` | mysql:8.0 image | 3307:3306 |
| `discovery-server` | backend/discovery-server | 8761 |
| `api-gateway` | backend/api-gateway | 8080 |
| `auth-service` | backend/AuthService | 9081 |
| `hotel-service` | backend/fooddelivery_backend | 9082 |
| `menu-service` | backend/Menu-backend | 9083 |
| `admin-rider-service` | backend/AdminRiderService | 9086 |
| `frontend` | frontend | 3000:80 |

**Startup Order:** MySQL → Discovery Server → All Services → API Gateway → Frontend

---

## 9. How Services Communicate

```
Frontend ──HTTP──▶ API Gateway (8080)
                      │
                      ├── /api/auth/** ──▶ Auth Service (Eureka lb)
                      ├── /api/hotels/** ──▶ Hotel Service (Eureka lb)
                      ├── /api/menu/** ──▶ Menu Service (Eureka lb)
                      ├── /api/orders/** ──▶ Hotel Service (Eureka lb)
                      ├── /api/payments/** ──▶ Hotel Service (Eureka lb)
                      └── /api/admin/** ──▶ Admin Service (direct URL)

Admin Service (.NET) ──HTTP──▶ Hotel Service (for hotels, orders)
Admin Service (.NET) ──HTTP──▶ Menu Service (for menu items)
Menu Service (Java) ──OpenFeign──▶ Hotel Service (for hotel validation)
```

---
