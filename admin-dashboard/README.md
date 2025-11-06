# Teer Khela Admin Dashboard

React-based admin dashboard for managing the Teer Khela mobile app.

## Features

- ✅ **Dashboard** - Overview statistics and revenue charts
- ✅ **User Management** - View, extend, and deactivate users
- ✅ **Predictions Override** - Manually set predictions
- ✅ **Results Entry** - Add Teer results with instant notifications
- ✅ **Push Notifications** - Send notifications to premium users
- ✅ **Notification History** - View past notifications

## Tech Stack

- React 18
- Vite (build tool)
- React Router (navigation)
- Chart.js (charts)
- Axios (API calls)
- Lucide React (icons)

## Setup

### 1. Install Dependencies

```bash
cd admin-dashboard
npm install
```

### 2. Configure API URL

Edit `src/services/api.js`:

```javascript
// Development
const API_BASE_URL = 'http://localhost:5000/api';

// Production
const API_BASE_URL = 'https://your-backend-url.up.railway.app/api';
```

### 3. Run Development Server

```bash
npm run dev
```

Open http://localhost:3000

### 4. Default Login

- **Username:** `admin` (from backend .env)
- **Password:** Your admin password (from backend .env)

## Build for Production

```bash
npm run build
```

Output will be in `dist/` directory.

## Deployment

### Vercel (Recommended)

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel --prod
```

### Netlify

```bash
# Build
npm run build

# Drag and drop dist/ folder to Netlify
```

### Manual Deployment

1. Run `npm run build`
2. Upload `dist/` folder to any static host
3. Configure redirects to `index.html` for SPA routing

## Pages

### Dashboard (`/`)
- Total users, premium users, revenue stats
- Revenue chart (last 30 days)
- Quick metrics

### Users (`/users`)
- User list with pagination
- Search by email/ID
- Filter: All/Premium/Free/Expired
- Extend premium
- Deactivate premium

### Predictions (`/predictions`)
- Override AI predictions
- Set FR/SR numbers (6 each)
- Add analysis text
- Set confidence level

### Results (`/results`)
- Manual result entry
- Select game, date
- Enter FR/SR
- Instant notifications to premium users

### Notifications (`/notifications`)
- Send push notifications
- Target: All Premium / All / Specific User
- Optional action (open screen)
- View notification history
- Quick templates

## API Integration

All API calls go through `src/services/api.js`:

```javascript
import { getStatistics, sendNotification } from '../services/api';

// Example usage
const stats = await getStatistics();
await sendNotification({ title, body, target });
```

## Authentication

- Login page at `/login`
- JWT token stored in `localStorage`
- Auto-redirect to `/login` if unauthorized
- Token included in all API requests

## Environment

No `.env` file needed. Just update API_BASE_URL in `src/services/api.js`.

## Troubleshooting

### "Failed to load" errors
- Check backend is running
- Verify API_BASE_URL is correct
- Check browser console for CORS errors

### "Unauthorized" error
- Backend admin credentials in `.env` must match
- Clear localStorage and login again

### Deployment issues
- Ensure SPA redirect rules are configured
- For Vercel/Netlify, they handle this automatically

## Support

For issues:
1. Check backend is running and accessible
2. Verify admin credentials
3. Check browser console for errors
4. Test API endpoints with Postman

## License

Proprietary - All rights reserved
