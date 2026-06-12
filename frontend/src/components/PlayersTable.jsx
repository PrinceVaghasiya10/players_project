import React from 'react';
import { useNavigate } from 'react-router-dom';
import { Link } from 'react-router-dom';


export default function PlayersTable({ players, onDelete }) {
  const navigate = useNavigate();
  return (
    <div className="mt-6 overflow-hidden rounded-xl border border-slate-200 bg-white/60 backdrop-blur">
      <table className="min-w-full divide-y divide-slate-200">
        <thead className="bg-gradient-to-r from-cyan-600 to-sky-600 text-white">
          <tr>
            <th className="px-4 py-3 text-left">ID</th>
            <th className="px-4 py-3 text-left">Name</th>
            <th className="px-4 py-3 text-left">DOB</th>
            <th className="px-4 py-3 text-left">Gender</th>
            <th className="px-4 py-3 text-left">Health</th>
            <th className="px-4 py-3 text-left">Medical</th>
            <th className="px-4 py-3 text-left">Actions</th>
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-slate-100">
          {players.map((p) => (
            <tr key={p.player_id} className="hover:bg-slate-50">
              <td className="px-4 py-3">{p.player_id}</td>
              <td className="px-4 py-3 font-medium">{p.name}</td>
              <td className="px-4 py-3">{p.date_of_birth ? new Date(p.date_of_birth).toISOString().slice(0,10) : ''}</td>
              <td className="px-4 py-3">{p.gender}</td>
              <td className="px-4 py-3">{p.health_status}</td>
              <td className="px-4 py-3">{p.medical_clearance ? 'Yes' : 'No'}</td>
              <td className="px-4 py-3 flex gap-2">
                <button onClick={() => navigate(`/stats/${p.player_id}`)} className="px-3 py-1 rounded-md bg-sky-500 text-white">Stats</button>
                <button onClick={() => navigate(`/update/${p.player_id}`)} className="px-3 py-1 rounded-md bg-emerald-500 text-white">Update</button>
                <button onClick={() => onDelete(p.player_id)} className="px-3 py-1 rounded-md bg-rose-500 text-white">Delete</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
