import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000/api';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor
apiClient.interceptors.request.use(
  (config) => {
    // Add auth token if available
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Handle unauthorized
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Shipment API calls
export const shipmentApi = {
  getAll: () => apiClient.get('/shipments'),
  getById: (id) => apiClient.get(`/shipments/${id}`),
  getActive: () => apiClient.get('/shipments/status/active'),
  create: (data) => apiClient.post('/shipments', data),
  update: (id, data) => apiClient.put(`/shipments/${id}`, data),
  delete: (id) => apiClient.delete(`/shipments/${id}`),
};

// Cargo API calls
export const cargoApi = {
  getAll: () => apiClient.get('/cargo'),
  getById: (id) => apiClient.get(`/cargo/${id}`),
  create: (data) => apiClient.post('/cargo', data),
  update: (id, data) => apiClient.put(`/cargo/${id}`, data),
  delete: (id) => apiClient.delete(`/cargo/${id}`),
};

// Agent API calls
export const agentApi = {
  getAll: () => apiClient.get('/agents'),
  getById: (id) => apiClient.get(`/agents/${id}`),
  create: (data) => apiClient.post('/agents', data),
  update: (id, data) => apiClient.put(`/agents/${id}`, data),
  delete: (id) => apiClient.delete(`/agents/${id}`),
};

// Customs API calls
export const customsApi = {
  getAll: () => apiClient.get('/customs'),
  getById: (id) => apiClient.get(`/customs/${id}`),
  create: (data) => apiClient.post('/customs', data),
  update: (id, data) => apiClient.put(`/customs/${id}`, data),
  delete: (id) => apiClient.delete(`/customs/${id}`),
};

export default apiClient;
