import { useState } from "react";
import { motion } from "motion/react";
import { ArrowLeft, Star, MapPin, Navigation, Phone, Clock, ChevronRight, Tag } from "lucide-react";
import { useTheme } from "../context/ThemeContext";

const deals = [
  { id: 1, emoji: "🍚", title: "15% off on Rice & Pulses", sub: "Min. purchase ₹200", expiry: "Ends today", savings: "₹85", active: true },
  { id: 2, emoji: "🛢️", title: "10% off on Cooking Oils", sub: "All brands included", expiry: "2 days left", savings: "₹45", active: true },
  { id: 3, emoji: "🧅", title: "Onions at ₹25/kg", sub: "Limited stock — 50kg", expiry: "Today only", savings: "₹15", active: true },
];

const reviews = [
  { name: "Meena S.", rating: 5, text: "Very fresh vegetables! Always find what I need.", time: "2 days ago", emoji: "👩" },
  { name: "Rajan K.", rating: 4, text: "Good prices, sometimes a little crowded in the morning.", time: "1 week ago", emoji: "👨" },
  { name: "Divya P.", rating: 5, text: "The offers through Kootu are amazing. Saved ₹300 last month!", time: "2 weeks ago", emoji: "👩‍🦱" },
];

interface MerchantProfileProps { onBack: () => void }

