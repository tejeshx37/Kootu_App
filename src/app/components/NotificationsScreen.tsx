import { useState } from "react";
import { motion } from "motion/react";
import { ArrowLeft, MapPin, ShoppingCart, Plus, Check, Bell } from "lucide-react";
import { useTheme } from "../context/ThemeContext";

const offerNotifs = [
  { id: 1, unread: true, time: "2 min ago", icon: "🛒", iconBg: "#E8F5E9", title: "You're near FreshMart!", body: "They have deals on 3 items from your list — Rice, Dal & Oil. Save up to ₹85.", cta: "View Offer", type: "geo" },
  { id: 2, unread: true, time: "1 hr ago", icon: "🥦", iconBg: "#F0FDF4", title: "New deal from Veggie Hub", body: "₹50 off on vegetables. Tomatoes are on your list! 500m away.", cta: "View", type: "offer" },
  { id: 3, unread: false, time: "3 hr ago", icon: "🥛", iconBg: "#EFF6FF", title: "South Fresh Dairy deal expires soon", body: "A2 milk offer ends in 2 hours. You have Milk on your list.", cta: "View", type: "offer" },
  { id: 4, unread: false, time: "Yesterday", icon: "🏪", iconBg: "#FFF7ED", title: "New store in your area", body: "Daily Needs Store just joined Kootu! Check their current offers.", cta: "Explore", type: "store" },
];

const roomNotifs = [
  { id: 1, unread: true, time: "5 min ago", emoji: "👩‍🦳", name: "Mom", action: "marked Milk as Bought ✓", room: "Family Room", type: "bought" },
  { id: 2, unread: true, time: "30 min ago", emoji: "👩", name: "Priya", action: "added Basmati Rice to the list", room: "Family Room", type: "added" },
  { id: 3, unread: false, time: "2 hr ago", emoji: "👨", name: "Dad", action: "claimed Bread — now buying", room: "Family Room", type: "claimed" },
  { id: 4, unread: false, time: "Yesterday", emoji: "👦", name: "Arjun", action: "joined Family Room", room: "Family Room", type: "joined" },
  { id: 5, unread: false, time: "Yesterday", emoji: "👩", name: "Priya", action: "set weekly budget to ₹3,500", room: "Family Room", type: "budget" },
];

const typeIcon = (type: string) => {
  if (type === "bought") return <Check size={12} className="text-green-500" />;
  if (type === "added") return <Plus size={12} className="text-[#1D9E75]" />;
  if (type === "claimed") return <ShoppingCart size={12} className="text-amber-500" />;
  return <Bell size={12} className="text-[#6B7280]" />;
};

interface NotificationsProps { onBack: () => void }

