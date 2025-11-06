import { useState } from 'react';
import { manualResultEntry } from '../services/api';
import { ClipboardList, Save } from 'lucide-react';

const Results = () => {
  const [formData, setFormData] = useState({
    game: 'shillong',
    date: new Date().toISOString().split('T')[0],
    fr: '',
    sr: '',
    declaredTime: ''
  });
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState('');
  const [error, setError] = useState('');

  const games = {
    'shillong': 'Shillong Teer',
    'khanapara': 'Khanapara Teer',
    'juwai': 'Juwai Teer',
    'shillong-morning': 'Shillong Morning',
    'khanapara-morning': 'Khanapara Morning',
    'juwai-morning': 'Juwai Morning'
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');

    // Validate FR and SR
    const fr = parseInt(formData.fr);
    const sr = parseInt(formData.sr);

    if (isNaN(fr) || fr < 0 || fr > 99) {
      setError('FR must be a number between 0-99');
      return;
    }

    if (isNaN(sr) || sr < 0 || sr > 99) {
      setError('SR must be a number between 0-99');
      return;
    }

    setLoading(true);

    try {
      await manualResultEntry({
        game: formData.game,
        date: formData.date,
        fr,
        sr,
        declaredTime: formData.declaredTime || null
      });

      setSuccess('Result entered successfully! Notifications sent to premium users.');

      // Reset FR and SR
      setFormData({
        ...formData,
        fr: '',
        sr: '',
        declaredTime: ''
      });
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to enter result');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <div style={{ display: 'flex', alignItems: 'center', marginBottom: '24px' }}>
        <ClipboardList size={32} style={{ marginRight: '12px', color: '#7c3aed' }} />
        <h1 style={{ fontSize: '32px', fontWeight: 'bold' }}>Manual Result Entry</h1>
      </div>

      {success && <div className="success">{success}</div>}
      {error && <div className="error">{error}</div>}

      <div className="card">
        <p style={{ marginBottom: '24px', color: '#6b7280' }}>
          Manually enter Teer results when they're declared. Premium users will receive instant push notifications.
        </p>

        <form onSubmit={handleSubmit}>
          <div className="grid grid-2">
            <div>
              <label>Game</label>
              <select
                value={formData.game}
                onChange={(e) => setFormData({ ...formData, game: e.target.value })}
                required
              >
                {Object.entries(games).map(([key, value]) => (
                  <option key={key} value={key}>{value}</option>
                ))}
              </select>
            </div>

            <div>
              <label>Date</label>
              <input
                type="date"
                value={formData.date}
                onChange={(e) => setFormData({ ...formData, date: e.target.value })}
                required
              />
            </div>
          </div>

          <div className="grid grid-2">
            <div>
              <label>First Round (FR)</label>
              <input
                type="number"
                min="0"
                max="99"
                value={formData.fr}
                onChange={(e) => setFormData({ ...formData, fr: e.target.value })}
                placeholder="00-99"
                required
              />
            </div>

            <div>
              <label>Second Round (SR)</label>
              <input
                type="number"
                min="0"
                max="99"
                value={formData.sr}
                onChange={(e) => setFormData({ ...formData, sr: e.target.value })}
                placeholder="00-99"
                required
              />
            </div>
          </div>

          <div>
            <label>Declared Time (optional)</label>
            <input
              type="time"
              value={formData.declaredTime}
              onChange={(e) => setFormData({ ...formData, declaredTime: e.target.value })}
            />
            <small style={{ color: '#6b7280' }}>Optional - leave blank if unknown</small>
          </div>

          <button
            type="submit"
            className="btn btn-primary"
            disabled={loading}
            style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', width: '100%' }}
          >
            <Save size={16} style={{ marginRight: '8px' }} />
            {loading ? 'Saving...' : 'Submit Result'}
          </button>
        </form>
      </div>

      {/* Info Card */}
      <div className="card" style={{ backgroundColor: '#fef3c7', marginTop: '20px' }}>
        <h3 style={{ fontSize: '16px', fontWeight: 'bold', marginBottom: '8px', color: '#92400e' }}>
          ⚠️ Important
        </h3>
        <ul style={{ paddingLeft: '20px', color: '#92400e' }}>
          <li>Double-check the numbers before submitting</li>
          <li>Premium users will receive instant push notifications</li>
          <li>Results cannot be deleted, only updated</li>
          <li>Make sure to enter results as soon as they're declared</li>
        </ul>
      </div>

      {/* Quick Reference */}
      <div className="card" style={{ marginTop: '20px' }}>
        <h3 style={{ fontSize: '16px', fontWeight: 'bold', marginBottom: '12px' }}>
          📋 Quick Reference
        </h3>
        <div className="grid grid-3">
          <div>
            <strong>Shillong Teer</strong>
            <p style={{ fontSize: '14px', color: '#6b7280' }}>FR: ~3:30 PM<br />SR: ~4:30 PM</p>
          </div>
          <div>
            <strong>Khanapara Teer</strong>
            <p style={{ fontSize: '14px', color: '#6b7280' }}>FR: ~3:45 PM<br />SR: ~4:45 PM</p>
          </div>
          <div>
            <strong>Juwai Teer</strong>
            <p style={{ fontSize: '14px', color: '#6b7280' }}>FR: ~3:30 PM<br />SR: ~4:30 PM</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Results;
