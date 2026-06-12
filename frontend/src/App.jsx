// src/App.jsx
import React from 'react';
import { Routes, Route } from 'react-router-dom';
import Header from './components/Header';
import Dashboard from './pages/Dashboard';
import AddPlayer from './pages/AddPlayer';
import UpdatePlayer from './pages/UpdatePlayer';
import StatsPage from './pages/StatsPage';

export default function App() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-slate-900 via-slate-800 to-slate-900 text-slate-100 p-6">
      <div className="max-w-6xl mx-auto">
        <Header />
        <main className="mt-6">
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/add" element={<AddPlayer />} />

            {/* support the generic update page (enter ID) */}
            <Route path="/update" element={<UpdatePlayer />} />

            {/* also support direct id route from table links */}
            <Route path="/update/:id" element={<UpdatePlayer />} />

            <Route path="/stats/:id" element={<StatsPage />} />
            <Route path="*" element={<div className="mt-6 text-center text-slate-300">Page not found</div>} />
          </Routes>
        </main>
      </div>
    </div>
  );
}
