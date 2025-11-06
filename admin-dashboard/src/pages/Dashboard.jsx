import { useEffect, useState } from 'react';
import { getStatistics, getRevenueChart } from '../services/api';
import StatCard from '../components/StatCard';
import { Users, DollarSign, TrendingUp, Bell, UserCheck, Activity } from 'lucide-react';
import { Line } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend
} from 'chart.js';

ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Legend);

const Dashboard = () => {
  const [stats, setStats] = useState(null);
  const [revenueData, setRevenueData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    loadDashboardData();
  }, []);

  const loadDashboardData = async () => {
    try {
      const [statsData, revenueChartData] = await Promise.all([
        getStatistics(),
        getRevenueChart()
      ]);

      setStats(statsData);
      setRevenueData(revenueChartData);
      setLoading(false);
    } catch (err) {
      setError('Failed to load dashboard data');
      setLoading(false);
    }
  };

  if (loading) {
    return <div className="loading">Loading dashboard...</div>;
  }

  if (error) {
    return <div className="error">{error}</div>;
  }

  const chartData = {
    labels: revenueData?.map(d => d.date) || [],
    datasets: [
      {
        label: 'Revenue (₹)',
        data: revenueData?.map(d => d.revenue) || [],
        borderColor: '#7c3aed',
        backgroundColor: 'rgba(124, 58, 237, 0.1)',
        tension: 0.4
      }
    ]
  };

  const chartOptions = {
    responsive: true,
    plugins: {
      legend: {
        display: true
      },
      title: {
        display: true,
        text: 'Revenue Trend (Last 30 Days)'
      }
    }
  };

  return (
    <div>
      <h1 style={{ fontSize: '32px', fontWeight: 'bold', marginBottom: '24px' }}>
        Dashboard
      </h1>

      {/* Stats Grid */}
      <div className="grid grid-4" style={{ marginBottom: '24px' }}>
        <StatCard
          icon={Users}
          label="Total Users"
          value={stats.totalUsers?.toLocaleString()}
          trend={`+${stats.newToday} today`}
          color="#3b82f6"
        />
        <StatCard
          icon={UserCheck}
          label="Premium Users"
          value={stats.premiumUsers?.toLocaleString()}
          trend={`${stats.conversionRate}% conversion`}
          color="#10b981"
        />
        <StatCard
          icon={DollarSign}
          label="Revenue Today"
          value={`₹${stats.revenueToday?.toLocaleString()}`}
          trend={`₹${stats.revenueThisMonth?.toLocaleString()} this month`}
          color="#f59e0b"
        />
        <StatCard
          icon={Activity}
          label="Active Subscriptions"
          value={stats.activeSubscriptions?.toLocaleString()}
          color="#8b5cf6"
        />
      </div>

      {/* Revenue Chart */}
      {revenueData && revenueData.length > 0 && (
        <div className="card">
          <h2 style={{ fontSize: '20px', fontWeight: 'bold', marginBottom: '16px' }}>
            Revenue Analytics
          </h2>
          <Line data={chartData} options={chartOptions} />
        </div>
      )}

      {/* Quick Stats */}
      <div className="grid grid-3" style={{ marginTop: '24px' }}>
        <div className="card">
          <h3 style={{ fontSize: '16px', fontWeight: 'bold', marginBottom: '12px' }}>
            Free Users
          </h3>
          <p style={{ fontSize: '28px', fontWeight: 'bold', color: '#7c3aed' }}>
            {stats.freeUsers?.toLocaleString()}
          </p>
        </div>
        <div className="card">
          <h3 style={{ fontSize: '16px', fontWeight: 'bold', marginBottom: '12px' }}>
            Total Revenue
          </h3>
          <p style={{ fontSize: '28px', fontWeight: 'bold', color: '#7c3aed' }}>
            ₹{stats.totalRevenue?.toLocaleString()}
          </p>
        </div>
        <div className="card">
          <h3 style={{ fontSize: '16px', fontWeight: 'bold', marginBottom: '12px' }}>
            Notifications Sent Today
          </h3>
          <p style={{ fontSize: '28px', fontWeight: 'bold', color: '#7c3aed' }}>
            {stats.notificationsToday?.toLocaleString()}
          </p>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
