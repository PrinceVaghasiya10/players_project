// src/components/Header.jsx
import React from "react";
import { Link } from "react-router-dom"; // if you use react-router
// If you don't use react-router, the <a> fallback is included below in comments.

export default function Header() {
  return (
    <header className="px-6 md:px-12 pt-8 pb-6">
      <div className="flex items-start justify-between gap-4">
        <div>
          <h1 className="text-3xl md:text-4xl font-extrabold text-white tracking-tight">
            Players Manager
          </h1>
        </div>

        <div className="flex items-center gap-3">
          {/* Update Player button (REPLACES "Dashboard") */}
          {/* If you're using react-router, use the Link below (uncomment) */}
          <Link
            to="/update"
            className="inline-flex items-center px-4 py-2 rounded-lg bg-emerald-500 hover:bg-emerald-600 text-slate-900 font-semibold shadow"
          >
            Update Player
          </Link>

          {/* If you're NOT using react-router, replace above Link with:
            <a href="/update" className="inline-flex items-center px-4 py-2 rounded-lg bg-emerald-500 hover:bg-emerald-600 text-slate-900 font-semibold shadow">Update Player</a>
          */}

          {/* Add Player button */}
          <Link
            to="/add"
            className="inline-flex items-center px-4 py-2 rounded-lg bg-green-400 hover:bg-green-500 text-slate-900 font-semibold shadow"
          >
            Add Player
          </Link>

          {/* If not using react-router, use:
            <a href="/add" className="inline-flex items-center px-4 py-2 rounded-lg bg-green-400 hover:bg-green-500 text-slate-900 font-semibold shadow">Add Player</a>
          */}
        </div>
      </div>
    </header>
  );
}
