import { useState } from 'react';
import API_BASE from '../api';

export default function useFetchPlayers() {
  const [players, setPlayers] = useState([]);
  const [loading, setLoading] = useState(false);
  const [status, setStatus] = useState('');

  const fetchPlayers = async (queryParams = '') => {
    setLoading(true);
    setStatus('Loading...');
    try {
      const url = queryParams ? `${API_BASE}/players?${queryParams}` : `${API_BASE}/players`;
      console.debug('[API] GET', url);
      const res = await fetch(url);
      if (!res.ok) {
        const txt = await res.text().catch(() => res.statusText);
        setStatus(`Error ${res.status}: ${txt}`);
        setPlayers([]);
      } else {
        const data = await res.json();
        const rows = Array.isArray(data) ? data : (data ? [data] : []);
        setPlayers(rows);
        setStatus(`Showing ${rows.length} result(s)`);
      }
    } catch (e) {
      console.error(e);
      setStatus('Network error');
      setPlayers([]);
    } finally {
      setLoading(false);
    }
  };

  return { players, loading, status, fetchPlayers, setPlayers };
}
