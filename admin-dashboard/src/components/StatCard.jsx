const StatCard = ({ icon: Icon, label, value, trend, color = '#7c3aed' }) => {
  return (
    <div className="card" style={{
      background: 'white',
      borderRadius: '12px',
      padding: '24px',
      display: 'flex',
      flexDirection: 'column',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', marginBottom: '16px' }}>
        <div style={{
          width: '48px',
          height: '48px',
          borderRadius: '12px',
          backgroundColor: `${color}20`,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          marginRight: '16px'
        }}>
          <Icon size={24} color={color} />
        </div>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: '14px', color: '#6b7280', marginBottom: '4px' }}>
            {label}
          </div>
          <div style={{ fontSize: '28px', fontWeight: 'bold', color: '#111827' }}>
            {value}
          </div>
        </div>
      </div>
      {trend && (
        <div style={{ fontSize: '14px', color: trend.startsWith('+') ? '#10b981' : '#ef4444' }}>
          {trend}
        </div>
      )}
    </div>
  );
};

export default StatCard;
