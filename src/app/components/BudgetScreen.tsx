import { motion } from "motion/react";
import { ChevronDown, TrendingDown } from "lucide-react";

const categories = [
  { name: "Groceries", icon: "🛒", spent: 1200, total: 1500, color: "#1D9E75" },
  { name: "Dairy", icon: "🥛", spent: 480, total: 600, color: "#3B82F6" },
  { name: "Vegetables", icon: "🥦", spent: 660, total: 800, color: "#22C55E" },
  { name: "Household", icon: "🧴", spent: 0, total: 600, color: "#F59E0B" },
];

const transactions = [
  { item: "Basmati Rice (2kg)", by: "👩 Priya", price: 180, date: "Today, 10:30 AM", cat: "Groceries" },
  { item: "Toor Dal (500g)", by: "👩 Priya", price: 75, date: "Today, 10:28 AM", cat: "Groceries" },
  { item: "Milk (2L)", by: "👨 Dad", price: 96, date: "Yesterday, 8:15 AM", cat: "Dairy" },
  { item: "Tomatoes (1kg)", by: "👩 Priya", price: 35, date: "Yesterday, 9:00 AM", cat: "Vegetables" },
  { item: "Curd (500g)", by: "👩‍🦳 Mom", price: 45, date: "2 days ago", cat: "Dairy" },
  { item: "Bread (1 loaf)", by: "👨 Dad", price: 45, date: "2 days ago", cat: "Groceries" },
];

const spent = 2340;
const total = 3500;
const pct = spent / total;
const r = 80;
const circ = 2 * Math.PI * r;

