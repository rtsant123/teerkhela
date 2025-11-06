import { useState } from 'react';
import { overridePrediction } from '../services/api';
import { Save, TrendingUp } from 'lucide-react';

const Predictions = () => {
  const [formData, setFormData] = useState({
    date: new Date().toISOString().split('T')[0],
    game: 'shillong',
    fr: '',
    sr: '',
    analysis: '',
    confidence: 90
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

    // Validate FR and SR (must be 6 numbers each)
    const frNumbers = formData.fr.split(',').map(n => parseInt(n.trim())).filter(n => !isNaN(n));
    const srNumbers = formData.sr.split(',').map(n => parseInt(n.trim())).filter(n => !isNaN(n));

    if (frNumbers.length !== 6) {
      setError('FR must contain exactly 6 numbers');
      return;
    }

    if (srNumbers.length !== 6) {
      setError('SR must contain exactly 6 numbers');
      return;
    }

    setLoading(true);

    try {
      await overridePrediction({
        date: formData.date,
        game: formData.game,
        fr: frNumbers,
        sr: srNumbers,
        analysis: formData.analysis,
        confidence: parseInt(formData.confidence)
      });

      setSuccess('Prediction overridden successfully!');

      // Reset form
      setFormData({
        ...formData,
        fr: '',
        sr: '',
        analysis: ''
      });
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to override prediction');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <div style={{ display: 'flex', alignItems: 'center', marginBottom: '24px' }}>
        <TrendingUp size={32} style={{ marginRight: '12px', color: '#7c3aed' }} />
        <h1 style={{ fontSize: '32px', fontWeight: 'bold' }}>Override Predictions</h1>
      </div>

      {success && <div className="success">{success}</div>}
      {error && <div className="error">{error}</div>}

      <div className="card">
        <p style={{ marginBottom: '24px', color: '#6b7280' }}>
          Manually override AI predictions for specific games. Your predictions will be shown to premium users.
        </p>

        <form onSubmit={handleSubmit}>
          <div className="grid grid-2">
            <div>
              <label>Date</label>
              <input
                type="date"
                value={formData.date}
                onChange={(e) => setFormData({ ...formData, date: e.target.value })}
                required
              />
            </div>

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
          </div>

          <div>
            <label>FR Numbers (comma-separated, 6 numbers)</label>
            <input
              type="text"
              value={formData.fr}
              onChange={(e) => setFormData({ ...formData, fr: e.target.value })}
              placeholder="e.g., 23, 45, 67, 89, 12, 34"
              required
            />
            <small style={{ color: '#6b7280' }}>Enter exactly 6 numbers separated by commas</small>
          </div>

          <div>
            <label>SR Numbers (comma-separated, 6 numbers)</label>
            <input
              type="text"
              value={formData.sr}
              onChange={(e) => setFormData({ ...formData, sr: e.target.value })}
              placeholder="e.g., 56, 78, 90, 11, 23, 45"
              required
            />
            <small style={{ color: '#6b7280' }}>Enter exactly 6 numbers separated by commas</small>
          </div>

          <div>
            <label>Analysis (explanation for users)</label>
            <textarea
              value={formData.analysis}
              onChange={(e) => setFormData({ ...formData, analysis: e.target.value })}
              rows={4}
              placeholder="Explain your prediction strategy and reasoning..."
              required
            />
          </div>

          <div>
            <label>Confidence Level (%)</label>
            <input
              type="range"
              min="60"
              max="100"
              value={formData.confidence}
              onChange={(e) => setFormData({ ...formData, confidence: e.target.value })}
              style={{ width: '100%' }}
            />
            <div style={{ textAlign: 'center', fontWeight: 'bold', fontSize: '20px', color: '#7c3aed' }}>
              {formData.confidence}%
            </div>
          </div>

          <button
            type="submit"
            className="btn btn-primary"
            disabled={loading}
            style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', width: '100%' }}
          >
            <Save size={16} style={{ marginRight: '8px' }} />
            {loading ? 'Saving...' : 'Override Prediction'}
          </button>
        </form>
      </div>

      {/* Info Card */}
      <div className="card" style={{ backgroundColor: '#dbeafe', marginTop: '20px' }}>
        <h3 style={{ fontSize: '16px', fontWeight: 'bold', marginBottom: '8px', color: '#1e40af' }}>
          ℹ️ How it works
        </h3>
        <ul style={{ paddingLeft: '20px', color: '#1e40af' }}>
          <li>Manual predictions override AI predictions for the selected date and game</li>
          <li>Premium users will see your predictions instead of AI-generated ones</li>
          <li>Make sure to provide clear analysis for users</li>
          <li>Predictions are shown at 6 AM daily to premium users</li>
        </ul>
      </div>
    </div>
  );
};

export default Predictions;
