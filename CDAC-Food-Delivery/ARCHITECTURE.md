# Food Delivery Application - Architecture Documentation

Complete system architecture documentation for the Food Delivery microservices application.

---

## Table of Contents

- [System Overview](#system-overview)
- [Service Architecture](#service-architecture)
- [Technology Stack](#technology-stack)
- [Network Topology](#network-topology)
- [Database Architecture](#database-architecture)
- [Communication Patterns](#communication-patterns)
- [Security Architecture](#security-architecture)
- [Port Reference](#port-reference)

---

## System Overview

The Food Delivery Application is a microservices-based platform that enables users to browse restaurants, view menus, place orders, and track deliveries. The system is designed for scalability, maintainability, and high availability.

### High-Level Architecture

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                              INTERNET                                         │
│                                  │                                            │
│                                  ▼                                            │
│                    ┌─────────────────────────┐                               │
│                    │    Nginx Reverse Proxy   │                               │
│                    │      (SSL/TLS :443)      │                               │
│                    └───────────┬─────────────┘                               │
│                                │                                              │
│              ┌─────────────────┼─────────────────┐                           │
│              │                 │                 │                            │
│              ▼                 ▼                 ▼                            │
│    ┌─────────────────┐  ┌──────────────┐  ┌──────────────┐                   │
│    │    Frontend     │  │  API Gateway │  │   Certbot    │                   │
│    │  (React + Vite) │  │  (Spring)    │  │  (SSL Certs) │                   │
│    └─────────────────┘  └──────┬───────┘  └──────────────┘                   │
│                                │                                              │
│    ┌───────────────────────────┼───────────────────────────┐                 │
│    │                           │                           │                  │
│    │           ┌───────────────┼───────────────┐          │                  │
│    │           ▼               ▼               ▼          │                  │
│    │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ │                  │
│    │  │ Auth Service │ │ Hotel Service│ │ Menu Service │ │                  │
│    │  │   (Spring)   │ │  (Spring)    │ │   (Spring)   │ │                  │
│    │  └──────┬───────┘ └──────┬───────┘ └──────┬───────┘ │                  │
│    │         │                │                │          │                  │
│    │         │         ┌──────┴───────┐        │          │                  │
│    │         │         ▼              │        │          │                  │
│    │         │  ┌──────────────┐      │        │          │                  │
│    │         │  │ Admin/Rider  │      │        │          │                  │
│    │         │  │  (.NET Core) │      │        │          │                  │
│    │         │  └──────┬───────┘      │        │          │                  │
│    │         │         │              │        │          │                  │
│    │         └─────────┼──────────────┼────────┘          │                  │
│    │                   ▼              ▼                   │                  │
│    │           ┌─────────────────────────┐                │                  │
│    │           │      MySQL 8.0          │                │                  │
│    │           │   (4 Databases)         │                │                  │
│    │           └─────────────────────────┘                │                  │
│    │                                                       │                  │
│    │              ┌──────────────┐                        │                  │
│    │              │  Discovery   │◄──── All Services      │                  │
│    │              │   Server     │      Register Here     │                  │
│    │              │  (Eureka)    │                        │                  │
│    │              └──────────────┘                        │                  │
│    │                                                       │                  │
│    │                   DOCKER NETWORK                      │                  │
│    └───────────────────────────────────────────────────────┘                 │
│                                                                               │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Service Architecture

### 1. Nginx Reverse Proxy

**Role:** Entry point for all external traffic, SSL termination, load balancing

| Attribute | Value |
|-----------|-------|
| Image | `nginx:alpine` |
| External Ports | 80 (HTTP), 443 (HTTPS) |
| Responsibilities | SSL termination, routing, rate limiting, security headers |

**Routing Rules:**
- `/` → Frontend (React Application)
- `/api/*` → API Gateway
- `/.well-known/acme-challenge/` → Certbot (SSL verification)

---

### 2. Discovery Server (Eureka)

**Role:** Service registry and discovery for microservices

| Attribute | Value |
|-----------|-------|
| Technology | Spring Cloud Netflix Eureka |
| Internal Port | 8761 |
| Language | Java 17 |
| Dependencies | None |

**Responsibilities:**
- Maintains registry of all running service instances
- Enables dynamic service discovery
- Provides health monitoring dashboard
- Supports service load balancing

---

### 3. API Gateway

**Role:** Single entry point for all API requests, request routing, cross-cutting concerns

| Attribute | Value |
|-----------|-------|
| Technology | Spring Cloud Gateway |
| Internal Port | 8080 |
| Language | Java 17 |
| Dependencies | Discovery Server |

**Responsibilities:**
- Route requests to appropriate microservices
- Authentication/Authorization pre-filters
- Request/Response logging
- Rate limiting (application level)
- Circuit breaker patterns

**Route Configuration:**
| Route | Target Service |
|-------|----------------|
| `/api/auth/**` | Auth Service |
| `/api/hotels/**` | Hotel Service |
| `/api/orders/**` | Hotel Service |
| `/api/menu/**` | Menu Service |
| `/api/admin/**` | Admin Rider Service |
| `/api/rider/**` | Admin Rider Service |

---

### 4. Auth Service

**Role:** User authentication and authorization

| Attribute | Value |
|-----------|-------|
| Technology | Spring Boot 3.x |
| Internal Port | 9081 |
| Language | Java 17 |
| Database | `fooddelivery_auth` |
| Dependencies | MySQL, Discovery Server |

**Responsibilities:**
- User registration and login
- JWT token generation and validation
- Password encryption (BCrypt)
- Role-based access control
- Session management

**API Endpoints:**
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | User registration |
| POST | `/api/auth/login` | User login |
| GET | `/api/auth/validate` | Token validation |
| GET | `/api/auth/user/{id}` | Get user details |

---

### 5. Hotel Service

**Role:** Restaurant/Hotel and Order management

| Attribute | Value |
|-----------|-------|
| Technology | Spring Boot 3.x |
| Internal Port | 9082 |
| Language | Java 17 |
| Database | `fooddelivery_hotel` |
| Dependencies | MySQL, Discovery Server |

**Responsibilities:**
- CRUD operations for restaurants/hotels
- Order creation and management
- Order status tracking
- Restaurant search and filtering
- Image management

**API Endpoints:**
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/hotels` | List all restaurants |
| GET | `/api/hotels/{id}` | Get restaurant details |
| POST | `/api/hotels` | Create restaurant (admin) |
| PUT | `/api/hotels/{id}` | Update restaurant |
| GET | `/api/orders` | List orders |
| POST | `/api/orders` | Create order |
| PUT | `/api/orders/{id}/status` | Update order status |

---

### 6. Menu Service

**Role:** Menu item management for restaurants

| Attribute | Value |
|-----------|-------|
| Technology | Spring Boot 3.x |
| Internal Port | 9083 |
| Language | Java 17 |
| Database | `fooddelivery_menu` |
| Dependencies | MySQL, Discovery Server, Hotel Service |

**Responsibilities:**
- CRUD operations for menu items
- Menu categorization
- Price management
- Availability tracking
- Menu search

**API Endpoints:**
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/menu/hotel/{hotelId}` | Get menu for restaurant |
| GET | `/api/menu/{id}` | Get menu item details |
| POST | `/api/menu` | Create menu item |
| PUT | `/api/menu/{id}` | Update menu item |
| DELETE | `/api/menu/{id}` | Delete menu item |

---

### 7. Admin Rider Service

**Role:** Admin dashboard and delivery rider management

| Attribute | Value |
|-----------|-------|
| Technology | ASP.NET Core 8 |
| Internal Port | 9086 |
| Language | C# |
| Database | `fooddelivery_admin_rider` |
| Dependencies | MySQL, Menu Service, Hotel Service |

**Responsibilities:**
- Admin authentication and dashboard
- Rider registration and management
- Order assignment to riders
- Delivery tracking
- Analytics and reporting
- Cross-service orchestration

**API Endpoints:**
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/admin/login` | Admin login |
| GET | `/api/admin/dashboard` | Dashboard data |
| GET | `/api/rider` | List riders |
| POST | `/api/rider/register` | Rider registration |
| PUT | `/api/rider/{id}/assign` | Assign order to rider |

---

### 8. Frontend

**Role:** User interface for the application

| Attribute | Value |
|-----------|-------|
| Technology | React 18 + Vite |
| Internal Port | 80 |
| Language | JavaScript/JSX |
| Build Output | Static files served by Nginx |

**Features:**
- Responsive design
- Restaurant browsing
- Menu viewing
- Cart management
- Order placement
- Order tracking
- User authentication
- Admin dashboard

---

## Technology Stack

### Backend Technologies

| Component | Technology | Version |
|-----------|------------|---------|
| Java Services | Spring Boot | 3.x |
| Service Discovery | Spring Cloud Eureka | Latest |
| API Gateway | Spring Cloud Gateway | Latest |
| .NET Service | ASP.NET Core | 8.0 |
| Database | MySQL | 8.0 |
| Caching | Spring Cache | Built-in |

### Frontend Technologies

| Component | Technology | Version |
|-----------|------------|---------|
| Framework | React | 18.x |
| Build Tool | Vite | Latest |
| HTTP Client | Axios | Latest |
| Routing | React Router | 6.x |
| State Management | React Context | Built-in |

### DevOps Technologies

| Component | Technology |
|-----------|------------|
| Containerization | Docker |
| Orchestration | Docker Compose |
| Reverse Proxy | Nginx |
| SSL Certificates | Let's Encrypt (Certbot) |
| OS | Ubuntu 22.04 LTS |

---

## Network Topology

### Docker Network Configuration

```
fooddelivery-network (bridge)
├── nginx (80, 443) ◄── Only external access point
├── frontend (80)
├── api-gateway (8080)
├── discovery-server (8761)
├── auth-service (9081)
├── hotel-service (9082)
├── menu-service (9083)
├── admin-rider-service (9086)
├── mysql (3306)
└── certbot (for SSL renewal)
```

### Network Security

- **External Access:** Only Nginx (ports 80/443)
- **Internal Communication:** All services communicate via Docker network
- **Database:** Only accessible from within Docker network
- **Service Discovery:** Internal only

---

## Database Architecture

### Database-per-Service Pattern

Each microservice owns its database, ensuring loose coupling.

| Database | Service | Purpose |
|----------|---------|---------|
| `fooddelivery_auth` | Auth Service | Users, roles, tokens |
| `fooddelivery_hotel` | Hotel Service | Restaurants, orders |
| `fooddelivery_menu` | Menu Service | Menu items, categories |
| `fooddelivery_admin_rider` | Admin Rider Service | Admins, riders, assignments |

### Entity Relationships

```
┌─────────────────────────────────────────────────────────────────┐
│                        fooddelivery_auth                         │
│  ┌─────────┐                                                    │
│  │  Users  │                                                    │
│  │─────────│                                                    │
│  │ id (PK) │                                                    │
│  │ email   │                                                    │
│  │ password│                                                    │
│  │ role    │                                                    │
│  └─────────┘                                                    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                        fooddelivery_hotel                        │
│  ┌─────────┐      ┌─────────┐                                   │
│  │ Hotels  │      │ Orders  │                                   │
│  │─────────│      │─────────│                                   │
│  │ id (PK) │◄─────│hotel_id │                                   │
│  │ name    │      │ user_id │                                   │
│  │ location│      │ status  │                                   │
│  │ image   │      │ total   │                                   │
│  └─────────┘      └─────────┘                                   │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                        fooddelivery_menu                         │
│  ┌───────────┐                                                  │
│  │ MenuItems │                                                  │
│  │───────────│                                                  │
│  │ id (PK)   │                                                  │
│  │ hotel_id  │──────► References Hotel (cross-service)          │
│  │ name      │                                                  │
│  │ price     │                                                  │
│  │ category  │                                                  │
│  └───────────┘                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    fooddelivery_admin_rider                      │
│  ┌─────────┐      ┌─────────┐      ┌────────────┐              │
│  │ Admins  │      │ Riders  │      │Assignments │              │
│  │─────────│      │─────────│      │────────────│              │
│  │ id (PK) │      │ id (PK) │◄─────│ rider_id   │              │
│  │ email   │      │ name    │      │ order_id   │              │
│  │ password│      │ phone   │      │ status     │              │
│  └─────────┘      │ status  │      └────────────┘              │
│                   └─────────┘                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Communication Patterns

### Synchronous Communication

Services communicate via REST APIs through the API Gateway.

```
Client → Nginx → API Gateway → Target Service → Database
                     ↓
              Discovery Server (for routing)
```

### Service Discovery Flow

1. Service starts and registers with Eureka
2. API Gateway queries Eureka for service locations
3. Requests are routed to healthy service instances
4. Eureka performs health checks every 30 seconds

### Cross-Service Communication

| From | To | Purpose |
|------|-----|---------|
| Menu Service | Hotel Service | Validate hotel exists |
| Admin Rider Service | Hotel Service | Get orders |
| Admin Rider Service | Menu Service | Get menu items |
| API Gateway | All Services | Route requests |

---

## Security Architecture

### Authentication Flow

```
┌────────┐     ┌───────┐     ┌──────────┐     ┌────────────┐
│ Client │────►│ Nginx │────►│  Gateway │────►│Auth Service│
└────────┘     └───────┘     └──────────┘     └────────────┘
    │                                               │
    │                    JWT Token                  │
    │◄──────────────────────────────────────────────┘
    │
    │         Subsequent Requests (with JWT)
    │────────────────────────────────────────────────►
```

### Security Layers

1. **Network Layer**
   - Only ports 80/443 exposed externally
   - Internal services isolated in Docker network
   - Firewall rules (UFW)

2. **Transport Layer**
   - TLS 1.2/1.3 encryption
   - HSTS enabled
   - Strong cipher suites

3. **Application Layer**
   - JWT authentication
   - Role-based authorization
   - Input validation
   - Rate limiting

4. **Data Layer**
   - Encrypted passwords (BCrypt)
   - Prepared statements (SQL injection prevention)
   - Database access restricted to services

---

## Port Reference

### Internal Ports (Docker Network Only)

| Service | Port | Protocol |
|---------|------|----------|
| MySQL | 3306 | TCP |
| Discovery Server | 8761 | HTTP |
| API Gateway | 8080 | HTTP |
| Auth Service | 9081 | HTTP |
| Hotel Service | 9082 | HTTP |
| Menu Service | 9083 | HTTP |
| Admin Rider Service | 9086 | HTTP |
| Frontend | 80 | HTTP |

### External Ports (Internet Accessible)

| Service | Port | Protocol |
|---------|------|----------|
| Nginx | 80 | HTTP (redirects to HTTPS) |
| Nginx | 443 | HTTPS |

---

## Health Endpoints

| Service | Health Endpoint |
|---------|-----------------|
| Discovery Server | `http://discovery-server:8761/actuator/health` |
| API Gateway | `http://api-gateway:8080/actuator/health` |
| Auth Service | `http://auth-service:9081/actuator/health` |
| Hotel Service | `http://hotel-service:9082/actuator/health` |
| Menu Service | `http://menu-service:9083/actuator/health` |
| Admin Rider Service | `http://admin-rider-service:9086/health` |
| Frontend | `http://frontend:80/health` |
| Nginx | `http://nginx/health` |

---

## Scaling Considerations

### Horizontal Scaling

Each service can be scaled independently:

```bash
docker compose -f docker-compose.prod.yml up -d --scale hotel-service=3
```

### Bottleneck Points

1. **Database:** Consider read replicas for scaling
2. **API Gateway:** Can be load-balanced
3. **Discovery Server:** Generally doesn't need scaling

### Recommended Production Setup

| Service | Instances | Memory |
|---------|-----------|--------|
| Nginx | 1 | 128MB |
| Discovery Server | 1 | 384MB |
| API Gateway | 2 | 384MB |
| Auth Service | 2 | 384MB |
| Hotel Service | 2 | 384MB |
| Menu Service | 2 | 384MB |
| Admin Rider Service | 1 | 384MB |
| MySQL | 1 | 512MB |

---

**Last Updated:** February 2026  
**Version:** 1.0.0
