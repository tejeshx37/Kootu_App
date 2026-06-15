import { motion } from "motion/react";
import { useOutletContext, useNavigate } from "react-router";
import { ChevronRight, MapPin, ShoppingCart, PiggyBank, Users, Globe, HelpCircle, LogOut, Star, Bell, Lock } from "lucide-react";
import { useTheme } from "../context/ThemeContext";

const myRooms = [
  { name: "Family Room", emoji: "🏠", members: ["👩", "👨", "👧"], count: 8, needed: 3 },
  { name: "Work Lunch", emoji: "🍱", members: ["👩", "👦"], count: 5, needed: 1 },
  { name: "Weekend BBQ", emoji: "🍖", members: ["👨", "👩", "👦", "👧"], count: 12, needed: 5 },
];

const stats = [
  { label: "Rooms", val: "3", icon: "🏠" },
  { label: "Items Bought", val: "156", icon: "🛒" },
  { label: "Money Saved", val: "₹2,840", icon: "💰" },
];

const recentActivity = [
  { item: "Basmati Rice", price: "₹180", date: "Today", room: "Family Room" },
  { item: "Toor Dal", price: "₹75", date: "Today", room: "Family Room" },
  { item: "Milk (2L)", price: "₹96", date: "Yesterday", room: "Family Room" },
];

interface OutletContext { onMerchantDash: () => void }

