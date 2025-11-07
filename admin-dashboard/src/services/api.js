import axios from 'axios';

// Production backend URL
const API_BASE_URL = 'https://teerkhela-production.up.railway.app/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add token to requests
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('adminToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Handle errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('adminToken');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Auth
export const login = async (username, password) => {
  const response = await api.post('/admin/login', { username, password });
  if (response.data.token) {
    localStorage.setItem('adminToken', response.data.token);
  }
  return response.data;
};

export const logout = () => {
  localStorage.removeItem('adminToken');
  window.location.href = '/login';
};

// Dashboard Stats
export const getStatistics = async () => {
  const response = await api.get('/admin/stats');
  return response.data.data;
};

export const getRevenueChart = async () => {
  const response = await api.get('/admin/revenue-chart');
  return response.data.data;
};

// Users
export const getUsers = async (page = 1, limit = 50, filter = 'all') => {
  const response = await api.get(`/admin/users?page=${page}&limit=${limit}&filter=${filter}`);
  return response.data.data;
};

export const extendPremium = async (userId, days) => {
  const response = await api.post(`/admin/user/${userId}/extend-premium`, { days });
  return response.data;
};

export const deactivatePremium = async (userId) => {
  const response = await api.post(`/admin/user/${userId}/deactivate`);
  return response.data;
};

// Predictions
export const overridePrediction = async (data) => {
  const response = await api.post('/admin/predictions/override', data);
  return response.data;
};

// Results
export const manualResultEntry = async (data) => {
  const response = await api.post('/admin/results/manual-entry', data);
  return response.data;
};

// Notifications
export const sendNotification = async (data) => {
  const response = await api.post('/admin/notification/send', data);
  return response.data;
};

export const getNotificationHistory = async (page = 1, limit = 20) => {
  const response = await api.get(`/admin/notifications/history?page=${page}&limit=${limit}`);
  return response.data.data;
};

// Games Management
export const getAllGames = async (includeInactive = false) => {
  const response = await api.get(`/admin/games?includeInactive=${includeInactive}`);
  return response.data.data;
};

export const getGame = async (id) => {
  const response = await api.get(`/admin/games/${id}`);
  return response.data.data;
};

export const createGame = async (data) => {
  const response = await api.post('/admin/games', data);
  return response.data;
};

export const updateGame = async (id, data) => {
  const response = await api.put(`/admin/games/${id}`, data);
  return response.data;
};

export const deleteGame = async (id) => {
  const response = await api.delete(`/admin/games/${id}`);
  return response.data;
};

export const toggleGameActive = async (id) => {
  const response = await api.post(`/admin/games/${id}/toggle-active`);
  return response.data;
};

export const toggleGameScraping = async (id) => {
  const response = await api.post(`/admin/games/${id}/toggle-scraping`);
  return response.data;
};

export default api;
