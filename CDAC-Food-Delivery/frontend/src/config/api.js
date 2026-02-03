// API Configuration
// Uses VITE_API_URL from environment files:
// - .env.production: VITE_API_URL= (empty = same origin via nginx)
// - .env.development: VITE_API_URL=http://localhost:8080

// Get API base URL from Vite environment variable
// Empty string means same-origin requests (production via nginx proxy)
export const API_BASE_URL = import.meta.env.VITE_API_URL || '';

export const API_ENDPOINTS = {
    AUTH: {
        REGISTER: `${API_BASE_URL}/api/auth/register`,
        LOGIN: `${API_BASE_URL}/api/auth/login`,
        PROFILE: `${API_BASE_URL}/api/auth/profile`,
    },

    HOTELS: {
        BASE: `${API_BASE_URL}/api/hotels`,
        BY_ID: (id) => `${API_BASE_URL}/api/hotels/${id}`,
    },

    MENU: {
        BASE: `${API_BASE_URL}/api/menu`,
        BY_HOTEL: (hotelId) => `${API_BASE_URL}/api/menu?hotelId=${hotelId}`,
        FILTER: (hotelId, foodType) => `${API_BASE_URL}/api/menu/filter?hotelId=${hotelId}&foodType=${foodType}`,
        BY_ID: (id) => `${API_BASE_URL}/api/menu/${id}`,
    },

    ORDERS: {
        BASE: `${API_BASE_URL}/api/orders`,
        BY_ID: (id) => `${API_BASE_URL}/api/orders/${id}`,
    },

    PAYMENTS: {
        CREATE: `${API_BASE_URL}/api/payments/create-order`,
        VERIFY: `${API_BASE_URL}/api/payments/verify`,
    },

    ADMIN: {
        BASE: `${API_BASE_URL}/api/admin`,
        RESTAURANTS: `${API_BASE_URL}/api/admin/restaurants`,
        ORDERS: `${API_BASE_URL}/api/admin/orders`,
        USERS: `${API_BASE_URL}/api/admin/users`,
        LOGIN: `${API_BASE_URL}/api/admin/login`,
        PROFILE: `${API_BASE_URL}/api/admin/profile`,
        REGISTER_RIDER: `${API_BASE_URL}/api/admin/register-rider`,
    },

    RIDERS: {
        REGISTER: `${API_BASE_URL}/api/riders/register`,
        LOGIN: `${API_BASE_URL}/api/riders/login`,
    },
};

export default API_ENDPOINTS;