export function ProfileScreen() {
  const { onMerchantDash } = useOutletContext<OutletContext>();
  const navigate = useNavigate();
  const { theme } = useTheme();
  const dark = theme === "dark";

  const sections = [
    {
      title: "Account",
      items: [
        { icon: <Users size={18} className="text-[#1D9E75]" />, bg: "#E8F5E9", label: "My Rooms", sub: `${myRooms.length} active rooms`, route: "/app/profile/rooms" },
        { icon: <ShoppingCart size={18} className="text-[#3B82F6]" />, bg: "#EFF6FF", label: "Purchase History", sub: "156 items bought", route: null },
        { icon: <PiggyBank size={18} className="text-[#FF6B35]" />, bg: "#FFF0EB", label: "Savings Report", sub: "₹2,840 saved", route: null },
        { icon: <span style={{ fontSize: 18 }}>💬</span>, bg: "#E8F5E9", label: "Contact Nicknames", sub: "Custom names for room members", route: "/app/profile/nicknames" },
      ],
    },
    {
      title: "Preferences",
      items: [
        { icon: <Bell size={18} className="text-amber-500" />, bg: "#FFFBEB", label: "Notifications", sub: "Geofence, offers, rooms", route: null },
        { icon: <Globe size={18} className="text-purple-500" />, bg: "#F5F3FF", label: "Language", sub: "English", toggle: true, route: null },
        { icon: <Lock size={18} className="text-[#6B7280]" />, bg: "#F3F4F6", label: "Privacy & Data", sub: null, route: null },
      ],
    },
    {
      title: "Support",
      items: [
        { icon: <HelpCircle size={18} className="text-[#6B7280]" />, bg: "#F3F4F6", label: "Help & Support", sub: null, route: null },
        { icon: <Star size={18} className="text-amber-500" />, bg: "#FFFBEB", label: "Rate Kootu", sub: null, route: null },
      ],
    },
  ];

  return (
    <div className={`h-full flex flex-col ${dark ? "bg-[#0f0f1a]" : "bg-[#F7F8FA]"}`}>
      {/* Header */}
      <div className={`px-5 pt-12 pb-4 shadow-sm flex items-center ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
        <h1 style={{ fontFamily: "Nunito", fontWeight: 800, fontSize: "22px", color: dark ? "#ffffff" : "#1A1A2E" }}>Profile</h1>
      </div>

      <div className="flex-1 overflow-y-auto pb-24">
        {/* User card */}
        <div className={`mx-5 mt-4 rounded-2xl p-5 shadow-sm ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
          <div className="flex items-center gap-4">
            <div className="relative">
              <img src=""
                className="w-20 h-20 rounded-full object-cover"
                style={{ borderWidth: 3, borderStyle: "solid", borderColor: "#1D9E75" }} />
              <div className="absolute -bottom-1 -right-1 w-6 h-6 bg-[#1D9E75] rounded-full flex items-center justify-center">
                <span className="text-white text-xs">✓</span>
              </div>
            </div>
            <div className="flex-1">
              <h2 style={{ fontFamily: "Nunito", fontWeight: 800, fontSize: "20px", color: dark ? "#ffffff" : "#1A1A2E" }}>Priya Rajan</h2>
              <div className="flex items-center gap-1.5 mt-1">
                <MapPin size={13} className={dark ? "text-gray-400" : "text-[#6B7280]"} />
                <span className={`text-sm ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>Velachery, Chennai</span>
              </div>
              <span className="inline-block mt-2 px-3 py-0.5 bg-[#E8F5E9] rounded-full text-xs text-[#1D9E75] font-medium" style={{ fontFamily: "Plus Jakarta Sans" }}>
                Member since Jan 2025
              </span>
            </div>
          </div>
        </div>

        {/* Stats */}
        <div className="flex gap-3 mx-5 mt-3">
          {stats.map((s, i) => (
            s.label === "Rooms" ? (
              <motion.button key={i} onClick={() => navigate("/app/profile/rooms")} whileTap={{ scale: 0.96 }}
                initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.08 }}
                className={`flex-1 rounded-2xl p-3.5 shadow-sm text-center ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
                <span className="text-2xl mb-1 block">{s.icon}</span>
                <p style={{ fontFamily: "Nunito", fontWeight: 800, fontSize: "16px", color: dark ? "#ffffff" : "#1A1A2E" }}>{myRooms.length}</p>
                <p className="text-xs text-[#1D9E75] mt-0.5 font-medium" style={{ fontFamily: "Plus Jakarta Sans" }}>{s.label}</p>
              </motion.button>
            ) : (
              <motion.div key={i} initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.08 }}
                className={`flex-1 rounded-2xl p-3.5 shadow-sm text-center ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
                <span className="text-2xl mb-1 block">{s.icon}</span>
                <p style={{ fontFamily: "Nunito", fontWeight: 800, fontSize: "16px", color: dark ? "#ffffff" : "#1A1A2E" }}>{s.val}</p>
                <p className={`text-xs mt-0.5 ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>{s.label}</p>
              </motion.div>
            )
          ))}
        </div>

        {/* Recent purchases */}
        <div className="mx-5 mt-4 mb-4">
          <h3 style={{ fontFamily: "Nunito", fontWeight: 700, fontSize: "15px", color: dark ? "#ffffff" : "#1A1A2E", marginBottom: 10 }}>Recent Purchases</h3>
          <div className={`rounded-2xl shadow-sm overflow-hidden ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
            {recentActivity.map((tx, i) => (
              <div key={i} className={`flex items-center gap-3 px-4 py-3.5 ${i < recentActivity.length - 1 ? `border-b ${dark ? "border-white/5" : "border-gray-50"}` : ""}`}>
                <div className="w-8 h-8 rounded-full bg-[#E8F5E9] flex items-center justify-center">
                  <ShoppingCart size={14} className="text-[#1D9E75]" />
                </div>
                <div className="flex-1">
                  <p style={{ fontFamily: "Plus Jakarta Sans", fontWeight: 500, fontSize: "13px", color: dark ? "#ffffff" : "#1A1A2E" }}>{tx.item}</p>
                  <p className={`text-xs ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>{tx.room} · {tx.date}</p>
                </div>
                <span style={{ fontFamily: "Nunito", fontWeight: 700, fontSize: "14px", color: dark ? "#ffffff" : "#1A1A2E" }}>{tx.price}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Merchant dashboard CTA */}
        <div className="mx-5 mb-4">
          <button onClick={onMerchantDash}
            className="w-full bg-gradient-to-r from-[#1D9E75] to-[#17875f] rounded-2xl p-4 flex items-center gap-3 text-left shadow-sm">
            <div className="w-12 h-12 rounded-xl bg-white/20 flex items-center justify-center text-2xl">🏪</div>
            <div className="flex-1">
              <p style={{ fontFamily: "Nunito", fontWeight: 700, fontSize: "15px", color: "white" }}>Switch to Merchant Mode</p>
              <p className="text-white/70 text-xs mt-0.5" style={{ fontFamily: "Plus Jakarta Sans" }}>Post offers & view your dashboard</p>
            </div>
            <ChevronRight size={18} className="text-white/60" />
          </button>
        </div>

        {/* Settings sections */}
        {sections.map(section => (
          <div key={section.title} className="mx-5 mb-4">
            <p className={`text-xs uppercase tracking-wider mb-2 px-1 ${dark ? "text-gray-500" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>
              {section.title}
            </p>
            <div className={`rounded-2xl shadow-sm overflow-hidden ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
              {section.items.map((item, i) => (
                <div key={i} onClick={() => item.route && navigate(item.route)}
                  className={`flex items-center gap-3 px-4 py-3.5 ${i < section.items.length - 1 ? `border-b ${dark ? "border-white/5" : "border-gray-50"}` : ""} ${item.route ? `cursor-pointer ${dark ? "active:bg-white/5" : "active:bg-gray-50"}` : ""}`}>
                  <div className="w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0" style={{ background: item.bg }}>
                    {item.icon}
                  </div>
                  <div className="flex-1">
                    <p style={{ fontFamily: "Plus Jakarta Sans", fontWeight: 500, fontSize: "14px", color: dark ? "#ffffff" : "#1A1A2E" }}>{item.label}</p>
                    {item.sub && <p className={`text-xs ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>{item.sub}</p>}
                  </div>
                  {item.toggle ? (
                    <div className="flex items-center gap-2">
                      <span className={`text-xs ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>தமிழ்</span>
                      <div className={`w-12 h-6 rounded-full relative ${dark ? "bg-white/10" : "bg-gray-200"}`}>
                        <div className="absolute left-1 top-1 w-4 h-4 bg-white rounded-full shadow" />
                      </div>
                    </div>
                  ) : (
                    <ChevronRight size={16} className={dark ? "text-white/20" : "text-gray-300"} />
                  )}
                </div>
              ))}
            </div>
          </div>
        ))}

        {/* Logout */}
        <div className="mx-5 mb-6">
          <button className={`w-full flex items-center justify-center gap-2 py-4 rounded-2xl border-2 ${dark ? "border-red-900/40 bg-red-900/10" : "border-red-100 bg-white"}`}>
            <LogOut size={18} className="text-red-500" />
            <span style={{ fontFamily: "Nunito", fontWeight: 700, fontSize: "15px", color: "#EF4444" }}>Log Out</span>
          </button>
        </div>
      </div>
    </div>
  );
}
