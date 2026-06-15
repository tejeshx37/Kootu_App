import { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { useOutletContext, useNavigate } from "react-router";
import { Bell, ChevronDown, Plus, LogIn, Check, Send, ChevronRight, MapPin, Sun, Moon } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { rooms, CATEGORIES, type Category, type ListItem } from "./MainLayout";

const KEYWORDS: Record<string, string> = {
  tomato: "Vegetables", onion: "Vegetables", potato: "Vegetables", carrot: "Vegetables",
  brinjal: "Vegetables", spinach: "Vegetables", beans: "Vegetables", peas: "Vegetables",
  cabbage: "Vegetables", cauliflower: "Vegetables", bitter: "Vegetables", ladyfinger: "Vegetables",
  rice: "Grains & Dal", dal: "Grains & Dal", atta: "Grains & Dal", wheat: "Grains & Dal",
  maida: "Grains & Dal", ragi: "Grains & Dal", poha: "Grains & Dal", oats: "Grains & Dal",
  milk: "Dairy", curd: "Dairy", butter: "Dairy", ghee: "Dairy", paneer: "Dairy",
  cheese: "Dairy", lassi: "Dairy", cream: "Dairy",
  fish: "Fish & Meat", chicken: "Fish & Meat", mutton: "Fish & Meat", egg: "Fish & Meat",
  prawn: "Fish & Meat", meat: "Fish & Meat",
  salt: "Spices", pepper: "Spices", turmeric: "Spices", chilli: "Spices", masala: "Spices",
  cumin: "Spices", coriander: "Spices", garam: "Spices", cardamom: "Spices",
  biscuit: "Snacks", chips: "Snacks", chocolate: "Snacks", namkeen: "Snacks",
  murukku: "Snacks", mixture: "Snacks", candy: "Snacks",
  soap: "Household", detergent: "Household", broom: "Household", mop: "Household",
  phenyl: "Household", floor: "Household", dish: "Household", trash: "Household",
  shampoo: "Personal Care", toothpaste: "Personal Care", lotion: "Personal Care",
  deo: "Personal Care", razor: "Personal Care", sanitizer: "Personal Care",
};

function guessCategory(name: string): Category {
  const lower = name.toLowerCase();
  for (const [kw, cat] of Object.entries(KEYWORDS)) {
    if (lower.includes(kw)) return CATEGORIES.find(c => c.label === cat) ?? CATEGORIES[8];
  }
  return CATEGORIES[8];
}

function fmt(d: Date) {
  return d.toLocaleString("en-IN", { day: "2-digit", month: "short", hour: "2-digit", minute: "2-digit", hour12: true });
}

interface OutletContext {
  onRoomTap: () => void;
  onNotifications: () => void;
  onCreateRoom: () => void;
  onJoinRoom: () => void;
  selectedRoomId: number;
  setSelectedRoomId: (id: number) => void;
  listItemsByRoom: Record<number, ListItem[]>;
  setListItemsByRoom: (fn: (prev: Record<number, ListItem[]>) => Record<number, ListItem[]>) => void;
}

export function HomeScreen() {
  const {
    onRoomTap, onNotifications, onCreateRoom, onJoinRoom,
    selectedRoomId, setSelectedRoomId, listItemsByRoom, setListItemsByRoom,
  } = useOutletContext<OutletContext>();
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const [inputValue, setInputValue] = useState("");
  const [showAddBar, setShowAddBar] = useState(false);
  const [pendingCategory, setPendingCategory] = useState<Category>(CATEGORIES[8]);

  const selectedRoom = rooms.find(r => r.id === selectedRoomId) ?? rooms[0];
  const listItems: ListItem[] = listItemsByRoom[selectedRoomId] ?? [];

  function updateItems(fn: (items: ListItem[]) => ListItem[]) {
    setListItemsByRoom(prev => ({ ...prev, [selectedRoomId]: fn(prev[selectedRoomId] ?? []) }));
  }

  function handleInputChange(val: string) {
    setInputValue(val);
    setPendingCategory(guessCategory(val));
  }

  function addItem() {
    const name = inputValue.trim();
    if (!name) return;
    updateItems(prev => [...prev, {
      id: Date.now(), name, bought: false, category: pendingCategory,
      showCatPicker: false, addedAt: new Date(), addedBy: "Priya",
    }]);
    setInputValue("");
    setPendingCategory(CATEGORIES[8]);
    setShowAddBar(false);
  }

  function toggleBought(id: number) {
    updateItems(prev => prev.map(i =>
      i.id === id
        ? i.bought
          ? { ...i, bought: false, boughtAt: undefined, boughtBy: undefined }
          : { ...i, bought: true, boughtAt: new Date(), boughtBy: "Priya" }
        : i
    ));
  }

  function setCategory(id: number, cat: Category) {
    updateItems(prev => prev.map(i => i.id === id ? { ...i, category: cat, showCatPicker: false } : i));
  }

  function toggleCatPicker(id: number) {
    updateItems(prev => prev.map(i => i.id === id ? { ...i, showCatPicker: !i.showCatPicker } : { ...i, showCatPicker: false }));
  }

  const pending = listItems.filter(i => !i.bought);
  const bought = listItems.filter(i => i.bought);

  const navigate = useNavigate();
  const { theme, toggle } = useTheme();
  const dark = theme === "dark";

  return (
    <div className={`h-full flex flex-col overflow-hidden ${dark ? "bg-[#0f0f1a]" : "bg-[#F7F8FA]"}`}>
      {/* Header */}
      <div className={`px-5 pt-12 pb-4 shadow-sm ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
        <div className="flex items-start justify-between mb-3">
          <div>
            <p className="text-[#6B7280] text-sm" style={{ fontFamily: "Plus Jakarta Sans" }}>Good morning,</p>
            <h1 style={{ fontFamily: "Nunito", fontWeight: 800, fontSize: "22px", color: dark ? "#ffffff" : "#1A1A2E", lineHeight: 1.2 }}>
              Priya 👋
            </h1>
          </div>
          <div className="flex items-center gap-3 pt-1">
            <motion.button onClick={toggle} whileTap={{ scale: 0.9 }}
              className="flex items-center gap-2 px-3 py-1.5 rounded-full transition-colors"
              style={{ background: dark ? "#2a2a4a" : "#F3F4F6" }}>
              {dark ? <Sun size={14} className="text-amber-400" /> : <Moon size={14} className="text-[#6B7280]" />}
              <span className="text-xs font-medium" style={{ fontFamily: "Plus Jakarta Sans", color: dark ? "#e2e8f0" : "#6B7280" }}>
                {dark ? "Light" : "Dark"}
              </span>
            </motion.button>
            <button onClick={onNotifications} className={`relative w-10 h-10 rounded-full flex items-center justify-center ${dark ? "bg-white/10" : "bg-[#F7F8FA]"}`}>
              <Bell size={20} className={dark ? "text-white" : "text-[#1A1A2E]"} />
              <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-[#FF6B35] rounded-full" />
            </button>
            <motion.button
              whileTap={{ scale: 0.9 }}
              onClick={() => navigate("/app/profile")}
              className="w-10 h-10 rounded-full bg-[#1D9E75] flex items-center justify-center"
            >
              <span className="text-white font-bold text-sm" style={{ fontFamily: "Nunito" }}>P</span>
            </motion.button>
          </div>
        </div>

        {/* Room selector */}
        <div className="relative">
          <button
            onClick={() => setDropdownOpen(v => !v)}
            className="flex items-center gap-2 px-3 py-1.5 bg-[#E8F5E9] rounded-full"
          >
            <span className="text-base leading-none">{selectedRoom.emoji}</span>
            <span className="text-[#1D9E75] text-xs font-medium" style={{ fontFamily: "Plus Jakarta Sans" }}>{selectedRoom.name}</span>
            <motion.span animate={{ rotate: dropdownOpen ? 180 : 0 }} transition={{ duration: 0.2 }}>
              <ChevronDown size={12} className="text-[#1D9E75]" />
            </motion.span>
          </button>

          <AnimatePresence>
            {dropdownOpen && (
              <motion.div
                initial={{ opacity: 0, y: -6, scale: 0.97 }}
                animate={{ opacity: 1, y: 0, scale: 1 }}
                exit={{ opacity: 0, y: -6, scale: 0.97 }}
                transition={{ duration: 0.15 }}
                className={`absolute top-full left-0 mt-2 w-56 rounded-2xl shadow-lg z-50 overflow-hidden border ${dark ? "bg-[#1a1a2e] border-white/10" : "bg-white border-gray-100"}`}
              >
                {rooms.map(room => (
                  <button
                    key={room.id}
                    onClick={() => { setSelectedRoomId(room.id); setDropdownOpen(false); }}
                    className={`w-full flex items-center gap-3 px-4 py-3 transition-colors text-left ${dark ? "hover:bg-white/5" : "hover:bg-[#F7F8FA]"}`}
                  >
                    <span className="text-xl">{room.emoji}</span>
                    <div className="flex-1 min-w-0">
                      <p style={{ fontFamily: "Nunito", fontWeight: 700, fontSize: "13px", color: dark ? "#ffffff" : "#1A1A2E" }}>{room.name}</p>
                      <p className={`text-[10px] ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>
                        {(listItemsByRoom[room.id] ?? []).filter(i => !i.bought).length} left · {room.members.length} members
                      </p>
                    </div>
                    {room.id === selectedRoomId && <Check size={14} className="text-[#1D9E75] flex-shrink-0" />}
                  </button>
                ))}
                <div className={`border-t flex ${dark ? "border-white/10" : "border-gray-100"}`}>
                  <button
                    onClick={() => { setDropdownOpen(false); onCreateRoom(); }}
                    className={`flex-1 flex items-center justify-center gap-1.5 py-3 text-[#1D9E75] transition-colors ${dark ? "hover:bg-white/5" : "hover:bg-[#F7F8FA]"}`}
                  >
                    <Plus size={14} />
                    <span className="text-xs font-medium" style={{ fontFamily: "Plus Jakarta Sans" }}>Create</span>
                  </button>
                  <div className={`w-px ${dark ? "bg-white/10" : "bg-gray-100"}`} />
                  <button
                    onClick={() => { setDropdownOpen(false); onJoinRoom(); }}
                    className={`flex-1 flex items-center justify-center gap-1.5 py-3 text-[#1D9E75] transition-colors ${dark ? "hover:bg-white/5" : "hover:bg-[#F7F8FA]"}`}
                  >
                    <LogIn size={14} />
                    <span className="text-xs font-medium" style={{ fontFamily: "Plus Jakarta Sans" }}>Join</span>
                  </button>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>

      {/* Scrollable content */}
      <div className="flex-1 overflow-y-auto" onClick={() => dropdownOpen && setDropdownOpen(false)}>
        <div className="px-5 pb-24">
          {/* Section header */}
          <div className="flex items-center justify-between mb-3 pt-4">
            <h2 style={{ fontFamily: "Nunito", fontWeight: 700, fontSize: "16px", color: dark ? "#ffffff" : "#1A1A2E" }}>
              {selectedRoom.emoji} {selectedRoom.name} List
            </h2>
            <span className="text-xs text-[#6B7280]" style={{ fontFamily: "Plus Jakarta Sans" }}>
              {pending.length} left · {bought.length} done
            </span>
          </div>

          {/* Plus bar */}
          <div className="mb-4">
            <motion.button whileTap={{ scale: 0.98 }} onClick={() => setShowAddBar(v => !v)}
              className={`w-full flex items-center gap-3 rounded-2xl px-4 py-3 shadow-sm border border-dashed border-[#1D9E75]/40 ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
              <div className="w-6 h-6 rounded-full bg-[#1D9E75] flex items-center justify-center flex-shrink-0">
                <Plus size={14} className="text-white" />
              </div>
              <span className="text-sm text-[#9CA3AF]" style={{ fontFamily: "Plus Jakarta Sans" }}>Add item or service…</span>
            </motion.button>

            <AnimatePresence>
              {showAddBar && (
                <motion.div initial={{ height: 0, opacity: 0 }} animate={{ height: "auto", opacity: 1 }}
                  exit={{ height: 0, opacity: 0 }} transition={{ duration: 0.2 }} className="overflow-hidden">
                  <div className={`rounded-2xl shadow-sm border border-[#1D9E75]/20 mt-2 p-3 flex flex-col gap-2 ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
                    <input autoFocus value={inputValue} onChange={e => handleInputChange(e.target.value)}
                      onKeyDown={e => e.key === "Enter" && addItem()}
                      placeholder="e.g. Tomatoes, Milk, Soap…"
                      className={`w-full text-sm outline-none bg-transparent placeholder-gray-300 px-1 ${dark ? "text-white" : "text-[#1A1A2E]"}`}
                      style={{ fontFamily: "Plus Jakarta Sans" }} />
                    <div className="flex items-center gap-2 flex-wrap">
                      {CATEGORIES.map(c => (
                        <button key={c.label} onClick={() => setPendingCategory(c)}
                          className="flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-medium transition-all"
                          style={{
                            background: pendingCategory.label === c.label ? c.bg : "#F3F4F6",
                            color: pendingCategory.label === c.label ? c.color : "#9CA3AF",
                            fontFamily: "Plus Jakarta Sans",
                            outline: pendingCategory.label === c.label ? `1.5px solid ${c.color}` : "none",
                          }}>
                          {c.emoji} {c.label}
                        </button>
                      ))}
                      <motion.button whileTap={{ scale: 0.9 }} onClick={addItem}
                        className="w-9 h-9 rounded-xl bg-[#1D9E75] flex items-center justify-center flex-shrink-0">
                        <Check size={15} className="text-white" />
                      </motion.button>
                    </div>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </div>

          {/* Pending items */}
          {pending.length > 0 && (
            <div className={`rounded-2xl shadow-sm overflow-hidden mb-4 ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
              {[...pending].reverse().map((item, idx) => (
                <div key={item.id}>
                  <div className={`flex items-start gap-3 px-4 py-3 ${idx < pending.length - 1 ? `border-b ${dark ? "border-white/5" : "border-gray-50"}` : ""}`}>
                    <button onClick={() => toggleBought(item.id)}
                      className="w-5 h-5 rounded-full border-2 flex-shrink-0 mt-0.5 transition-colors"
                      style={{ borderColor: item.category.color }} />
                    <div className="flex-1 min-w-0">
                      <span className={`text-sm ${dark ? "text-white" : "text-[#1A1A2E]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>{item.name}</span>
                      <p className="text-[10px] text-[#9CA3AF] mt-0.5" style={{ fontFamily: "Plus Jakarta Sans" }}>
                        {fmt(item.addedAt)} · {item.addedBy}
                      </p>
                    </div>
                    <button onClick={() => toggleCatPicker(item.id)}
                      className="flex items-center gap-0.5 px-2 py-0.5 rounded-full text-[10px] font-medium flex-shrink-0 mt-0.5"
                      style={{ background: item.category.bg, color: item.category.color, fontFamily: "Plus Jakarta Sans" }}>
                      {item.category.emoji} {item.category.label}
                      <ChevronRight size={9} className="ml-0.5" />
                    </button>
                  </div>
                  <AnimatePresence>
                    {item.showCatPicker && (
                      <motion.div initial={{ height: 0, opacity: 0 }} animate={{ height: "auto", opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }} transition={{ duration: 0.15 }}
                        className={`overflow-hidden border-t ${dark ? "bg-[#111124] border-white/5" : "bg-[#F7F8FA] border-gray-50"}`}>
                        <div className="flex flex-wrap gap-1.5 px-4 py-2.5">
                          {CATEGORIES.map(c => (
                            <button key={c.label} onClick={() => setCategory(item.id, c)}
                              className="flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-medium"
                              style={{ background: c.bg, color: c.color, fontFamily: "Plus Jakarta Sans", outline: c.label === item.category.label ? `1.5px solid ${c.color}` : "none" }}>
                              {c.emoji} {c.label}
                            </button>
                          ))}
                        </div>
                      </motion.div>
                    )}
                  </AnimatePresence>
                </div>
              ))}
            </div>
          )}

          {pending.length === 0 && (
            <div className="text-center py-10">
              <span className="text-4xl">✅</span>
              <p className="text-sm text-[#6B7280] mt-3" style={{ fontFamily: "Plus Jakarta Sans" }}>All done! Add items above.</p>
            </div>
          )}

          {/* Bought items */}
          {bought.length > 0 && (
            <div>
              <p className={`text-xs uppercase tracking-wider mb-2 px-1 ${dark ? "text-gray-500" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>
                ✓ Bought ({bought.length})
              </p>
              <div className={`rounded-2xl shadow-sm overflow-hidden opacity-60 ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
                {bought.map((item, idx) => (
                  <div key={item.id}
                    className={`flex items-start gap-3 px-4 py-3 ${idx < bought.length - 1 ? `border-b ${dark ? "border-white/5" : "border-gray-50"}` : ""}`}>
                    <button onClick={() => toggleBought(item.id)}
                      className="w-5 h-5 rounded-full flex-shrink-0 flex items-center justify-center bg-[#1D9E75] mt-0.5">
                      <Check size={11} className="text-white" />
                    </button>
                    <div className="flex-1 min-w-0">
                      <span className={`text-sm line-through ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>{item.name}</span>
                      <p className="text-[10px] text-[#9CA3AF] mt-0.5" style={{ fontFamily: "Plus Jakarta Sans" }}>
                        {fmt(item.addedAt)} · {item.addedBy}
                        {item.boughtAt && <> · ✓ {fmt(item.boughtAt)}</>}
                      </p>
                    </div>
                    <span className="text-[10px] px-2 py-0.5 rounded-full mt-0.5 flex-shrink-0"
                      style={{ background: item.category.bg, color: item.category.color, fontFamily: "Plus Jakarta Sans" }}>
                      {item.category.emoji} {item.category.label}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
