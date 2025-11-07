import { useState } from 'react';
import { bulkAddResults } from '../services/api';
import { ClipboardList, Save, Zap } from 'lucide-react';

const Results = () => {
  const games = [
    { id: 'shillong', name: 'Shillong Teer', time: '~3:30 PM / 4:30 PM' },
    { id: 'khanapara', name: 'Khanapara Teer', time: '~3:45 PM / 4:45 PM' },
    { id: 'juwai', name: 'Juwai Teer', time: '~3:30 PM / 4:30 PM' },
    { id: 'shillong-morning', name: 'Shillong Morning', time: '~10:30 AM / 11:30 AM' },
    { id: 'khanapara-morning', name: 'Khanapara Morning', time: '~10:45 AM / 11:45 AM' },
    { id: 'juwai-morning', name: 'Juwai Morning', time: '~10:30 AM / 11:30 AM' }
  ];

  const [date, setDate] = useState(new Date().toISOString().split('T')[0]);
  const [results, setResults] = useState(
    games.reduce((acc, game) => ({
      ...acc,
      [game.id]: { fr: '', sr: '' }
    }), {})
  );
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState('');
  const [error, setError] = useState('');

  const updateResult = (gameId, field, value) => {
    setResults(prev => ({
      ...prev,
      [gameId]: {
        ...prev[gameId],
        [field]: value
      }
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');

    // Collect all games with data
    const resultsToSubmit = [];
    for (const game of games) {
      const fr = results[game.id].fr;
      const sr = results[game.id].sr;

      // Skip if both FR and SR are empty
      if (!fr && !sr) continue;

      // Validate
      if (fr && (isNaN(parseInt(fr)) || parseInt(fr) < 0 || parseInt(fr) > 99)) {
        setError(`${game.name}: FR must be between 0-99`);
        return;
      }
      if (sr && (isNaN(parseInt(sr)) || parseInt(sr) < 0 || parseInt(sr) > 99)) {
        setError(`${game.name}: SR must be between 0-99`);
        return;
      }

      resultsToSubmit.push({
        game: game.id,
        fr: fr ? parseInt(fr) : null,
        sr: sr ? parseInt(sr) : null
      });
    }

    if (resultsToSubmit.length === 0) {
      setError('Please enter at least one result');
      return;
    }

    setLoading(true);

    try {
      await bulkAddResults({
        date,
        results: resultsToSubmit
      });

      setSuccess(`✅ Successfully added ${resultsToSubmit.length} results! Notifications sent to premium users.`);

      // Clear all results
      setResults(
        games.reduce((acc, game) => ({
          ...acc,
          [game.id]: { fr: '', sr: '' }
        }), {})
      );
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to submit results');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '24px' }}>
        <div style={{ display: 'flex', alignItems: 'center' }}>
          <Zap size={32} style={{ marginRight: '12px', color: '#0891b2' }} />
          <h1 style={{ fontSize: '32px', fontWeight: 'bold' }}>Bulk Result Entry</h1>
        </div>
        <div style={{ fontSize: '14px', color: '#6b7280' }}>
          Enter all 6 game results at once
        </div>
      </div>

      {success && <div className="success">{success}</div>}
      {error && <div className="error">{error}</div>}

      <form onSubmit={handleSubmit}>
        {/* Date Picker */}
        <div className="card" style={{ marginBottom: '20px' }}>
          <label style={{ fontSize: '16px', fontWeight: 'bold', marginBottom: '8px', display: 'block' }}>
            Select Date
          </label>
          <input
            type="date"
            value={date}
            onChange={(e) => setDate(e.target.value)}
            required
            style={{ width: '100%', maxWidth: '300px' }}
          />
        </div>

        {/* All Games Grid */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(350px, 1fr))', gap: '20px', marginBottom: '24px' }}>
          {games.map(game => (
            <div key={game.id} className="card" style={{ backgroundColor: '#f0f9ff' }}>
              <h3 style={{ fontSize: '18px', fontWeight: 'bold', marginBottom: '4px', color: '#0891b2' }}>
                {game.name}
              </h3>
              <p style={{ fontSize: '12px', color: '#6b7280', marginBottom: '16px' }}>
                {game.time}
              </p>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                <div>
                  <label style={{ fontSize: '14px', fontWeight: '500', marginBottom: '4px', display: 'block' }}>
                    First Round (FR)
                  </label>
                  <input
                    type="number"
                    min="0"
                    max="99"
                    value={results[game.id].fr}
                    onChange={(e) => updateResult(game.id, 'fr', e.target.value)}
                    placeholder="00-99"
                    style={{ width: '100%', textAlign: 'center', fontSize: '18px', fontWeight: 'bold' }}
                  />
                </div>

                <div>
                  <label style={{ fontSize: '14px', fontWeight: '500', marginBottom: '4px', display: 'block' }}>
                    Second Round (SR)
                  </label>
                  <input
                    type="number"
                    min="0"
                    max="99"
                    value={results[game.id].sr}
                    onChange={(e) => updateResult(game.id, 'sr', e.target.value)}
                    placeholder="00-99"
                    style={{ width: '100%', textAlign: 'center', fontSize: '18px', fontWeight: 'bold' }}
                  />
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Submit Button */}
        <button
          type="submit"
          className="btn btn-primary"
          disabled={loading}
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            width: '100%',
            fontSize: '18px',
            padding: '16px',
            backgroundColor: '#0891b2'
          }}
        >
          <Save size={20} style={{ marginRight: '8px' }} />
          {loading ? 'Submitting All Results...' : 'Submit All Results & Notify Users'}
        </button>
      </form>

      {/* Info Card */}
      <div className="card" style={{ backgroundColor: '#fef3c7', marginTop: '20px' }}>
        <h3 style={{ fontSize: '16px', fontWeight: 'bold', marginBottom: '8px', color: '#92400e' }}>
          ⚠️ Important
        </h3>
        <ul style={{ paddingLeft: '20px', color: '#92400e' }}>
          <li>You can enter results for some or all games - leave empty fields blank</li>
          <li>Double-check all numbers before submitting</li>
          <li>Premium users will receive instant push notifications for ALL entered results</li>
          <li>Results can be updated later if needed</li>
        </ul>
      </div>
    </div>
  );
};

export default Results;
