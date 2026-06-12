// src/components/UpdatePlayer.jsx
import React, { useEffect, useState } from 'react';
import { useNavigate, useParams, useSearchParams } from 'react-router-dom';
import API_BASE from '../api';

export default function UpdatePlayer() {
  const { id: paramId } = useParams();
  const [searchParams] = useSearchParams();
  const queryId = searchParams.get('id');

  const navigate = useNavigate();

  // state
  const [idInput, setIdInput] = useState(paramId || queryId || '');
  const [loading, setLoading] = useState(false);
  const [player, setPlayer] = useState(null);
  const [form, setForm] = useState({
    Name: '',
    Date_of_Birth: '',
    Gender: 'M',
    Health_Status: 'Fit',
    Medical_Clearance: true
  });
  const [error, setError] = useState('');
  const [saving, setSaving] = useState(false);

  // auto-load when route has id param or query id
  useEffect(() => {
    const idToLoad = paramId || queryId;
    if (idToLoad) {
      setIdInput(String(idToLoad));
      fetchPlayer(idToLoad);
    } else {
      // if no id param, ensure we don't show "loading" placeholder
      setPlayer(null);
      setLoading(false);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [paramId, queryId]);

  async function fetchPlayer(id) {
    setError('');
    setLoading(true);
    setPlayer(null);
    try {
      const res = await fetch(`${API_BASE}/players?id=${encodeURIComponent(id)}`);
      if (!res.ok) throw new Error(`Fetch failed (${res.status})`);
      const data = await res.json();
      const p = Array.isArray(data) ? data[0] : data;
      if (!p) {
        setError('Player not found');
        setLoading(false);
        return;
      }
      setPlayer(p);
      setForm({
        Name: p.name ?? p.Name ?? '',
        Date_of_Birth: (p.date_of_birth ?? p.Date_of_Birth ?? '')?.slice(0,10) || '',
        Gender: p.gender ?? p.Gender ?? 'M',
        Health_Status: p.health_status ?? p.Health_Status ?? 'Fit',
        Medical_Clearance: !!(p.medical_clearance ?? p.Medical_Clearance)
      });
    } catch (err) {
      console.error(err);
      setError(String(err.message || err));
    } finally {
      setLoading(false);
    }
  }

  function onChange(e) {
    const { name, value, type } = e.target;
    if (type === 'checkbox') {
      setForm(f => ({ ...f, [name]: e.target.checked }));
    } else {
      setForm(f => ({ ...f, [name]: value }));
    }
  }

  async function onLoadClick(e) {
    e.preventDefault();
    setError('');
    if (!idInput || !/^\d+$/.test(idInput)) { setError('Enter a valid numeric ID'); return; }
    await fetchPlayer(idInput);
    // update URL to include id (keeps history)
    navigate(`/update/${encodeURIComponent(idInput)}`, { replace: true });
  }

  async function onSave(e) {
    e.preventDefault();
    if (!player && !idInput) { setError('No player loaded'); return; }
    setSaving(true);
    setError('');
    try {
      const payload = {
        Name: form.Name,
        Date_of_Birth: form.Date_of_Birth,
        Gender: form.Gender,
        Health_Status: form.Health_Status,
        Medical_Clearance: !!form.Medical_Clearance
      };
      const pid = player ? (player.player_id ?? player.Player_ID) : idInput;
      const res = await fetch(`${API_BASE}/players/${encodeURIComponent(pid)}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      if (!res.ok) {
        const ebody = await res.json().catch(()=>null);
        throw new Error(ebody?.error || ebody?.detail || `Update failed (${res.status})`);
      }
      alert('Player updated successfully');
      navigate('/'); // back to dashboard/list
    } catch (err) {
      console.error(err);
      setError(String(err.message || err));
    } finally {
      setSaving(false);
    }
  }

  // If no id loaded and not loading, show small ID-entry UI
  return (
    <div className="max-w-3xl mx-auto p-4">
      <h2 className="text-2xl font-semibold mb-4 text-white">Update Player</h2>

      {/* ID loader */}
      {!player && !loading && (
        <form onSubmit={onLoadClick} className="mb-6 flex gap-2 items-center">
          <input
            value={idInput}
            onChange={e => setIdInput(e.target.value)}
            placeholder="Enter numeric Player ID (e.g. 369)"
            className="px-4 py-2 rounded-md bg-slate-800 text-white border border-slate-700"
          />
          <button className="px-4 py-2 rounded-md bg-cyan-500 hover:bg-cyan-600" type="submit">Load Player</button>
          <button type="button" onClick={() => { setIdInput(''); setError(''); navigate('/update'); }} className="px-3 py-2 rounded-md bg-gray-600">Reset</button>
        </form>
      )}

      {loading && <div className="text-slate-300 mb-4">Loading player...</div>}
      {error && <div className="text-rose-400 mb-4">{error}</div>}

      {/* Edit form */}
      {player && (
        <form onSubmit={onSave} className="bg-slate-900 p-6 rounded-md shadow">
          <div className="mb-3 text-slate-300">Editing Player ID: <strong className="text-white">{player.player_id ?? player.Player_ID}</strong></div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm text-slate-300">Name</label>
              <input name="Name" value={form.Name} onChange={onChange} className="w-full mt-1 px-3 py-2 rounded-md bg-slate-800 text-white border border-slate-700" />
            </div>

            <div>
              <label className="block text-sm text-slate-300">Date of Birth</label>
              <input name="Date_of_Birth" type="date" value={form.Date_of_Birth || ''} onChange={onChange} className="w-full mt-1 px-3 py-2 rounded-md bg-slate-800 text-white border border-slate-700" />
            </div>

            <div>
              <label className="block text-sm text-slate-300">Gender</label>
              <select name="Gender" value={form.Gender} onChange={onChange} className="w-full mt-1 px-3 py-2 rounded-md bg-slate-800 text-white border border-slate-700">
                <option value="M">M</option>
                <option value="F">F</option>
                <option value="O">O</option>
              </select>
            </div>

            <div>
              <label className="block text-sm text-slate-300">Health Status</label>
              <select name="Health_Status" value={form.Health_Status} onChange={onChange} className="w-full mt-1 px-3 py-2 rounded-md bg-slate-800 text-white border border-slate-700">
                <option value="Fit">Fit</option>
                <option value="Recovering">Recovering</option>
                <option value="Injured">Injured</option>
              </select>
            </div>

            <div>
              <label className="block text-sm text-slate-300">Medical Clearance</label>
              <select name="Medical_Clearance" value={String(form.Medical_Clearance)} onChange={(e)=>setForm(f=>({...f, Medical_Clearance: e.target.value === 'true'}))} className="w-full mt-1 px-3 py-2 rounded-md bg-slate-800 text-white border border-slate-700">
                <option value="true">true</option>
                <option value="false">false</option>
              </select>
            </div>
          </div>

          <div className="mt-4 flex gap-3">
            <button disabled={saving} className="px-4 py-2 rounded-md bg-emerald-500 hover:bg-emerald-600 text-white">{saving ? 'Saving...' : 'Update Player'}</button>
            <button type="button" onClick={() => navigate('/')} className="px-4 py-2 rounded-md bg-gray-600 text-white">Back</button>
          </div>
        </form>
      )}
    </div>
  );
}
