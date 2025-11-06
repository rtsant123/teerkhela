import { useState, useEffect } from 'react';
import { sendNotification, getNotificationHistory } from '../services/api';
import { Bell, Send, History } from 'lucide-react';

const Notifications = () => {
  const [formData, setFormData] = useState({
    title: '',
    body: '',
    target: 'all-premium',
    screen: '',
    userId: ''
  });
  const [history, setHistory] = useState([]);
  const [loading, setLoading] = useState(false);
  const [loadingHistory, setLoadingHistory] = useState(false);
  const [success, setSuccess] = useState('');
  const [error, setError] = useState('');

  useEffect(() => {
    loadHistory();
  }, []);

  const loadHistory = async () => {
    try {
      setLoadingHistory(true);
      const data = await getNotificationHistory(1, 10);
      setHistory(data.notifications || []);
    } catch (err) {
      console.error('Failed to load history:', err);
    } finally {
      setLoadingHistory(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');

    if (formData.target === 'specific' && !formData.userId) {
      setError('Please enter a user ID');
      return;
    }

    setLoading(true);

    try {
      const result = await sendNotification({
        title: formData.title,
        body: formData.body,
        target: formData.target,
        action: formData.screen ? 'open-screen' : 'none',
        screen: formData.screen,
        userId: formData.target === 'specific' ? formData.userId : undefined
      });

      setSuccess(`Notification sent successfully! Delivered to ${result.sent} users.`);

      // Reset form
      setFormData({
        title: '',
        body: '',
        target: 'all-premium',
        screen: '',
        userId: ''
      });

      // Reload history
      loadHistory();
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to send notification');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <div style={{ display: 'flex', alignItems: 'center', marginBottom: '24px' }}>
        <Bell size={32} style={{ marginRight: '12px', color: '#7c3aed' }} />
        <h1 style={{ fontSize: '32px', fontWeight: 'bold' }}>Send Push Notifications</h1>
      </div>

      {success && <div className="success">{success}</div>}
      {error && <div className="error">{error}</div>}

      {/* Send Notification Form */}
      <div className="card">
        <h2 style={{ fontSize: '20px', fontWeight: 'bold', marginBottom: '16px', display: 'flex', alignItems: 'center' }}>
          <Send size={20} style={{ marginRight: '8px' }} />
          Compose Notification
        </h2>

        <form onSubmit={handleSubmit}>
          <div>
            <label>Title</label>
            <input
              type="text"
              value={formData.title}
              onChange={(e) => setFormData({ ...formData, title: e.target.value })}
              placeholder="e.g., New Feature Added!"
              maxLength={50}
              required
            />
            <small style={{ color: '#6b7280' }}>Max 50 characters</small>
          </div>

          <div>
            <label>Message</label>
            <textarea
              value={formData.body}
              onChange={(e) => setFormData({ ...formData, body: e.target.value })}
              rows={4}
              placeholder="e.g., Check out the new dream bot feature with multi-language support..."
              maxLength={200}
              required
            />
            <small style={{ color: '#6b7280' }}>Max 200 characters</small>
          </div>

          <div className="grid grid-2">
            <div>
              <label>Target Audience</label>
              <select
                value={formData.target}
                onChange={(e) => setFormData({ ...formData, target: e.target.value })}
                required
              >
                <option value="all-premium">All Premium Users</option>
                <option value="all">All Users</option>
                <option value="specific">Specific User (by ID)</option>
              </select>
            </div>

            <div>
              <label>Action (Optional)</label>
              <select
                value={formData.screen}
                onChange={(e) => setFormData({ ...formData, screen: e.target.value })}
              >
                <option value="">No Action</option>
                <option value="predictions">Open Predictions</option>
                <option value="dream">Open Dream Bot</option>
                <option value="subscribe">Open Subscribe</option>
                <option value="profile">Open Profile</option>
              </select>
            </div>
          </div>

          {formData.target === 'specific' && (
            <div>
              <label>User ID</label>
              <input
                type="text"
                value={formData.userId}
                onChange={(e) => setFormData({ ...formData, userId: e.target.value })}
                placeholder="Enter user ID"
              />
            </div>
          )}

          <button
            type="submit"
            className="btn btn-primary"
            disabled={loading}
            style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', width: '100%' }}
          >
            <Send size={16} style={{ marginRight: '8px' }} />
            {loading ? 'Sending...' : 'Send Notification'}
          </button>
        </form>
      </div>

      {/* Notification History */}
      <div className="card" style={{ marginTop: '24px' }}>
        <h2 style={{ fontSize: '20px', fontWeight: 'bold', marginBottom: '16px', display: 'flex', alignItems: 'center' }}>
          <History size={20} style={{ marginRight: '8px' }} />
          Recent Notifications
        </h2>

        {loadingHistory ? (
          <div className="loading">Loading history...</div>
        ) : history.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '40px', color: '#9ca3af' }}>
            No notifications sent yet
          </div>
        ) : (
          <div style={{ overflowX: 'auto' }}>
            <table>
              <thead>
                <tr>
                  <th>Title</th>
                  <th>Body</th>
                  <th>Target</th>
                  <th>Sent Count</th>
                  <th>Sent At</th>
                </tr>
              </thead>
              <tbody>
                {history.map((notification) => (
                  <tr key={notification.id}>
                    <td style={{ fontWeight: 'bold' }}>{notification.title}</td>
                    <td style={{ maxWidth: '300px', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                      {notification.body}
                    </td>
                    <td>
                      <span className="badge badge-info">
                        {notification.target.replace('-', ' ')}
                      </span>
                    </td>
                    <td>
                      <strong>{notification.sent_count || 0}</strong> users
                    </td>
                    <td>
                      {notification.sent_at
                        ? new Date(notification.sent_at).toLocaleString()
                        : new Date(notification.created_at).toLocaleString()}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Info Card */}
      <div className="card" style={{ backgroundColor: '#dbeafe', marginTop: '20px' }}>
        <h3 style={{ fontSize: '16px', fontWeight: 'bold', marginBottom: '8px', color: '#1e40af' }}>
          ℹ️ Notification Guidelines
        </h3>
        <ul style={{ paddingLeft: '20px', color: '#1e40af' }}>
          <li>Keep titles short and impactful (max 50 characters)</li>
          <li>Write clear, actionable messages (max 200 characters)</li>
          <li>Use "All Premium Users" for feature announcements</li>
          <li>Test with a specific user before sending to all</li>
          <li>Notifications are delivered instantly via Firebase Cloud Messaging</li>
        </ul>
      </div>

      {/* Quick Templates */}
      <div className="card" style={{ marginTop: '20px' }}>
        <h3 style={{ fontSize: '16px', fontWeight: 'bold', marginBottom: '12px' }}>
          📝 Quick Templates
        </h3>
        <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap' }}>
          <button
            className="btn btn-secondary"
            onClick={() => setFormData({
              ...formData,
              title: '🔮 Daily Predictions Ready!',
              body: 'Check AI predictions for all 6 Teer games now',
              screen: 'predictions'
            })}
          >
            Daily Predictions
          </button>
          <button
            className="btn btn-secondary"
            onClick={() => setFormData({
              ...formData,
              title: '⚡ Result Declared!',
              body: 'Shillong Teer result is now available',
              screen: ''
            })}
          >
            Result Alert
          </button>
          <button
            className="btn btn-secondary"
            onClick={() => setFormData({
              ...formData,
              title: '🎉 New Feature!',
              body: 'Check out our new multi-language dream bot',
              screen: 'dream'
            })}
          >
            Feature Announcement
          </button>
        </div>
      </div>
    </div>
  );
};

export default Notifications;
