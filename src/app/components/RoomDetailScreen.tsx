import { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { ArrowLeft, Settings, Plus, ShoppingCart, Check, AlertTriangle, Clock } from "lucide-react";
import { RoomInfoSheet } from "./RoomInfoSheet";
import { useTheme } from "../context/ThemeContext";

type ItemStatus = "needed" | "buying" | "bought" | "due-soon";

interface Item {
  id: number; name: string; qty: string; status: ItemStatus;
  buyer?: string; buyerEmoji?: string; timeAgo?: string; claimedBy?: string;
}

const initialItems: Item[] = [
  { id: 1, name: "Basmati Rice", qty: "2 kg", status: "needed" },
  { id: 2, name: "Milk", qty: "2 L", status: "buying", buyer: "Priya", buyerEmoji: "👩" },
  { id: 3, name: "Tomatoes", qty: "1 kg", status: "bought", buyer: "Priya", buyerEmoji: "👩", timeAgo: "2h ago" },
  { id: 4, name: "Cooking Oil", qty: "1 L", status: "due-soon", timeAgo: "Usually every 7 days" },
  { id: 5, name: "Toor Dal", qty: "500 g", status: "needed" },
  { id: 6, name: "Curd", qty: "500 g", status: "needed" },
  { id: 7, name: "Eggs", qty: "12 pcs", status: "bought", buyer: "Mom", buyerEmoji: "👩‍🦳", timeAgo: "Yesterday" },
  { id: 8, name: "Bread", qty: "1 loaf", status: "buying", buyer: "Dad", buyerEmoji: "👨" },
];

const members = ["👩", "👨", "👧"];
const tabs = ["Items", "History", "Budget"] as const;

function StatusChip({ status, buyer, buyerEmoji }: { status: ItemStatus; buyer?: string; buyerEmoji?: string }) {
  if (status === "needed") return <span className="px-2.5 py-1 bg-gray-100 text-gray-500 rounded-full text-xs font-medium" style={{ fontFamily: "Plus Jakarta Sans" }}>Needed</span>;
  if (status === "buying") return <span className="flex items-center gap-1.5 px-2.5 py-1 bg-amber-50 text-amber-600 rounded-full text-xs font-medium" style={{ fontFamily: "Plus Jakarta Sans" }}><span>{buyerEmoji}</span><ShoppingCart size={10} />{buyer} buying</span>;
  if (status === "bought") return <span className="flex items-center gap-1 px-2.5 py-1 bg-green-50 text-green-600 rounded-full text-xs font-medium" style={{ fontFamily: "Plus Jakarta Sans" }}><Check size={10} />Done</span>;
  if (status === "due-soon") return <span className="flex items-center gap-1 px-2.5 py-1 bg-orange-50 text-[#FF6B35] rounded-full text-xs font-medium" style={{ fontFamily: "Plus Jakarta Sans" }}><AlertTriangle size={10} />Due Soon</span>;
  return null;
}

interface RoomDetailProps { roomId: number; onBack: () => void; onAddItem: () => void }

export function RoomDetailScreen({ onBack, onAddItem }: RoomDetailProps) {
  const { theme } = useTheme();
  const dark = theme === "dark";
  const [activeTab, setActiveTab] = useState<"Items" | "History" | "Budget">("Items");
  const [items, setItems] = useState<Item[]>(initialItems);
  const [showRoomInfo, setShowRoomInfo] = useState(false);

  const claimItem = (id: number) => {
    setItems(prev => prev.map(item => item.id === id ? { ...item, status: "buying" as ItemStatus, buyer: "Priya", buyerEmoji: "👩" } : item));
  };

  const activeItems = items.filter(i => i.status !== "bought");
  const boughtItems = items.filter(i => i.status === "bought");

  return (
    <div className={`h-full flex flex-col ${dark ? "bg-[#0f0f1a]" : "bg-[#F7F8FA]"}`}>
      <div className={`px-4 pt-12 pb-0 shadow-sm ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
        <div className="flex items-center justify-between mb-4">
          <button onClick={onBack} className={`w-10 h-10 rounded-full flex items-center justify-center ${dark ? "bg-white/10" : "bg-[#F7F8FA]"}`}>
            <ArrowLeft size={20} className={dark ? "text-white" : "text-[#1A1A2E]"} />
          </button>
          <div className="flex-1 mx-3">
            <h1 style={{ fontFamily: "Nunito", fontWeight: 800, fontSize: "18px", color: dark ? "#ffffff" : "#1A1A2E" }}>Family Room</h1>
            <div className="flex items-center gap-2 mt-0.5">
              <div className="flex -space-x-1.5">
                {members.map((m, i) => (
                  <div key={i} className={`w-5 h-5 rounded-full flex items-center justify-center text-xs border ${dark ? "bg-white/10 border-[#1a1a2e]" : "bg-[#E8F5E9] border-white"}`}>{m}</div>
                ))}
              </div>
              <span className={`text-xs ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>3 members</span>
            </div>
          </div>
          <button onClick={() => setShowRoomInfo(true)} className={`w-10 h-10 rounded-full flex items-center justify-center ${dark ? "bg-white/10" : "bg-[#F7F8FA]"}`}>
            <Settings size={18} className={dark ? "text-gray-300" : "text-[#6B7280]"} />
          </button>
        </div>

        <div className="mb-4 px-1">
          <div className="flex justify-between text-xs mb-1.5">
            <span className={dark ? "text-gray-400" : "text-[#6B7280]"} style={{ fontFamily: "Plus Jakarta Sans" }}>Weekly Budget</span>
            <span className={`font-medium ${dark ? "text-white" : "text-[#1A1A2E]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>₹2,340 / ₹3,500</span>
          </div>
          <div className={`h-2 rounded-full overflow-hidden ${dark ? "bg-white/10" : "bg-gray-100"}`}>
            <motion.div initial={{ width: 0 }} animate={{ width: "67%" }} transition={{ delay: 0.3, duration: 0.6 }} className="h-full bg-[#1D9E75] rounded-full" />
          </div>
        </div>

        <div className={`flex gap-0 border-b ${dark ? "border-white/5" : "border-gray-100"}`}>
          {tabs.map(tab => (
            <button key={tab} onClick={() => setActiveTab(tab)} className="flex-1 py-3 text-sm font-medium relative transition-colors"
              style={{ fontFamily: "Plus Jakarta Sans", color: activeTab === tab ? "#1D9E75" : dark ? "#6B7280" : "#6B7280" }}>
              {tab}
              {activeTab === tab && <motion.div layoutId="tabIndicator" className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#1D9E75]" />}
            </button>
          ))}
        </div>
      </div>

      <div className="flex-1 overflow-y-auto pb-32">
        <AnimatePresence mode="wait">
          {activeTab === "Items" && (
            <motion.div key="items" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="pt-3 px-4">
              <p className={`text-xs uppercase tracking-wider mb-2 px-1 ${dark ? "text-gray-500" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>Active · {activeItems.length} items</p>
              <div className="flex flex-col gap-2 mb-4">
                {activeItems.map(item => (
                  <motion.div key={item.id} layout className={`rounded-2xl px-4 py-3.5 flex items-center gap-3 shadow-sm ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
                    {item.status === "due-soon" && (
                      <motion.div animate={{ opacity: [1, 0.4, 1] }} transition={{ repeat: Infinity, duration: 1.5 }} className="w-2.5 h-2.5 bg-[#FF6B35] rounded-full flex-shrink-0" />
                    )}
                    {item.status !== "due-soon" && <div className="w-2.5 h-2.5 flex-shrink-0" />}
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2">
                        <span style={{ fontFamily: "Plus Jakarta Sans", fontWeight: 500, fontSize: "14px", color: dark ? "#ffffff" : "#1A1A2E" }}>{item.name}</span>
                        <span className={`text-xs px-2 py-0.5 rounded-full border ${dark ? "bg-white/5 text-gray-400 border-white/10" : "bg-gray-50 text-[#6B7280] border-gray-100"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>{item.qty}</span>
                      </div>
                      {item.timeAgo && (
                        <p className={`text-xs mt-0.5 ${dark ? "text-gray-500" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>
                          <Clock size={9} className="inline mr-1" />{item.timeAgo}
                        </p>
                      )}
                    </div>
                    <div className="flex flex-col items-end gap-1.5">
                      <StatusChip status={item.status} buyer={item.buyer} buyerEmoji={item.buyerEmoji} />
                      {item.status === "needed" && (
                        <motion.button onClick={() => claimItem(item.id)} whileTap={{ scale: 0.95 }}
                          className="text-xs px-3 py-1 bg-[#1D9E75] text-white rounded-full font-medium" style={{ fontFamily: "Plus Jakarta Sans" }}>
                          Claim
                        </motion.button>
                      )}
                    </div>
                  </motion.div>
                ))}
              </div>

              <p className={`text-xs uppercase tracking-wider mb-2 px-1 ${dark ? "text-gray-500" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>Bought · {boughtItems.length} items</p>
              <div className="flex flex-col gap-2">
                {boughtItems.map(item => (
                  <div key={item.id} className={`rounded-2xl px-4 py-3.5 flex items-center gap-3 opacity-60 ${dark ? "bg-[#1a1a2e]" : "bg-white/60"}`}>
                    <Check size={14} className="text-green-500 flex-shrink-0" />
                    <div className="flex-1 min-w-0">
                      <span style={{ fontFamily: "Plus Jakarta Sans", fontWeight: 400, fontSize: "14px", color: dark ? "#9CA3AF" : "#9CA3AF", textDecoration: "line-through" }}>{item.name}</span>
                      <p className={`text-xs mt-0.5 ${dark ? "text-gray-500" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>{item.buyerEmoji} {item.buyer} · {item.timeAgo}</p>
                    </div>
                    <span className="text-xs px-2 py-0.5 bg-green-50 text-green-600 rounded-full" style={{ fontFamily: "Plus Jakarta Sans" }}>Done</span>
                  </div>
                ))}
              </div>
            </motion.div>
          )}

          {activeTab === "History" && (
            <motion.div key="history" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="pt-4 px-4">
              {["Today", "Yesterday", "3 days ago"].map((day, di) => (
                <div key={day} className="mb-4">
                  <p className={`text-xs uppercase tracking-wider mb-2 px-1 ${dark ? "text-gray-500" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>{day}</p>
                  <div className="flex flex-col gap-2">
                    {[1, 2].map(i => (
                      <div key={i} className={`rounded-2xl px-4 py-3 flex items-center gap-3 shadow-sm ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
                        <div className="w-8 h-8 rounded-full bg-green-50 flex items-center justify-center">
                          <Check size={14} className="text-green-500" />
                        </div>
                        <div className="flex-1">
                          <p style={{ fontFamily: "Plus Jakarta Sans", fontWeight: 500, fontSize: "13px", color: dark ? "#ffffff" : "#1A1A2E" }}>
                            {["Milk (2L)", "Onions (1kg)", "Bread", "Eggs", "Butter", "Salt"][di * 2 + i - 1] || "Item"}
                          </p>
                          <p className={`text-xs ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>
                            👩 Priya bought · ₹{[48, 30, 35, 72, 55, 20][di * 2 + i - 1] || 50}
                          </p>
                        </div>
                        <span className="text-[#1D9E75] font-medium text-sm" style={{ fontFamily: "Plus Jakarta Sans" }}>₹{[48, 30, 35, 72, 55, 20][di * 2 + i - 1] || 50}</span>
                      </div>
                    ))}
                  </div>
                </div>
              ))}
            </motion.div>
          )}

          {activeTab === "Budget" && (
            <motion.div key="budget" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="pt-4 px-4">
              <div className={`rounded-2xl p-5 shadow-sm mb-4 ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
                <p className={`text-sm mb-1 ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>This week's spend</p>
                <p style={{ fontFamily: "Nunito", fontWeight: 800, fontSize: "28px", color: dark ? "#ffffff" : "#1A1A2E" }}>₹2,340</p>
                <p className={`text-sm ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>of ₹3,500 budget</p>
                <div className={`h-3 rounded-full overflow-hidden mt-3 ${dark ? "bg-white/10" : "bg-gray-100"}`}>
                  <motion.div initial={{ width: 0 }} animate={{ width: "67%" }} transition={{ delay: 0.3, duration: 0.6 }} className="h-full bg-[#1D9E75] rounded-full" />
                </div>
                <p className="text-[#1D9E75] text-sm font-medium mt-1.5" style={{ fontFamily: "Plus Jakarta Sans" }}>₹1,160 remaining</p>
              </div>
              {[
                { cat: "Groceries", icon: "🛒", spent: 1200, total: 1500 },
                { cat: "Dairy", icon: "🥛", spent: 480, total: 600 },
                { cat: "Vegetables", icon: "🥦", spent: 660, total: 800 },
                { cat: "Household", icon: "🧴", spent: 0, total: 600 },
              ].map(c => (
                <div key={c.cat} className={`rounded-2xl px-4 py-3.5 mb-2 shadow-sm ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
                  <div className="flex items-center gap-3 mb-2">
                    <span className="text-xl">{c.icon}</span>
                    <div className="flex-1">
                      <div className="flex justify-between">
                        <span style={{ fontFamily: "Plus Jakarta Sans", fontWeight: 500, fontSize: "14px", color: dark ? "#ffffff" : "#1A1A2E" }}>{c.cat}</span>
                        <span style={{ fontFamily: "Plus Jakarta Sans", fontWeight: 500, fontSize: "14px", color: dark ? "#ffffff" : "#1A1A2E" }}>₹{c.spent}</span>
                      </div>
                    </div>
                  </div>
                  <div className={`h-1.5 rounded-full overflow-hidden ${dark ? "bg-white/10" : "bg-gray-100"}`}>
                    <div className="h-full bg-[#1D9E75] rounded-full" style={{ width: `${(c.spent / c.total) * 100}%` }} />
                  </div>
                  <p className={`text-xs mt-1 ${dark ? "text-gray-500" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>₹{c.total - c.spent} left of ₹{c.total}</p>
                </div>
              ))}
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      <div className={`absolute bottom-0 left-0 right-0 border-t px-4 py-3 ${dark ? "bg-[#1a1a2e] border-white/5" : "bg-white border-gray-100"}`}>
        <button onClick={onAddItem} className={`w-full flex items-center gap-3 rounded-xl px-4 py-3 border border-dashed border-[#1D9E75]/40 ${dark ? "bg-[#0f0f1a]" : "bg-[#F7F8FA]"}`}>
          <div className="w-8 h-8 bg-[#1D9E75] rounded-full flex items-center justify-center">
            <Plus size={18} className="text-white" />
          </div>
          <span className={`text-sm ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>Add item to Family Room…</span>
        </button>
      </div>

      <AnimatePresence>
        {showRoomInfo && <RoomInfoSheet onClose={() => setShowRoomInfo(false)} roomName="Family Room" roomEmoji="🏠" roomId="A3X9K2" members={members} />}
      </AnimatePresence>
    </div>
  );
}
