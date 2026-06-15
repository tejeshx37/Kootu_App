import { useState } from "react";
import { motion } from "motion/react";
import { useOutletContext } from "react-router";
import { MapPin, Tag, Clock, ChevronRight, Zap } from "lucide-react";
import { type ListItem } from "./MainLayout";
import { useTheme } from "../context/ThemeContext";

const categories = ["All", "Groceries", "Vegetables", "Dairy", "Household"];
const distances = ["Any", "< 500m", "< 1km", "< 2km"];

const allOffers = [
  { id: 1, merchant: "FreshMart Velachery", logo: "🛒", distance: "2.0 km", headline: "15% off on Rice, Dal & Pulses", items: ["Basmati Rice", "Toor Dal"], savings: "₹85", expiry: "4h 23m", category: "Groceries", nearby: false, color: "#1D9E75" },
  { id: 2, merchant: "Velachery Veggie Hub", logo: "🥦", distance: "500 m", headline: "₹50 off on vegetables above ₹200", items: ["Tomatoes", "Capsicum", "Onions"], savings: "₹50", expiry: "2h 15m", category: "Vegetables", nearby: true, color: "#22C55E" },
  { id: 3, merchant: "Daily Needs Store", logo: "🏪", distance: "1.2 km", headline: "Buy 2 Get 1 on dairy products", items: ["Milk", "Curd", "Butter", "Paneer"], savings: "₹120", expiry: "8h", category: "Dairy", nearby: false, color: "#3B82F6" },
  { id: 4, merchant: "Raja Kirana & Co.", logo: "🫙", distance: "800 m", headline: "Flat 10% on all cooking oils", items: ["Sunflower Oil", "Coconut Oil"], savings: "₹45", expiry: "1d 2h", category: "Groceries", nearby: false, color: "#F59E0B" },
  { id: 5, merchant: "South Fresh Dairy", logo: "🥛", distance: "300 m", headline: "Fresh A2 milk — ₹5 off per litre", items: ["Milk", "A2 Milk", "Ghee"], savings: "₹15", expiry: "6h", category: "Dairy", nearby: true, color: "#8B5CF6" },
  { id: 6, merchant: "Spice World", logo: "🫙", distance: "1.5 km", headline: "20% off on all masalas & spices", items: ["Garam Masala", "Turmeric", "Chilli Powder"], savings: "₹60", expiry: "12h", category: "Groceries", nearby: false, color: "#7C3AED" },
  { id: 7, merchant: "CleanHome Supplies", logo: "🧹", distance: "900 m", headline: "Buy 3 household items, get 15% off", items: ["Vim Bar", "Detergent", "Floor Cleaner"], savings: "₹90", expiry: "2d", category: "Household", nearby: false, color: "#0891B2" },
  { id: 8, merchant: "NatureFresh Chicken", logo: "🍗", distance: "600 m", headline: "Fresh chicken ₹30/kg off today only", items: ["Chicken", "Mutton"], savings: "₹150", expiry: "5h", category: "Groceries", nearby: true, color: "#DC2626" },
];

interface OutletContext {
  onMerchantTap: () => void;
  selectedRoomId: number;
  listItemsByRoom: Record<number, ListItem[]>;
}

