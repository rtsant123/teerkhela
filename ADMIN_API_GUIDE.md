# 🔐 Admin Panel API Guide - Teer Khela

## Base URL
```
https://teerkhela-production.up.railway.app/api/admin
```

---

## 🔑 Authentication

### **1. Login**
**Endpoint:** `POST /api/admin/login`

**Request:**
```json
{
  "username": "admin",
  "password": "admin123"
}
```

**Response:**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "admin": {
    "id": "admin-123",
    "username": "admin",
    "role": "admin"
  }
}
```

**Save this token!** Use it in all subsequent requests as:
```
Authorization: Bearer <token>
```

---

## 📊 Dashboard

### **2. Get Statistics**
**Endpoint:** `GET /api/admin/stats`

**Headers:**
```
Authorization: Bearer <your_token>
```

**Response:**
```json
{
  "success": true,
  "stats": {
    "totalUsers": 150,
    "premiumUsers": 25,
    "totalRevenue": 1225,
    "todaySignups": 5,
    "activeSubscriptions": 23
  }
}
```

### **3. Get Revenue Chart**
**Endpoint:** `GET /api/admin/revenue-chart?days=30`

**Response:**
```json
{
  "success": true,
  "data": [
    {"date": "2025-01-01", "revenue": 245, "subscriptions": 5},
    {"date": "2025-01-02", "revenue": 98, "subscriptions": 2}
  ]
}
```

---

## 🎯 Manual Results Entry

### **4. Add Single Result**
**Endpoint:** `POST /api/admin/results/manual-entry`

**Request:**
```json
{
  "game": "shillong",
  "date": "2025-01-08",
  "fr": 45,
  "sr": 78
}
```

**Response:**
```json
{
  "success": true,
  "message": "Result added successfully",
  "result": {
    "id": "res-123",
    "game": "shillong",
    "date": "2025-01-08",
    "fr": 45,
    "sr": 78
  }
}
```

### **5. Bulk Add Results (All 6 Games)**
**Endpoint:** `POST /api/admin/results/bulk-add`

**Request:**
```json
{
  "date": "2025-01-08",
  "results": [
    {"game": "shillong", "fr": 45, "sr": 78},
    {"game": "khanapara", "fr": 23, "sr": 67},
    {"game": "juwai", "fr": 34, "sr": 89},
    {"game": "shillong-morning", "fr": 12, "sr": 56},
    {"game": "khanapara-morning", "fr": 67, "sr": 90},
    {"game": "juwai-morning", "fr": 45, "sr": 23}
  ]
}
```

**Response:**
```json
{
  "success": true,
  "message": "Bulk results added successfully",
  "count": 6
}
```

---

## 🤖 Predictions Management

### **6. Override AI Prediction**
**Endpoint:** `POST /api/admin/predictions/override`

**Request:**
```json
{
  "game": "shillong",
  "date": "2025-01-08",
  "fr": [12, 23, 34, 45, 56, 67, 78, 89, 90, 01],
  "sr": [11, 22, 33, 44, 55, 66, 77, 88, 99, 00]
}
```

**Response:**
```json
{
  "success": true,
  "message": "Prediction overridden successfully"
}
```

### **7. Force Generate Predictions**
**Endpoint:** `POST /api/admin/predictions/generate`

**Request:**
```json
{
  "game": "shillong"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Predictions generated for shillong"
}
```

---

## 👥 User Management

### **8. Get All Users**
**Endpoint:** `GET /api/admin/users?page=1&limit=50&filter=premium`

**Query Parameters:**
- `page` - Page number (default: 1)
- `limit` - Items per page (default: 50)
- `filter` - all | premium | free (default: all)

**Response:**
```json
{
  "success": true,
  "users": [
    {
      "id": "usr-123",
      "phone": "+91xxxxxxxxxx",
      "isPremium": true,
      "expiryDate": "2025-02-08",
      "createdAt": "2025-01-01"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 50,
    "total": 150,
    "pages": 3
  }
}
```

### **9. Extend Premium**
**Endpoint:** `POST /api/admin/user/:userId/extend-premium`

**Request:**
```json
{
  "days": 30
}
```

**Response:**
```json
{
  "success": true,
  "message": "Premium extended by 30 days",
  "newExpiryDate": "2025-03-08"
}
```

### **10. Deactivate Premium**
**Endpoint:** `POST /api/admin/user/:userId/deactivate`

**Response:**
```json
{
  "success": true,
  "message": "Premium deactivated"
}
```

---

## 📨 Push Notifications

### **11. Send Push Notification**
**Endpoint:** `POST /api/admin/notification/send`

**Request:**
```json
{
  "target": "all",
  "title": "New Results Available!",
  "body": "Check the latest Teer results now",
  "data": {
    "screen": "home"
  }
}
```

**Target options:**
- `all` - All users
- `premium` - Only premium users
- `free` - Only free users
- `user:<userId>` - Specific user

**Response:**
```json
{
  "success": true,
  "message": "Notification sent to 150 users"
}
```

### **12. Get Notification History**
**Endpoint:** `GET /api/admin/notifications/history?limit=50`

**Response:**
```json
{
  "success": true,
  "notifications": [
    {
      "id": "notif-123",
      "title": "New Results",
      "sentTo": 150,
      "sentAt": "2025-01-08T10:00:00Z"
    }
  ]
}
```

---

## 🎮 Games Management

### **13. Get All Games**
**Endpoint:** `GET /api/admin/games`

**Response:**
```json
{
  "success": true,
  "games": [
    {
      "id": "game-1",
      "name": "Shillong Teer",
      "slug": "shillong",
      "isActive": true,
      "scrapingEnabled": true
    }
  ]
}
```

### **14. Create New Game**
**Endpoint:** `POST /api/admin/games`

**Request:**
```json
{
  "name": "New Teer Game",
  "slug": "new-game",
  "isActive": true,
  "scrapingEnabled": false,
  "scrapeUrl": "https://example.com/results"
}
```

### **15. Toggle Game Active**
**Endpoint:** `POST /api/admin/games/:id/toggle-active`

**Response:**
```json
{
  "success": true,
  "message": "Game toggled",
  "isActive": false
}
```

---

## 🛠️ Quick Test with cURL

### Login:
```bash
curl -X POST https://teerkhela-production.up.railway.app/api/admin/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

### Add Result:
```bash
curl -X POST https://teerkhela-production.up.railway.app/api/admin/results/manual-entry \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "game": "shillong",
    "date": "2025-01-08",
    "fr": 45,
    "sr": 78
  }'
```

### Send Notification:
```bash
curl -X POST https://teerkhela-production.up.railway.app/api/admin/notification/send \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "target": "all",
    "title": "Test Notification",
    "body": "This is a test"
  }'
```

---

## 🔒 Default Admin Credentials

**Username:** `admin`
**Password:** `admin123`

**⚠️ IMPORTANT:** Change these credentials immediately in production!

To change admin password, update it in the database or add a change password endpoint.

---

## 📱 Admin Dashboard (Web)

You can build a simple admin dashboard using these APIs. Features:

**Dashboard:**
- Total users, revenue, subscriptions
- Revenue chart (last 30 days)

**Results Management:**
- Manual entry form (single game)
- Bulk entry form (all 6 games at once)

**User Management:**
- List all users (with pagination)
- Extend/deactivate premium

**Predictions:**
- Override AI predictions
- Force regenerate predictions

**Notifications:**
- Send push notifications
- View history

---

**Generated with Claude Code**
**Date:** January 8, 2025
**Version:** 1.0.0
