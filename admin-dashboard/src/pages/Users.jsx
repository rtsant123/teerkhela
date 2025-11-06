import { useEffect, useState } from 'react';
import { getUsers, extendPremium, deactivatePremium } from '../services/api';
import { Search, Filter, UserPlus, UserMinus } from 'lucide-react';

const Users = () => {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [filter, setFilter] = useState('all');
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    loadUsers();
  }, [page, filter]);

  const loadUsers = async () => {
    try {
      setLoading(true);
      const data = await getUsers(page, 50, filter);
      setUsers(data.users);
      setTotalPages(data.totalPages);
      setLoading(false);
    } catch (err) {
      setError('Failed to load users');
      setLoading(false);
    }
  };

  const handleExtendPremium = async (userId) => {
    const days = prompt('Enter number of days to extend:', '30');
    if (!days) return;

    try {
      await extendPremium(userId, parseInt(days));
      alert('Premium extended successfully');
      loadUsers();
    } catch (err) {
      alert('Failed to extend premium');
    }
  };

  const handleDeactivate = async (userId) => {
    if (!confirm('Are you sure you want to deactivate this user\'s premium?')) return;

    try {
      await deactivatePremium(userId);
      alert('Premium deactivated successfully');
      loadUsers();
    } catch (err) {
      alert('Failed to deactivate premium');
    }
  };

  const filteredUsers = users.filter(user =>
    user.email?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.id?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <h1 style={{ fontSize: '32px', fontWeight: 'bold' }}>Users</h1>
      </div>

      {/* Filters */}
      <div className="card" style={{ marginBottom: '20px' }}>
        <div style={{ display: 'flex', gap: '16px', flexWrap: 'wrap' }}>
          <div style={{ flex: 1, minWidth: '200px' }}>
            <div style={{ position: 'relative' }}>
              <Search size={20} style={{ position: 'absolute', left: '12px', top: '12px', color: '#9ca3af' }} />
              <input
                type="text"
                placeholder="Search by email or user ID..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                style={{ paddingLeft: '40px' }}
              />
            </div>
          </div>

          <select
            value={filter}
            onChange={(e) => {
              setFilter(e.target.value);
              setPage(1);
            }}
            style={{ minWidth: '150px' }}
          >
            <option value="all">All Users</option>
            <option value="premium">Premium Only</option>
            <option value="free">Free Only</option>
            <option value="expired">Expired</option>
          </select>

          <button className="btn btn-secondary" onClick={loadUsers}>
            <Filter size={16} style={{ marginRight: '8px' }} />
            Refresh
          </button>
        </div>
      </div>

      {error && <div className="error">{error}</div>}

      {loading ? (
        <div className="loading">Loading users...</div>
      ) : (
        <>
          {/* Users Table */}
          <div className="card" style={{ overflowX: 'auto' }}>
            <table>
              <thead>
                <tr>
                  <th>User ID</th>
                  <th>Email</th>
                  <th>Status</th>
                  <th>Expiry Date</th>
                  <th>Created</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {filteredUsers.map((user) => (
                  <tr key={user.id}>
                    <td style={{ fontSize: '12px', fontFamily: 'monospace' }}>
                      {user.id?.substring(0, 8)}...
                    </td>
                    <td>{user.email || 'N/A'}</td>
                    <td>
                      {user.is_premium ? (
                        <span className="badge badge-success">Premium</span>
                      ) : (
                        <span className="badge badge-danger">Free</span>
                      )}
                    </td>
                    <td>
                      {user.expiry_date
                        ? new Date(user.expiry_date).toLocaleDateString()
                        : 'N/A'}
                    </td>
                    <td>{new Date(user.created_at).toLocaleDateString()}</td>
                    <td>
                      <div style={{ display: 'flex', gap: '8px' }}>
                        <button
                          className="btn btn-success"
                          style={{ padding: '6px 12px', fontSize: '12px' }}
                          onClick={() => handleExtendPremium(user.id)}
                          title="Extend Premium"
                        >
                          <UserPlus size={14} />
                        </button>
                        {user.is_premium && (
                          <button
                            className="btn btn-danger"
                            style={{ padding: '6px 12px', fontSize: '12px' }}
                            onClick={() => handleDeactivate(user.id)}
                            title="Deactivate Premium"
                          >
                            <UserMinus size={14} />
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>

            {filteredUsers.length === 0 && (
              <div style={{ textAlign: 'center', padding: '40px', color: '#9ca3af' }}>
                No users found
              </div>
            )}
          </div>

          {/* Pagination */}
          {totalPages > 1 && (
            <div style={{ display: 'flex', justifyContent: 'center', gap: '8px', marginTop: '20px' }}>
              <button
                className="btn btn-secondary"
                onClick={() => setPage(Math.max(1, page - 1))}
                disabled={page === 1}
              >
                Previous
              </button>
              <span style={{ padding: '10px 20px', display: 'flex', alignItems: 'center' }}>
                Page {page} of {totalPages}
              </span>
              <button
                className="btn btn-secondary"
                onClick={() => setPage(Math.min(totalPages, page + 1))}
                disabled={page === totalPages}
              >
                Next
              </button>
            </div>
          )}
        </>
      )}
    </div>
  );
};

export default Users;