export function OffersScreen() {
  const { onMerchantTap, selectedRoomId, listItemsByRoom } = useOutletContext<OutletContext>();
  const { theme } = useTheme();
  const dark = theme === "dark";
  const [matchedOnly, setMatchedOnly] = useState(true);
  const [selCat, setSelCat] = useState("All");
  const [selDist, setSelDist] = useState("Any");

  const pendingNames = (listItemsByRoom[selectedRoomId] ?? []).filter(i => !i.bought).map(i => i.name.toLowerCase());

  const offersWithMatch = allOffers.map(offer => {
    const matchCount = offer.items.filter(offerItem =>
      pendingNames.some(pName => pName.includes(offerItem.toLowerCase()) || offerItem.toLowerCase().includes(pName))
    ).length;
    return { ...offer, match: matchCount, matched: matchCount > 0 };
  });

  const filtered = offersWithMatch.filter(o => {
    if (matchedOnly && !o.matched) return false;
    if (selCat !== "All" && o.category !== selCat) return false;
    if (selDist === "< 500m" && parseFloat(o.distance) > 0.5) return false;
    if (selDist === "< 1km" && parseFloat(o.distance) > 1) return false;
    if (selDist === "< 2km" && parseFloat(o.distance) > 2) return false;
    return true;
  });

  const sorted = [...filtered].sort((a, b) => {
    if (b.matched !== a.matched) return b.matched ? 1 : -1;
    return parseFloat(a.distance) - parseFloat(b.distance);
  });

  const roomItems = (listItemsByRoom[selectedRoomId] ?? []).filter(i => !i.bought);

  return (
    <div className={`h-full flex flex-col ${dark ? "bg-[#0f0f1a]" : "bg-[#F7F8FA]"}`}>
      <div className={`px-5 pt-12 pb-4 shadow-sm ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
        <div className="flex items-center justify-between mb-1">
          <h1 style={{ fontFamily: "Nunito", fontWeight: 800, fontSize: "22px", color: dark ? "#ffffff" : "#1A1A2E" }}>Offers</h1>
          <div className="flex items-center gap-2">
            <span className={`text-xs ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>Matched only</span>
            <button onClick={() => setMatchedOnly(!matchedOnly)} className="relative w-12 h-6 rounded-full transition-colors" style={{ background: matchedOnly ? "#1D9E75" : dark ? "#374151" : "#e5e7eb" }}>
              <motion.div animate={{ x: matchedOnly ? 24 : 2 }} className="absolute top-1 w-4 h-4 bg-white rounded-full shadow" />
            </button>
          </div>
        </div>

        {roomItems.length > 0 && (
          <p className={`text-xs mb-3 ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>
            Matching against <span className="text-[#1D9E75] font-medium">{roomItems.length} items</span> in your list
          </p>
        )}

        <div className="flex gap-2 overflow-x-auto pb-1 no-scrollbar mb-3">
          {categories.map(cat => (
            <button key={cat} onClick={() => setSelCat(cat)}
              className="flex-shrink-0 px-3.5 py-1.5 rounded-full text-sm font-medium transition-all"
              style={{
                fontFamily: "Plus Jakarta Sans",
                background: selCat === cat ? "#1D9E75" : dark ? "#2a2a4a" : "#F7F8FA",
                color: selCat === cat ? "white" : dark ? "#9CA3AF" : "#6B7280",
                border: selCat === cat ? "none" : `1px solid ${dark ? "rgba(255,255,255,0.08)" : "#e5e7eb"}`,
              }}>
              {cat}
            </button>
          ))}
        </div>

        <div className="flex gap-2 overflow-x-auto no-scrollbar">
          {distances.map(d => (
            <button key={d} onClick={() => setSelDist(d)}
              className="flex-shrink-0 px-3 py-1 rounded-full text-xs font-medium transition-all"
              style={{
                fontFamily: "Plus Jakarta Sans",
                background: selDist === d ? "#FF6B35" : dark ? "#2a2a4a" : "#F7F8FA",
                color: selDist === d ? "white" : dark ? "#9CA3AF" : "#6B7280",
                border: selDist === d ? "none" : `1px solid ${dark ? "rgba(255,255,255,0.08)" : "#e5e7eb"}`,
              }}>
              {d}
            </button>
          ))}
        </div>
      </div>

      <div className="px-5 py-2.5">
        <p className={`text-sm ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>
          {sorted.length} offer{sorted.length !== 1 ? "s" : ""} found
          {matchedOnly && sorted.length > 0 && <span className="text-[#1D9E75] font-medium"> · {sorted.filter(o => o.matched).length} matched your list</span>}
        </p>
      </div>

      <div className="flex-1 overflow-y-auto px-5 pb-24">
        {sorted.length === 0 ? (
          <div className="text-center py-16">
            <span className="text-4xl">🔍</span>
            <p className={`text-sm mt-3 ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>
              {matchedOnly ? "No offers match your current list. Try turning off 'Matched only'." : "No offers found."}
            </p>
          </div>
        ) : (
          <div className="flex flex-col gap-3">
            {sorted.map((offer, idx) => (
              <motion.button key={offer.id} onClick={onMerchantTap}
                initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: idx * 0.06 }}
                whileTap={{ scale: 0.98 }}
                className={`rounded-2xl p-4 shadow-sm text-left w-full ${dark ? "bg-[#1a1a2e] border border-white/5" : "bg-white border border-gray-50"}`}>
                {offer.nearby && (
                  <div className="flex items-center gap-2 px-3 py-2 bg-[#E8F5E9] rounded-xl mb-3 -mx-1">
                    <Zap size={13} className="text-[#1D9E75]" />
                    <span className="text-xs text-[#1D9E75] font-medium" style={{ fontFamily: "Plus Jakarta Sans" }}>You're nearby — visit now!</span>
                  </div>
                )}
                <div className="flex items-center gap-3 mb-3">
                  <div className="w-12 h-12 rounded-full flex items-center justify-center text-2xl flex-shrink-0" style={{ background: offer.color + "25" }}>{offer.logo}</div>
                  <div className="flex-1 min-w-0">
                    <p style={{ fontFamily: "Nunito", fontWeight: 700, fontSize: "15px", color: dark ? "#ffffff" : "#1A1A2E" }}>{offer.merchant}</p>
                    <div className="flex items-center gap-1">
                      <MapPin size={11} className={dark ? "text-gray-500" : "text-[#6B7280]"} />
                      <span className={`text-xs ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>{offer.distance}</span>
                    </div>
                  </div>
                  <ChevronRight size={16} className={dark ? "text-white/20" : "text-gray-300"} />
                </div>
                <p className={`font-medium text-sm mb-3 ${dark ? "text-white" : "text-[#1A1A2E]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>{offer.headline}</p>
                <div className="flex flex-wrap gap-1.5 mb-3">
                  {offer.items.map(item => {
                    const isMatch = pendingNames.some(pName => pName.includes(item.toLowerCase()) || item.toLowerCase().includes(pName));
                    return (
                      <span key={item} className="px-2 py-0.5 text-xs rounded-full font-medium"
                        style={{ fontFamily: "Plus Jakarta Sans", background: isMatch ? "#E8F5E9" : dark ? "rgba(255,255,255,0.08)" : "#F3F4F6", color: isMatch ? "#1D9E75" : dark ? "#6B7280" : "#9CA3AF", outline: isMatch ? "1px solid #1D9E7540" : "none" }}>
                        {isMatch ? "✓ " : ""}{item}
                      </span>
                    );
                  })}
                </div>
                <div className="flex items-center gap-2 flex-wrap">
                  {offer.matched && (
                    <span className="flex items-center gap-1 px-2.5 py-1 bg-[#E8F5E9] rounded-full text-xs text-[#1D9E75] font-medium" style={{ fontFamily: "Plus Jakarta Sans" }}>
                      <Tag size={9} />{offer.match} list match{offer.match > 1 ? "es" : ""}!
                    </span>
                  )}
                  <span className="flex items-center gap-1 px-2.5 py-1 bg-[#FF6B35]/10 rounded-full text-xs text-[#FF6B35] font-medium" style={{ fontFamily: "Plus Jakarta Sans" }}>Save {offer.savings}</span>
                  <span className={`flex items-center gap-1 px-2.5 py-1 rounded-full text-xs ${dark ? "bg-white/5 text-gray-400" : "bg-gray-50 text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>
                    <Clock size={9} />Ends {offer.expiry}
                  </span>
                </div>
              </motion.button>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