export function BudgetScreen() {
  return (
    <div className="h-full bg-[#F7F8FA] flex flex-col">
      {/* Header */}
      <div className="bg-white px-5 pt-12 pb-4 shadow-sm">
        <div className="flex items-center justify-between">
          <h1 style={{ fontFamily: "Nunito", fontWeight: 800, fontSize: "22px", color: "#1A1A2E" }}>Budget</h1>
          <button className="flex items-center gap-1.5 px-3 py-1.5 bg-[#F7F8FA] rounded-xl border border-gray-100">
            <span className="text-sm text-[#1A1A2E]" style={{ fontFamily: "Plus Jakarta Sans", fontWeight: 500 }}>This Week</span>
            <ChevronDown size={14} className="text-[#6B7280]" />
          </button>
        </div>
        <p className="text-[#6B7280] text-sm mt-1" style={{ fontFamily: "Plus Jakarta Sans" }}>Family Room · Jun 1–7, 2026</p>
      </div>

      <div className="flex-1 overflow-y-auto pb-6">
        {/* Ring chart */}
        <div className="bg-white mx-5 mt-4 rounded-2xl p-5 shadow-sm">
          <div className="flex items-center gap-6">
            {/* SVG ring */}
            <div className="relative flex-shrink-0">
              <svg width="180" height="180" viewBox="0 0 180 180">
                {/* Background ring */}
                <circle cx="90" cy="90" r={r} fill="none" stroke="#F3F4F6" strokeWidth="20" />
                {/* Progress arc */}
                <motion.circle
                  cx="90" cy="90" r={r}
                  fill="none"
                  stroke="#1D9E75"
                  strokeWidth="20"
                  strokeLinecap="round"
                  strokeDasharray={circ}
                  initial={{ strokeDashoffset: circ }}
                  animate={{ strokeDashoffset: circ * (1 - pct) }}
                  transition={{ delay: 0.3, duration: 1, ease: "easeOut" }}
                  transform="rotate(-90 90 90)"
                />
              </svg>
              {/* Center text */}
              <div className="absolute inset-0 flex flex-col items-center justify-center">
                <span style={{ fontFamily: "Nunito", fontWeight: 900, fontSize: "22px", color: "#1A1A2E" }}>
                  ₹{spent.toLocaleString()}
                </span>
                <span className="text-xs text-[#6B7280]" style={{ fontFamily: "Plus Jakarta Sans" }}>of ₹{total.toLocaleString()}</span>
              </div>
            </div>

            {/* Stats */}
            <div className="flex-1">
              <div className="mb-4">
                <p className="text-[#6B7280] text-xs mb-1" style={{ fontFamily: "Plus Jakarta Sans" }}>Spent</p>
                <p style={{ fontFamily: "Nunito", fontWeight: 800, fontSize: "20px", color: "#1A1A2E" }}>₹{spent.toLocaleString()}</p>
              </div>
              <div className="mb-4">
                <p className="text-[#6B7280] text-xs mb-1" style={{ fontFamily: "Plus Jakarta Sans" }}>Remaining</p>
                <p style={{ fontFamily: "Nunito", fontWeight: 800, fontSize: "20px", color: "#1D9E75" }}>₹{(total - spent).toLocaleString()}</p>
              </div>
              <div className="flex items-center gap-1.5 px-3 py-2 bg-green-50 rounded-xl">
                <TrendingDown size={14} className="text-green-500" />
                <span className="text-xs text-green-600 font-medium" style={{ fontFamily: "Plus Jakarta Sans" }}>12% less vs last week</span>
              </div>
            </div>
          </div>
        </div>

        {/* Category breakdown */}
        <div className="mx-5 mt-4">
          <h2 style={{ fontFamily: "Nunito", fontWeight: 700, fontSize: "16px", color: "#1A1A2E", marginBottom: 12 }}>By Category</h2>
          <div className="flex flex-col gap-2.5">
            {categories.map((cat, i) => (
              <motion.div key={cat.name} initial={{ opacity: 0, x: -12 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.2 + i * 0.08 }}
                className="bg-white rounded-2xl px-4 py-3.5 shadow-sm">
                <div className="flex items-center gap-3 mb-2.5">
                  <div className="w-10 h-10 rounded-xl flex items-center justify-center text-xl flex-shrink-0"
                    style={{ background: cat.color + "20" }}>
                    {cat.icon}
                  </div>
                  <div className="flex-1">
                    <div className="flex justify-between items-center mb-0.5">
                      <span style={{ fontFamily: "Plus Jakarta Sans", fontWeight: 500, fontSize: "14px", color: "#1A1A2E" }}>{cat.name}</span>
                      <span style={{ fontFamily: "Nunito", fontWeight: 700, fontSize: "14px", color: "#1A1A2E" }}>
                        ₹{cat.spent} <span className="text-[#6B7280] font-normal">/ ₹{cat.total}</span>
                      </span>
                    </div>
                    <div className="h-2 bg-gray-100 rounded-full overflow-hidden">
                      <motion.div
                        initial={{ width: 0 }}
                        animate={{ width: `${(cat.spent / cat.total) * 100}%` }}
                        transition={{ delay: 0.4 + i * 0.1, duration: 0.6 }}
                        className="h-full rounded-full"
                        style={{ background: cat.color }}
                      />
                    </div>
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        </div>

        {/* Transactions */}
        <div className="mx-5 mt-5">
          <h2 style={{ fontFamily: "Nunito", fontWeight: 700, fontSize: "16px", color: "#1A1A2E", marginBottom: 12 }}>Recent Purchases</h2>
          <div className="flex flex-col gap-2">
            {transactions.map((tx, i) => (
              <div key={i} className="bg-white rounded-2xl px-4 py-3.5 shadow-sm flex items-center gap-3">
                <div className="w-9 h-9 rounded-full bg-[#E8F5E9] flex items-center justify-center text-lg flex-shrink-0">
                  {tx.by.split(" ")[0]}
                </div>
                <div className="flex-1 min-w-0">
                  <p style={{ fontFamily: "Plus Jakarta Sans", fontWeight: 500, fontSize: "13px", color: "#1A1A2E" }}>{tx.item}</p>
                  <p className="text-xs text-[#6B7280] mt-0.5" style={{ fontFamily: "Plus Jakarta Sans" }}>
                    {tx.by.split(" ").slice(1).join(" ")} · {tx.date}
                  </p>
                </div>
                <span style={{ fontFamily: "Nunito", fontWeight: 700, fontSize: "14px", color: "#1A1A2E" }}>₹{tx.price}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
