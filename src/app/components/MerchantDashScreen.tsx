import { useState } from "react";
import { motion } from "motion/react";
import { TrendingUp, Eye, ShoppingCart, Users, ChevronRight, Plus } from "lucide-react";
import { useTheme } from "../context/ThemeContext";

const demandItems = [
  { item: "Rice", count: 143, trend: "+12%" },
  { item: "Toor Dal", count: 98, trend: "+5%" },
  { item: "Tomatoes", count: 87, trend: "+23%" },
  { item: "Milk", count: 76, trend: "-3%" },
];

const activeOffers = [
  { id: 1, title: "15% off Rice & Pulses", views: 248, claims: 34, revenue: "₹4,200" },
  { id: 2, title: "10% off Cooking Oils", views: 115, claims: 18, revenue: "₹1,800" },
  { id: 3, title: "Onions at ₹25/kg", views: 89, claims: 42, revenue: "₹1,050" },
];

export function MerchantDashScreen() {
  const { theme } = useTheme();
  const dark = theme === "dark";
  const [discount, setDiscount] = useState("10");
  const [item, setItem] = useState("");
  const [radius, setRadius] = useState(1);

  return (
    <div className={`h-full flex flex-col ${dark ? "bg-[#0f0f1a]" : "bg-[#F7F8FA]"}`}>
      <div className={`px-5 pt-12 pb-4 shadow-sm ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
        <div className="flex items-center gap-3 mb-1">
          <div className="w-10 h-10 rounded-xl bg-[#1D9E75] flex items-center justify-center text-xl">🛒</div>
          <div>
            <h1 style={{ fontFamily: "Nunito", fontWeight: 800, fontSize: "18px", color: dark ? "#ffffff" : "#1A1A2E" }}>FreshMart Dashboard</h1>
            <p className={`text-xs ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>Velachery · Today, 7 Jun</p>
          </div>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto pb-24 px-5">
        <div className="flex gap-3 mt-4 mb-4">
          {[
            { label: "Views Today", val: "248", icon: <Eye size={16} className="text-[#1D9E75]" />, bg: "#E8F5E9", change: "+18%" },
            { label: "Claims", val: "94", icon: <ShoppingCart size={16} className="text-[#FF6B35]" />, bg: "#FFF0EB", change: "+7%" },
            { label: "New Customers", val: "12", icon: <Users size={16} className="text-blue-500" />, bg: "#EFF6FF", change: "+4" },
          ].map((stat, i) => (
            <motion.div key={i} initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.08 }}
              className={`flex-1 rounded-2xl p-3.5 shadow-sm ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
              <div className="w-9 h-9 rounded-xl flex items-center justify-center mb-2" style={{ background: stat.bg }}>{stat.icon}</div>
              <p style={{ fontFamily: "Nunito", fontWeight: 800, fontSize: "20px", color: dark ? "#ffffff" : "#1A1A2E" }}>{stat.val}</p>
              <p className={`text-xs mt-0.5 ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>{stat.label}</p>
              <p className="text-[#1D9E75] text-xs font-medium mt-1" style={{ fontFamily: "Plus Jakarta Sans" }}>{stat.change}</p>
            </motion.div>
          ))}
        </div>

        <div className={`rounded-2xl p-4 shadow-sm mb-4 ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
          <div className="flex items-center justify-between mb-3">
            <div>
              <p style={{ fontFamily: "Nunito", fontWeight: 700, fontSize: "15px", color: dark ? "#ffffff" : "#1A1A2E" }}>🔥 Demand Near You</p>
              <p className={`text-xs ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>What customers are looking for within 2km</p>
            </div>
          </div>
          <div className="flex flex-col gap-2">
            {demandItems.map((d, i) => (
              <div key={d.item} className="flex items-center gap-3">
                <div className="w-6 text-center">
                  <span className={`text-xs font-medium ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Nunito" }}>#{i + 1}</span>
                </div>
                <div className="flex-1">
                  <div className="flex justify-between items-center mb-1">
                    <span style={{ fontFamily: "Plus Jakarta Sans", fontWeight: 500, fontSize: "13px", color: dark ? "#ffffff" : "#1A1A2E" }}>{d.item}</span>
                    <div className="flex items-center gap-2">
                      <span className={`text-xs ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>{d.count} people</span>
                      <span className={`text-xs font-medium ${d.trend.startsWith("+") ? "text-green-500" : "text-red-400"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>{d.trend}</span>
                    </div>
                  </div>
                  <div className={`h-2 rounded-full overflow-hidden ${dark ? "bg-white/10" : "bg-gray-100"}`}>
                    <motion.div initial={{ width: 0 }} animate={{ width: `${(d.count / 143) * 100}%` }} transition={{ delay: 0.3 + i * 0.1, duration: 0.6 }}
                      className="h-full rounded-full" style={{ background: i === 0 ? "#1D9E75" : i === 1 ? "#22C55E" : i === 2 ? "#FF6B35" : "#3B82F6" }} />
                  </div>
                </div>
              </div>
            ))}
          </div>
          <motion.button whileTap={{ scale: 0.97 }}
            className="w-full mt-4 py-3 rounded-xl flex items-center justify-center gap-2 font-bold text-sm"
            style={{ background: "#E8F5E9", color: "#1D9E75", fontFamily: "Nunito" }}>
            <Plus size={16} />Post an Offer for Rice →
          </motion.button>
        </div>

        <div className={`rounded-2xl p-4 shadow-sm mb-4 ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
          <p style={{ fontFamily: "Nunito", fontWeight: 700, fontSize: "15px", color: dark ? "#ffffff" : "#1A1A2E", marginBottom: 12 }}>Quick Post Offer</p>
          <div className="flex flex-col gap-3">
            <input value={item} onChange={e => setItem(e.target.value)} placeholder="Item name (e.g. Basmati Rice)"
              className={`w-full px-4 py-3 rounded-xl border outline-none text-sm transition-colors placeholder:text-gray-400 focus:border-[#1D9E75] ${dark ? "bg-[#0f0f1a] border-white/10 text-white" : "bg-[#F7F8FA] border-gray-100 text-[#1A1A2E]"}`}
              style={{ fontFamily: "Plus Jakarta Sans" }} />
            <div className="flex gap-3">
              <div className="flex-1">
                <label className={`text-xs mb-1 block ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>Discount %</label>
                <input value={discount} onChange={e => setDiscount(e.target.value)} type="number"
                  className={`w-full px-4 py-3 rounded-xl border outline-none text-sm transition-colors focus:border-[#1D9E75] ${dark ? "bg-[#0f0f1a] border-white/10 text-white" : "bg-[#F7F8FA] border-gray-100 text-[#1A1A2E]"}`}
                  style={{ fontFamily: "Plus Jakarta Sans" }} />
              </div>
              <div className="flex-1">
                <label className={`text-xs mb-1 block ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>Valid for</label>
                <select className={`w-full px-4 py-3 rounded-xl border outline-none text-sm transition-colors focus:border-[#1D9E75] ${dark ? "bg-[#0f0f1a] border-white/10 text-white" : "bg-[#F7F8FA] border-gray-100 text-[#1A1A2E]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>
                  <option>Today</option>
                  <option>2 days</option>
                  <option>1 week</option>
                </select>
              </div>
            </div>
            <div>
              <div className="flex justify-between mb-1">
                <label className={`text-xs ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>Reach radius</label>
                <span className="text-xs text-[#1D9E75] font-medium" style={{ fontFamily: "Plus Jakarta Sans" }}>{radius} km</span>
              </div>
              <input type="range" min={0.5} max={5} step={0.5} value={radius} onChange={e => setRadius(Number(e.target.value))} className="w-full accent-[#1D9E75]" />
              <div className={`flex justify-between text-xs mt-0.5 ${dark ? "text-gray-500" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>
                <span>0.5 km</span><span>5 km</span>
              </div>
            </div>
            <motion.button whileTap={{ scale: 0.97 }} className="w-full py-3.5 rounded-xl text-white font-bold text-sm" style={{ background: "#1D9E75", fontFamily: "Nunito" }}>Post Offer Now</motion.button>
          </div>
        </div>

        <div className="mb-4">
          <p style={{ fontFamily: "Nunito", fontWeight: 700, fontSize: "16px", color: dark ? "#ffffff" : "#1A1A2E", marginBottom: 12 }}>Active Offers</p>
          <div className="flex flex-col gap-2.5">
            {activeOffers.map(offer => (
              <div key={offer.id} className={`rounded-2xl p-4 shadow-sm ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
                <div className="flex items-center justify-between mb-3">
                  <p style={{ fontFamily: "Plus Jakarta Sans", fontWeight: 500, fontSize: "14px", color: dark ? "#ffffff" : "#1A1A2E" }}>{offer.title}</p>
                  <ChevronRight size={16} className={dark ? "text-white/20" : "text-gray-300"} />
                </div>
                <div className="flex gap-4">
                  <div className="flex items-center gap-1.5">
                    <Eye size={13} className={dark ? "text-gray-400" : "text-[#6B7280]"} />
                    <span className={`text-sm font-medium ${dark ? "text-white" : "text-[#1A1A2E]"}`} style={{ fontFamily: "Nunito" }}>{offer.views}</span>
                    <span className={`text-xs ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>views</span>
                  </div>
                  <div className="flex items-center gap-1.5">
                    <ShoppingCart size={13} className="text-[#1D9E75]" />
                    <span className="text-sm font-medium text-[#1D9E75]" style={{ fontFamily: "Nunito" }}>{offer.claims}</span>
                    <span className={`text-xs ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>claims</span>
                  </div>
                  <div className="flex items-center gap-1.5">
                    <TrendingUp size={13} className="text-[#FF6B35]" />
                    <span className="text-sm font-medium text-[#FF6B35]" style={{ fontFamily: "Nunito" }}>{offer.revenue}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