export function MerchantProfileScreen({ onBack }: MerchantProfileProps) {
  const { theme } = useTheme();
  const dark = theme === "dark";
  const [activeTab, setActiveTab] = useState<"offers" | "reviews" | "about">("offers");

  return (
    <div className={`h-full flex flex-col overflow-hidden ${dark ? "bg-[#0f0f1a]" : "bg-[#F7F8FA]"}`}>
      <div className="relative h-48 flex-shrink-0">
        <img src="https://images.unsplash.com/photo-1607349913338-fca6f7fc42d0?w=600&q=80" alt="FreshMart store" className="w-full h-full object-cover" />
        <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
        <button onClick={onBack} className="absolute top-12 left-4 w-10 h-10 rounded-full bg-white/90 backdrop-blur flex items-center justify-center shadow">
          <ArrowLeft size={18} className="text-[#1A1A2E]" />
        </button>
        <div className={`absolute -bottom-7 left-5 w-16 h-16 rounded-2xl shadow-lg flex items-center justify-center text-3xl border-2 ${dark ? "bg-[#1a1a2e] border-[#1a1a2e]" : "bg-white border-white"}`}>🛒</div>
      </div>

      <div className={`px-5 pt-10 pb-0 shadow-sm ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
        <div className="flex items-start justify-between mb-1">
          <div>
            <h1 style={{ fontFamily: "Nunito", fontWeight: 800, fontSize: "20px", color: dark ? "#ffffff" : "#1A1A2E" }}>FreshMart Velachery</h1>
            <p className={`text-sm ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>Grocery · Vegetables · Dairy</p>
          </div>
          <div className="flex flex-col items-end">
            <div className="flex items-center gap-1">
              {[4, 4, 4, 4, 1].map((v, i) => <Star key={i} size={14} className={v === 4 ? "text-amber-400 fill-amber-400" : "text-amber-200 fill-amber-200"} />)}
              <span className={`font-bold text-sm ml-1 ${dark ? "text-white" : "text-[#1A1A2E]"}`} style={{ fontFamily: "Nunito" }}>4.2</span>
            </div>
            <span className={`text-xs ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>142 reviews</span>
          </div>
        </div>

        <div className="flex items-center gap-3 mb-4">
          <div className="flex items-center gap-1">
            <MapPin size={13} className={dark ? "text-gray-500" : "text-[#6B7280]"} />
            <span className={`text-xs ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>2.0 km · Velachery Main Rd</span>
          </div>
          <div className="flex items-center gap-1">
            <Clock size={13} className="text-green-500" />
            <span className="text-xs text-green-500 font-medium" style={{ fontFamily: "Plus Jakarta Sans" }}>Open · Closes 10 PM</span>
          </div>
        </div>

        <div className="flex gap-3 mb-4">
          <button className="flex-1 flex items-center justify-center gap-2 py-3 rounded-xl text-white font-bold" style={{ background: "#1D9E75", fontFamily: "Nunito" }}>
            <Navigation size={16} />Directions
          </button>
          <button className={`flex items-center justify-center w-12 h-12 rounded-xl border ${dark ? "bg-white/10 border-white/10" : "bg-[#F7F8FA] border-gray-100"}`}>
            <Phone size={18} className={dark ? "text-white" : "text-[#1A1A2E]"} />
          </button>
        </div>

        <div className={`flex border-b ${dark ? "border-white/5" : "border-gray-100"}`}>
          {(["offers", "reviews", "about"] as const).map(tab => (
            <button key={tab} onClick={() => setActiveTab(tab)}
              className="flex-1 py-3 capitalize text-sm font-medium relative"
              style={{ fontFamily: "Plus Jakarta Sans", color: activeTab === tab ? "#1D9E75" : dark ? "#6B7280" : "#6B7280" }}>
              {tab === "offers" ? "Active Offers" : tab.charAt(0).toUpperCase() + tab.slice(1)}
              {activeTab === tab && <motion.div layoutId="merchantTab" className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#1D9E75]" />}
            </button>
          ))}
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-5 pt-4 pb-6">
        {activeTab === "offers" && (
          <div className="flex flex-col gap-3">
            {deals.map(deal => (
              <div key={deal.id} className={`rounded-2xl p-4 shadow-sm ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
                <div className="flex items-start gap-3">
                  <div className="w-12 h-12 rounded-xl bg-[#E8F5E9] flex items-center justify-center text-2xl flex-shrink-0">{deal.emoji}</div>
                  <div className="flex-1 min-w-0">
                    <p style={{ fontFamily: "Nunito", fontWeight: 700, fontSize: "14px", color: dark ? "#ffffff" : "#1A1A2E" }}>{deal.title}</p>
                    <p className={`text-xs mt-0.5 ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>{deal.sub}</p>
                    <div className="flex items-center gap-2 mt-2">
                      <span className="flex items-center gap-1 px-2 py-0.5 bg-[#FF6B35]/10 text-[#FF6B35] text-xs rounded-full font-medium" style={{ fontFamily: "Plus Jakarta Sans" }}><Tag size={9} />Save {deal.savings}</span>
                      <span className={`text-xs ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}><Clock size={9} className="inline mr-1" />{deal.expiry}</span>
                    </div>
                  </div>
                  <ChevronRight size={16} className={`mt-1 flex-shrink-0 ${dark ? "text-white/20" : "text-gray-300"}`} />
                </div>
              </div>
            ))}
          </div>
        )}

        {activeTab === "reviews" && (
          <div className="flex flex-col gap-3">
            {reviews.map((r, i) => (
              <div key={i} className={`rounded-2xl p-4 shadow-sm ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
                <div className="flex items-center gap-3 mb-2">
                  <div className="w-9 h-9 rounded-full bg-[#E8F5E9] flex items-center justify-center text-xl">{r.emoji}</div>
                  <div className="flex-1">
                    <p style={{ fontFamily: "Nunito", fontWeight: 700, fontSize: "14px", color: dark ? "#ffffff" : "#1A1A2E" }}>{r.name}</p>
                    <div className="flex items-center gap-0.5">
                      {Array.from({ length: 5 }).map((_, j) => <Star key={j} size={11} className={j < r.rating ? "text-amber-400 fill-amber-400" : "text-gray-200 fill-gray-200"} />)}
                    </div>
                  </div>
                  <span className={`text-xs ${dark ? "text-gray-500" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>{r.time}</span>
                </div>
                <p className={`text-sm ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>{r.text}</p>
              </div>
            ))}
          </div>
        )}

        {activeTab === "about" && (
          <div className="flex flex-col gap-3">
            <div className={`rounded-2xl p-4 shadow-sm ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
              <h3 style={{ fontFamily: "Nunito", fontWeight: 700, fontSize: "15px", color: dark ? "#ffffff" : "#1A1A2E", marginBottom: 8 }}>About</h3>
              <p className={`text-sm leading-relaxed ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>FreshMart is a family-run grocery and vegetable store in Velachery, serving the neighbourhood since 1998. We stock fresh produce daily from local farms and offer competitive prices on all staples.</p>
            </div>
            {[
              { icon: "📍", label: "Address", val: "42, Velachery Main Road, Chennai - 600042" },
              { icon: "📞", label: "Phone", val: "+91 98405 XXXXX" },
              { icon: "🕐", label: "Hours", val: "Mon–Sun: 6 AM – 10 PM" },
              { icon: "🚚", label: "Delivery", val: "Home delivery available · Min ₹300" },
            ].map(info => (
              <div key={info.label} className={`rounded-2xl px-4 py-3.5 shadow-sm flex items-start gap-3 ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
                <span className="text-xl">{info.icon}</span>
                <div>
                  <p className={`text-xs mb-0.5 ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>{info.label}</p>
                  <p style={{ fontFamily: "Plus Jakarta Sans", fontWeight: 500, fontSize: "14px", color: dark ? "#ffffff" : "#1A1A2E" }}>{info.val}</p>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
