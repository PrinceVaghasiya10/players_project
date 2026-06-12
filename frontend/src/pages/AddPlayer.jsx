// src/pages/AddPlayer.jsx
import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import API_BASE from '../api';

export default function AddPlayer() {
  const navigate = useNavigate();
  const [form, setForm] = useState({
    Player_ID: '',
    Name: '',
    Date_of_Birth: '',
    Gender: 'M',
    Health_Status: 'Fit',
    Medical_Clearance: true
  });
  const [busy, setBusy] = useState(false);

  function setField(k, v) {
    setForm(prev => ({ ...prev, [k]: v }));
  }

  const submit = async (e) => {
    e.preventDefault();
    // basic validation
    if (!form.Player_ID || !/^\d+$/.test(String(form.Player_ID).trim())) {
      alert('Please enter a numeric Player ID.');
      return;
    }
    if (!form.Name || !form.Name.trim()) {
      alert('Please enter Name.');
      return;
    }
    if (!form.Date_of_Birth) {
      alert('Please select Date of Birth.');
      return;
    }

    const payload = {
      Player_ID: parseInt(form.Player_ID, 10),
      Name: form.Name.trim(),
      Date_of_Birth: form.Date_of_Birth,
      Gender: form.Gender,
      Health_Status: form.Health_Status,
      Medical_Clearance: !!form.Medical_Clearance
    };

    setBusy(true);
    try {
      const res = await fetch(`${API_BASE}/players`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      if (!res.ok) {
        const err = await res.json().catch(()=>({ error: 'Server error' }));
        alert('Save failed: ' + (err.error || JSON.stringify(err)));
        setBusy(false);
        return;
      }
      alert('Player added successfully.');
      navigate('/');
    } catch (err) {
      console.error(err);
      alert('Network error while saving player.');
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="mt-8 max-w-3xl mx-auto">
      <h2 className="text-2xl font-semibold text-white mb-4">Add Player</h2>

      <form onSubmit={submit} className="bg-slate-900/70 p-6 rounded-xl shadow-md">
        <div className="mb-4 text-slate-300">Fill player details and click <strong>Save</strong>.</div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <input
            type="text"
            placeholder="Player ID"
            value={form.Player_ID}
            onChange={(e) => setField('Player_ID', e.target.value)}
            className="px-4 py-3 rounded-md bg-slate-800 border border-slate-700 text-slate-100"
          />

          <input
            type="text"
            placeholder="Name"
            value={form.Name}
            onChange={(e) => setField('Name', e.target.value)}
            className="px-4 py-3 rounded-md bg-slate-800 border border-slate-700 text-slate-100"
          />

          <input
            type="date"
            placeholder="dd-mm-yyyy"
            value={form.Date_of_Birth}
            onChange={(e) => setField('Date_of_Birth', e.target.value)}
            className="px-4 py-3 rounded-md bg-slate-800 border border-slate-700 text-slate-100"
          />

          <select
            value={form.Gender}
            onChange={(e) => setField('Gender', e.target.value)}
            className="px-4 py-3 rounded-md bg-slate-800 border border-slate-700 text-slate-100"
          >
            <option value="M">M</option>
            <option value="F">F</option>
            <option value="O">O</option>
          </select>

          <select
            value={form.Health_Status}
            onChange={(e) => setField('Health_Status', e.target.value)}
            className="px-4 py-3 rounded-md bg-slate-800 border border-slate-700 text-slate-100"
          >
            <option value="Fit">Fit</option>
            <option value="Recovering">Recovering</option>
            <option value="Injured">Injured</option>
          </select>

          <select
            value={String(form.Medical_Clearance)}
            onChange={(e) => setField('Medical_Clearance', e.target.value === 'true')}
            className="px-4 py-3 rounded-md bg-slate-800 border border-slate-700 text-slate-100"
          >
            <option value="true">true</option>
            <option value="false">false</option>
          </select>
        </div>

        <div className="mt-6 flex items-center gap-3">
          <button
            type="submit"
            disabled={busy}
            className={`px-5 py-2 rounded-md font-medium ${busy ? 'bg-slate-500 text-slate-200' : 'bg-emerald-500 text-slate-900 hover:bg-emerald-600'}`}
          >
            {busy ? 'Saving...' : 'Save'}
          </button>

          <button
            type="button"
            onClick={() => navigate('/')}
            className="px-4 py-2 rounded-md bg-slate-700 text-slate-200"
          >
            Cancel
          </button>
        </div>
      </form>
    </div>
  );
}
