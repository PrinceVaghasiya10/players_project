import React, { useState } from 'react';

export default function Filters({ onApply }) {
  const [search, setSearch] = useState('');
  const [gender, setGender] = useState('');
  const [health, setHealth] = useState('');
  const [medical, setMedical] = useState('');

  function buildQSFromState() {
    const params = new URLSearchParams();
    const trimmed = String(search).trim();
    if (/^\d+$/.test(trimmed)) params.set('id', trimmed);
    else if (trimmed) params.set('q', trimmed);
    if (gender) params.set('gender', gender);
    if (health) params.set('health_status', health);
    if (medical) params.set('medical_clearance', medical);
    return params.toString();
  }

  function buildQSForSearchOnly() {
    const params = new URLSearchParams();
    const trimmed = String(search).trim();
    if (/^\d+$/.test(trimmed)) params.set('id', trimmed);
    else if (trimmed) params.set('q', trimmed);
    return params.toString();
  }

  function handleApplyFilters() {
    onApply(buildQSFromState());
  }

  function handleClear() {
    setSearch('');
    setGender('');
    setHealth('');
    setMedical('');
    onApply('');
  }

  function handleSearch() {
    // search uses only the search input (ID or name), not filters
    onApply(buildQSForSearchOnly());
  }

  function handleListAll() {
    setSearch('');
    setGender('');
    setHealth('');
    setMedical('');
    onApply('');
  }

  // allow Enter inside search input to trigger Search
  function onSearchKeyDown(e) {
    if (e.key === 'Enter') {
      e.preventDefault();
      handleSearch();
    }
  }

  return (
    <div className="bg-gradient-to-r from-slate-900 via-slate-800 to-slate-900 p-4 rounded-xl shadow-lg text-white">
      <div className="flex flex-col md:flex-row gap-3 md:items-center md:justify-between">
        {/* left block: search input + search/list buttons + filters */}
        <div className="flex flex-col sm:flex-row gap-3 items-start sm:items-center flex-1">
          <div className="flex items-center gap-2 w-full sm:w-auto">
            <input
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              onKeyDown={onSearchKeyDown}
              placeholder="Search name or exact ID"
              className="w-full md:w-64 px-3 py-2 rounded-md bg-slate-700 border border-slate-600 placeholder-slate-400 text-slate-100"
            />

            <button
              onClick={handleSearch}
              className="px-3 py-2 bg-cyan-500 hover:bg-cyan-600 rounded-md font-medium text-slate-900"
              aria-label="Search"
            >
              Search
            </button>

            <button
              onClick={handleListAll}
              className="px-3 py-2 bg-slate-600 hover:bg-slate-700 rounded-md font-medium text-white"
              aria-label="List all players"
            >
              List All
            </button>
          </div>

          {/* filters (kept inline with search on wide screens) */}
          <div className="flex gap-3 flex-wrap mt-2 sm:mt-0">
            <select
              value={gender}
              onChange={(e) => setGender(e.target.value)}
              className="px-3 py-2 rounded-md bg-slate-700 border border-slate-600 text-slate-100"
            >
              <option value="">All Genders</option>
              <option value="M">Male (M)</option>
              <option value="F">Female (F)</option>
              <option value="O">Other (O)</option>
            </select>

            <select
              value={health}
              onChange={(e) => setHealth(e.target.value)}
              className="px-3 py-2 rounded-md bg-slate-700 border border-slate-600 text-slate-100"
            >
              <option value="">All Health</option>
              <option value="Fit">Fit</option>
              <option value="Recovering">Recovering</option>
              <option value="Injured">Injured</option>
            </select>

            <select
              value={medical}
              onChange={(e) => setMedical(e.target.value)}
              className="px-3 py-2 rounded-md bg-slate-700 border border-slate-600 text-slate-100"
            >
              <option value="">All Medical</option>
              <option value="true">Yes</option>
              <option value="false">No</option>
            </select>
          </div>
        </div>

        {/* right block: Apply / Clear buttons */}
        <div className="flex gap-2">
          <button
            onClick={handleApplyFilters}
            className="px-4 py-2 bg-cyan-500 hover:bg-cyan-600 rounded-md font-medium text-slate-900"
          >
            Apply Filters
          </button>
          <button
            onClick={handleClear}
            className="px-4 py-2 bg-amber-500 hover:bg-amber-600 rounded-md font-medium text-slate-900"
          >
            Clear
          </button>
        </div>
      </div>
    </div>
  );
}
