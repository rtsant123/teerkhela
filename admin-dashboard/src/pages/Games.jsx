import { useEffect, useState } from 'react';
import { getAllGames, createGame, updateGame, deleteGame, toggleGameActive, toggleGameScraping } from '../services/api';
import { Plus, Edit2, Trash2, Power, TrendingUp, X } from 'lucide-react';

const Games = () => {
  const [games, setGames] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [editingGame, setEditingGame] = useState(null);
  const [includeInactive, setIncludeInactive] = useState(false);

  const [formData, setFormData] = useState({
    name: '',
    display_name: '',
    region: '',
    scrape_url: '',
    is_active: true,
    scrape_enabled: false,
    fr_time: '',
    sr_time: '',
    display_order: 0
  });

  useEffect(() => {
    loadGames();
  }, [includeInactive]);

  const loadGames = async () => {
    try {
      setLoading(true);
      const data = await getAllGames(includeInactive);
      setGames(data);
      setLoading(false);
    } catch (err) {
      setError('Failed to load games');
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    try {
      if (editingGame) {
        await updateGame(editingGame.id, formData);
        alert('Game updated successfully');
      } else {
        await createGame(formData);
        alert('Game created successfully');
      }
      setShowModal(false);
      resetForm();
      loadGames();
    } catch (err) {
      alert(err.response?.data?.message || 'Failed to save game');
    }
  };

  const handleEdit = (game) => {
    setEditingGame(game);
    setFormData({
      name: game.name,
      display_name: game.display_name,
      region: game.region || '',
      scrape_url: game.scrape_url || '',
      is_active: game.is_active,
      scrape_enabled: game.scrape_enabled,
      fr_time: game.fr_time || '',
      sr_time: game.sr_time || '',
      display_order: game.display_order || 0
    });
    setShowModal(true);
  };

  const handleDelete = async (game) => {
    if (!confirm(`Are you sure you want to delete "${game.display_name}"?`)) return;

    try {
      await deleteGame(game.id);
      alert('Game deleted successfully');
      loadGames();
    } catch (err) {
      alert('Failed to delete game');
    }
  };

  const handleToggleActive = async (game) => {
    try {
      await toggleGameActive(game.id);
      loadGames();
    } catch (err) {
      alert('Failed to toggle game status');
    }
  };

  const handleToggleScraping = async (game) => {
    try {
      await toggleGameScraping(game.id);
      loadGames();
    } catch (err) {
      alert('Failed to toggle scraping');
    }
  };

  const resetForm = () => {
    setFormData({
      name: '',
      display_name: '',
      region: '',
      scrape_url: '',
      is_active: true,
      scrape_enabled: false,
      fr_time: '',
      sr_time: '',
      display_order: 0
    });
    setEditingGame(null);
  };

  const closeModal = () => {
    setShowModal(false);
    resetForm();
  };

  return (
    <div>
      {/* Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <h1 style={{ fontSize: '32px', fontWeight: 'bold' }}>Games Management</h1>
        <button
          className="btn-primary"
          onClick={() => setShowModal(true)}
          style={{ display: 'flex', alignItems: 'center', gap: '8px' }}
        >
          <Plus size={20} />
          Add New Game
        </button>
      </div>

      {/* Filter */}
      <div className="card" style={{ marginBottom: '20px', padding: '16px' }}>
        <label style={{ display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer' }}>
          <input
            type="checkbox"
            checked={includeInactive}
            onChange={(e) => setIncludeInactive(e.target.checked)}
          />
          <span>Show inactive games</span>
        </label>
      </div>

      {/* Games Grid */}
      {loading ? (
        <div style={{ textAlign: 'center', padding: '40px' }}>
          <p>Loading games...</p>
        </div>
      ) : error ? (
        <div className="card" style={{ padding: '20px', backgroundColor: '#fee2e2', color: '#991b1b' }}>
          {error}
        </div>
      ) : games.length === 0 ? (
        <div className="card" style={{ textAlign: 'center', padding: '40px' }}>
          <p style={{ color: '#6b7280' }}>No games found</p>
        </div>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(350px, 1fr))', gap: '20px' }}>
          {games.map((game) => (
            <div key={game.id} className="card" style={{ position: 'relative' }}>
              {/* Active Status Badge */}
              <div style={{ position: 'absolute', top: '12px', right: '12px' }}>
                <span
                  style={{
                    padding: '4px 12px',
                    borderRadius: '12px',
                    fontSize: '12px',
                    fontWeight: '600',
                    backgroundColor: game.is_active ? '#d1fae5' : '#fee2e2',
                    color: game.is_active ? '#065f46' : '#991b1b'
                  }}
                >
                  {game.is_active ? 'Active' : 'Inactive'}
                </span>
              </div>

              {/* Game Info */}
              <div style={{ marginTop: '8px' }}>
                <h3 style={{ fontSize: '20px', fontWeight: 'bold', marginBottom: '8px' }}>
                  {game.display_name}
                </h3>
                <p style={{ color: '#6b7280', fontSize: '14px', marginBottom: '4px' }}>
                  ID: <code style={{ backgroundColor: '#f3f4f6', padding: '2px 6px', borderRadius: '4px' }}>{game.name}</code>
                </p>
                {game.region && (
                  <p style={{ color: '#6b7280', fontSize: '14px', marginBottom: '4px' }}>
                    📍 Region: {game.region}
                  </p>
                )}
                <p style={{ color: '#6b7280', fontSize: '14px', marginBottom: '4px' }}>
                  🔗 Scrape URL: {game.scrape_url || 'N/A'}
                </p>
                <p style={{ color: '#6b7280', fontSize: '14px', marginBottom: '4px' }}>
                  🤖 Auto-Scraping: <strong>{game.scrape_enabled ? 'Enabled' : 'Disabled'}</strong>
                </p>
                <p style={{ color: '#6b7280', fontSize: '14px' }}>
                  📊 Display Order: {game.display_order}
                </p>
              </div>

              {/* Statistics */}
              {game.stats && (
                <div style={{
                  marginTop: '16px',
                  padding: '12px',
                  backgroundColor: '#f9fafb',
                  borderRadius: '8px'
                }}>
                  <p style={{ fontSize: '12px', color: '#6b7280', marginBottom: '4px' }}>
                    📈 Total Results: <strong>{game.stats.total_results || 0}</strong>
                  </p>
                  <p style={{ fontSize: '12px', color: '#6b7280' }}>
                    📅 Last Result: {game.stats.last_result_date || 'Never'}
                  </p>
                </div>
              )}

              {/* Actions */}
              <div style={{ display: 'flex', gap: '8px', marginTop: '16px', flexWrap: 'wrap' }}>
                <button
                  className="btn-secondary"
                  onClick={() => handleEdit(game)}
                  style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '4px', fontSize: '14px' }}
                >
                  <Edit2 size={16} />
                  Edit
                </button>
                <button
                  className={game.is_active ? "btn-warning" : "btn-success"}
                  onClick={() => handleToggleActive(game)}
                  style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '4px', fontSize: '14px' }}
                >
                  <Power size={16} />
                  {game.is_active ? 'Deactivate' : 'Activate'}
                </button>
                <button
                  className={game.scrape_enabled ? "btn-secondary" : "btn-primary"}
                  onClick={() => handleToggleScraping(game)}
                  style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '4px', fontSize: '14px' }}
                >
                  <TrendingUp size={16} />
                  {game.scrape_enabled ? 'Stop Scraping' : 'Enable Scraping'}
                </button>
                <button
                  className="btn-danger"
                  onClick={() => handleDelete(game)}
                  style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '4px', fontSize: '14px', padding: '8px 12px' }}
                >
                  <Trash2 size={16} />
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Modal */}
      {showModal && (
        <div style={{
          position: 'fixed',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          backgroundColor: 'rgba(0, 0, 0, 0.5)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          zIndex: 1000
        }}>
          <div className="card" style={{
            width: '90%',
            maxWidth: '600px',
            maxHeight: '90vh',
            overflow: 'auto',
            position: 'relative'
          }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
              <h2 style={{ fontSize: '24px', fontWeight: 'bold' }}>
                {editingGame ? 'Edit Game' : 'Create New Game'}
              </h2>
              <button
                onClick={closeModal}
                style={{ background: 'none', border: 'none', cursor: 'pointer', padding: '4px' }}
              >
                <X size={24} />
              </button>
            </div>

            <form onSubmit={handleSubmit}>
              <div style={{ marginBottom: '16px' }}>
                <label style={{ display: 'block', marginBottom: '4px', fontWeight: '500' }}>
                  Game ID (Internal Name) *
                </label>
                <input
                  type="text"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  placeholder="e.g., bhutan, assam-teer"
                  required
                  disabled={editingGame !== null}
                  style={{ opacity: editingGame ? 0.6 : 1 }}
                />
                <small style={{ color: '#6b7280' }}>Lowercase, no spaces. Use hyphens for multi-word names.</small>
              </div>

              <div style={{ marginBottom: '16px' }}>
                <label style={{ display: 'block', marginBottom: '4px', fontWeight: '500' }}>
                  Display Name *
                </label>
                <input
                  type="text"
                  value={formData.display_name}
                  onChange={(e) => setFormData({ ...formData, display_name: e.target.value })}
                  placeholder="e.g., Bhutan Teer, Assam Teer"
                  required
                />
              </div>

              <div style={{ marginBottom: '16px' }}>
                <label style={{ display: 'block', marginBottom: '4px', fontWeight: '500' }}>
                  Region
                </label>
                <input
                  type="text"
                  value={formData.region}
                  onChange={(e) => setFormData({ ...formData, region: e.target.value })}
                  placeholder="e.g., Meghalaya, Assam, Bhutan"
                />
              </div>

              <div style={{ marginBottom: '16px' }}>
                <label style={{ display: 'block', marginBottom: '4px', fontWeight: '500' }}>
                  Scrape URL
                </label>
                <input
                  type="text"
                  value={formData.scrape_url}
                  onChange={(e) => setFormData({ ...formData, scrape_url: e.target.value })}
                  placeholder="e.g., bhutan-teer"
                />
                <small style={{ color: '#6b7280' }}>URL path for scraping results (if applicable)</small>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px', marginBottom: '16px' }}>
                <div>
                  <label style={{ display: 'block', marginBottom: '4px', fontWeight: '500' }}>
                    FR Time
                  </label>
                  <input
                    type="time"
                    value={formData.fr_time}
                    onChange={(e) => setFormData({ ...formData, fr_time: e.target.value })}
                  />
                </div>

                <div>
                  <label style={{ display: 'block', marginBottom: '4px', fontWeight: '500' }}>
                    SR Time
                  </label>
                  <input
                    type="time"
                    value={formData.sr_time}
                    onChange={(e) => setFormData({ ...formData, sr_time: e.target.value })}
                  />
                </div>
              </div>

              <div style={{ marginBottom: '16px' }}>
                <label style={{ display: 'block', marginBottom: '4px', fontWeight: '500' }}>
                  Display Order
                </label>
                <input
                  type="number"
                  value={formData.display_order}
                  onChange={(e) => setFormData({ ...formData, display_order: parseInt(e.target.value) })}
                  min="0"
                />
                <small style={{ color: '#6b7280' }}>Lower numbers appear first</small>
              </div>

              <div style={{ marginBottom: '16px' }}>
                <label style={{ display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer' }}>
                  <input
                    type="checkbox"
                    checked={formData.is_active}
                    onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
                  />
                  <span>Active (show in app)</span>
                </label>
              </div>

              <div style={{ marginBottom: '20px' }}>
                <label style={{ display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer' }}>
                  <input
                    type="checkbox"
                    checked={formData.scrape_enabled}
                    onChange={(e) => setFormData({ ...formData, scrape_enabled: e.target.checked })}
                  />
                  <span>Enable Auto-Scraping</span>
                </label>
              </div>

              <div style={{ display: 'flex', gap: '12px' }}>
                <button type="submit" className="btn-primary" style={{ flex: 1 }}>
                  {editingGame ? 'Update Game' : 'Create Game'}
                </button>
                <button type="button" onClick={closeModal} className="btn-secondary" style={{ flex: 1 }}>
                  Cancel
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Games;