export function NotificationsScreen({ onBack }: NotificationsProps) {
  const { theme } = useTheme();
  const dark = theme === "dark";
  const [tab, setTab] = useState<"offers" | "room">("offers");

  return (
    <div className={`h-full flex flex-col ${dark ? "bg-[#0f0f1a]" : "bg-[#F7F8FA]"}`}>
      <div className={`px-4 pt-12 pb-0 shadow-sm ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
        <div className="flex items-center gap-3 mb-4">
          <button onClick={onBack} className={`w-10 h-10 rounded-full flex items-center justify-center ${dark ? "bg-white/10" : "bg-[#F7F8FA]"}`}>
            <ArrowLeft size={20} className={dark ? "text-white" : "text-[#1A1A2E]"} />
          </button>
          <h1 style={{ fontFamily: "Nunito", fontWeight: 800, fontSize: "20px", color: dark ? "#ffffff" : "#1A1A2E" }}>Notifications</h1>
          <div className="ml-auto px-2.5 py-1 bg-[#FF6B35] rounded-full">
            <span className="text-white text-xs font-bold" style={{ fontFamily: "Nunito" }}>4</span>
          </div>
        </div>
        <div className={`flex border-b ${dark ? "border-white/5" : "border-gray-100"}`}>
          {(["offers", "room"] as const).map(t => (
            <button key={t} onClick={() => setTab(t)}
              className="flex-1 py-3 text-sm font-medium relative capitalize"
              style={{ fontFamily: "Plus Jakarta Sans", color: tab === t ? "#1D9E75" : dark ? "#6B7280" : "#6B7280" }}>
              {t === "room" ? "Room Activity" : "Offers & Alerts"}
              {tab === t && <motion.div layoutId="notifTab" className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#1D9E75]" />}
            </button>
          ))}
        </div>
      </div>

      <div className="flex-1 overflow-y-auto pb-6">
        {tab === "offers" ? (
          <div className="pt-3 px-4 flex flex-col gap-2.5">
            {offerNotifs.map((n, i) => (
              <motion.div key={n.id} initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.07 }}
                className={`rounded-2xl p-4 shadow-sm flex gap-3 ${n.unread ? "border-l-4 border-[#1D9E75]" : ""} ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}
                style={{ borderRadius: n.unread ? "0 16px 16px 0" : "16px" }}>
                <div className="w-12 h-12 rounded-xl flex items-center justify-center text-2xl flex-shrink-0" style={{ background: n.iconBg }}>{n.icon}</div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-start justify-between gap-2 mb-0.5">
                    <p style={{ fontFamily: "Nunito", fontWeight: 700, fontSize: "14px", color: dark ? "#ffffff" : "#1A1A2E" }}>
                      {n.type === "geo" && <MapPin size={12} className="inline text-[#1D9E75] mr-1" />}
                      {n.title}
                    </p>
                    {n.unread && <div className="w-2 h-2 bg-[#FF6B35] rounded-full flex-shrink-0 mt-1.5" />}
                  </div>
                  <p className={`text-xs leading-relaxed mb-2 ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>{n.body}</p>
                  <div className="flex items-center justify-between">
                    <button className="px-3 py-1 bg-[#E8F5E9] rounded-full text-xs text-[#1D9E75] font-medium" style={{ fontFamily: "Plus Jakarta Sans" }}>{n.cta}</button>
                    <span className={`text-xs ${dark ? "text-gray-500" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>{n.time}</span>
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        ) : (
          <div className="pt-3 px-4 flex flex-col gap-2.5">
            {roomNotifs.map((n, i) => (
              <motion.div key={n.id} initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.06 }}
                className={`rounded-2xl px-4 py-3.5 shadow-sm flex items-start gap-3 ${n.unread ? "border-l-4 border-[#1D9E75]" : ""} ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}
                style={{ borderRadius: n.unread ? "0 16px 16px 0" : "16px" }}>
                <div className="relative">
                  <div className="w-11 h-11 rounded-full bg-[#E8F5E9] flex items-center justify-center text-2xl">{n.emoji}</div>
                  <div className={`absolute -bottom-0.5 -right-0.5 w-5 h-5 rounded-full flex items-center justify-center shadow-sm ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>{typeIcon(n.type)}</div>
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm" style={{ fontFamily: "Plus Jakarta Sans" }}>
                    <span style={{ fontWeight: 600, color: dark ? "#ffffff" : "#1A1A2E" }}>{n.name}</span>
                    <span style={{ color: dark ? "#9CA3AF" : "#6B7280" }}> {n.action}</span>
                  </p>
                  <div className="flex items-center gap-2 mt-1">
                    <span className="px-2 py-0.5 bg-[#E8F5E9] rounded-full text-xs text-[#1D9E75]" style={{ fontFamily: "Plus Jakarta Sans" }}>{n.room}</span>
                    <span className={`text-xs ${dark ? "text-gray-500" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>{n.time}</span>
                  </div>
                </div>
                {n.unread && <div className="w-2 h-2 bg-[#FF6B35] rounded-full flex-shrink-0 mt-1.5" />}
              </motion.div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
