// src/pages/StatsPage.jsx
import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import API_BASE from '../api';

export default function StatsPage() {
  const { id } = useParams();
  const navigate = useNavigate();

  const [loading, setLoading] = useState(true);
  const [player, setPlayer] = useState(null);
  const [stats, setStats] = useState({
    total_matches: 0,
    total_wins: 0,
    total_losses: 0,
  });

  useEffect(() => {
    async function load() {
      try {
        setLoading(true);
        const res = await fetch(`${API_BASE}/players/${encodeURIComponent(id)}/stats`);
        if (!res.ok) {
          const err = await res.json().catch(() => ({ error: 'unknown' }));
          alert('Failed to load stats: ' + (err.error || JSON.stringify(err)));
          navigate('/');
          return;
        }
        const data = await res.json();
        setPlayer(data.player || { player_id: id, name: `Player ${id}` });
        setStats(data.stats || { total_matches: 0, total_wins: 0, total_losses: 0 });
      } catch (err) {
        console.error(err);
        alert('Network error while loading stats');
        navigate('/');
      } finally {
        setLoading(false);
      }
    }

    if (id) load();
  }, [id, navigate]);

  if (loading) {
    return <div className="mt-8 text-slate-300">Loading stats...</div>;
  }

  const { total_matches = 0, total_wins = 0, total_losses = 0 } = stats;
  const winRate = total_matches ? (Number(total_wins) / Number(total_matches)) * 100 : 0;
  const displayWinRate = Number.isFinite(winRate) ? `${winRate.toFixed(2)}%` : '—';

  return (
    <div className="mt-8 max-w-4xl">
      {/* Title */}
      <h1 className="text-3xl md:text-4xl font-extrabold text-slate-100 mb-6">
        Stats — {player?.name || `Player ${id}`}
      </h1>

      {/* Outer card */}
      <div className="bg-slate-900/70 p-8 rounded-2xl shadow-2xl">
        <div className="text-slate-300 mb-6">
          Player ID: <span className="font-medium text-slate-100">{player?.player_id ?? id}</span>
        </div>

        {/* Grid styled like Add/Update Player */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {/* Each stat "input box" */}
          <div>
            <label className="block text-slate-300 mb-1">Total Matches</label>
            <div className="w-full px-4 py-3 rounded-lg bg-slate-800 border border-slate-700 text-white font-medium">
              {total_matches}
            </div>
          </div>

          <div>
            <label className="block text-slate-300 mb-1">Total Wins</label>
            <div className="w-full px-4 py-3 rounded-lg bg-slate-800 border border-slate-700 text-white font-medium">
              {total_wins}
            </div>
          </div>

          <div>
            <label className="block text-slate-300 mb-1">Total Losses</label>
            <div className="w-full px-4 py-3 rounded-lg bg-slate-800 border border-slate-700 text-white font-medium">
              {total_losses}
            </div>
          </div>

          <div>
            <label className="block text-slate-300 mb-1">Win Rate</label>
            <div className="w-full px-4 py-3 rounded-lg bg-slate-800 border border-slate-700 text-emerald-400 font-semibold">
              {displayWinRate}
            </div>
          </div>
        </div>

        {/* Buttons */}
        <div className="mt-6 flex gap-3">
          <button
            onClick={() => navigate(-1)}
            className="px-5 py-2 bg-slate-700 text-slate-200 rounded-lg hover:bg-slate-600 shadow"
          >
            Back
          </button>
        </div>
      </div>
    </div>
  );
}
