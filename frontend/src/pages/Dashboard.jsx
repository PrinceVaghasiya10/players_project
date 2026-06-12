import React, { useEffect } from 'react';
import Filters from '../components/Filters';
import PlayersTable from '../components/PlayersTable';
import useFetchPlayers from '../hooks/useFetchPlayers';

export default function Dashboard() {
  const { players, loading, status, fetchPlayers, setPlayers } = useFetchPlayers();

  useEffect(() => { fetchPlayers(); }, []); // initial load

  const handleApply = (qs) => fetchPlayers(qs);

  const handleDelete = async (id) => {
    if (!confirm(`Delete player ${id}?`)) return;
    try {
      const res = await fetch(`${process.env.REACT_APP_API_URL || 'http://localhost:4000'}/players/${encodeURIComponent(id)}`, { method: 'DELETE' });
      if (!res.ok) { const err = await res.json().catch(()=>({error:'error'})); alert('Delete failed: '+(err.error||JSON.stringify(err))); return; }
      setPlayers(players.filter(p => p.player_id !== id));
    } catch (e) { console.error(e); alert('Network error'); }
  };

  return (
    <div>
      <Filters onApply={handleApply} />
      <div className="mt-4 flex items-center justify-between">
        <div className="text-sm text-slate-500">{loading ? 'Loading players...' : status}</div>
        <div className="text-sm text-slate-400">API: {process.env.REACT_APP_API_URL || 'http://localhost:4000'}</div>
      </div>
      <PlayersTable players={players} onDelete={handleDelete} />
    </div>
  );
}
