import { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { Mic, ScanBarcode, X, Plus } from "lucide-react";
import { useTheme } from "../context/ThemeContext";

const suggestions = ["Basmati Rice", "Toor Dal", "Coconut Oil", "Turmeric", "Coriander", "Green Chilli"];
const quickItems = ["🍚 Rice", "🫘 Dal", "🛢️ Oil", "🥛 Curd", "🥚 Eggs", "🍞 Bread", "🧅 Onion", "🍅 Tomato", "🫙 Ghee", "☕ Tea"];

interface AddItemSheetProps {
  onClose: () => void;
  onAdd: (item: string) => void;
}

export function AddItemSheet({ onClose, onAdd }: AddItemSheetProps) {
  const { theme } = useTheme();
  const dark = theme === "dark";
  const [text, setText] = useState("");
  const [recording, setRecording] = useState(false);
  const [added, setAdded] = useState<string[]>([]);

  const toggleRecording = () => {
    setRecording(r => !r);
    if (recording) setText("Basmati Rice 2 kg");
  };

  const addItem = (name: string) => {
    if (!name.trim()) return;
    setAdded(prev => [...prev, name]);
    setText("");
  };

  const handleAdd = () => {
    addItem(text || "Item");
    setTimeout(() => { onAdd(text || "Item"); onClose(); }, 300);
  };

  return (
    <motion.div initial={{ y: "100%" }} animate={{ y: 0 }} exit={{ y: "100%" }} transition={{ type: "spring", damping: 28, stiffness: 300 }} className="absolute inset-0 z-50 flex flex-col">
      <div className="flex-1 bg-black/50 backdrop-blur-sm" onClick={onClose} />
      <div className={`rounded-t-[28px] px-5 pt-3 pb-8 ${dark ? "bg-[#1a1a2e]" : "bg-white"}`} style={{ maxHeight: "85%" }}>
        <div className="flex justify-center mb-4">
          <div className={`w-10 h-1 rounded-full ${dark ? "bg-white/20" : "bg-gray-200"}`} />
        </div>
        <div className="flex items-center justify-between mb-6">
          <h2 style={{ fontFamily: "Nunito", fontWeight: 800, fontSize: "20px", color: dark ? "#ffffff" : "#1A1A2E" }}>Add to Family Room</h2>
          <button onClick={onClose} className={`w-9 h-9 rounded-full flex items-center justify-center ${dark ? "bg-white/10" : "bg-[#F7F8FA]"}`}>
            <X size={18} className={dark ? "text-gray-300" : "text-[#6B7280]"} />
          </button>
        </div>

        <div className="flex flex-col items-center mb-6">
          <div className="relative mb-3">
            {recording && (
              <>
                <motion.div animate={{ scale: [1, 1.4, 1], opacity: [0.3, 0, 0.3] }} transition={{ repeat: Infinity, duration: 1.5 }} className="absolute inset-0 rounded-full bg-[#1D9E75]" style={{ margin: -12 }} />
                <motion.div animate={{ scale: [1, 1.7, 1], opacity: [0.15, 0, 0.15] }} transition={{ repeat: Infinity, duration: 1.5, delay: 0.3 }} className="absolute inset-0 rounded-full bg-[#1D9E75]" style={{ margin: -24 }} />
              </>
            )}
            <motion.button onClick={toggleRecording} whileTap={{ scale: 0.9 }}
              className="relative w-20 h-20 rounded-full flex items-center justify-center shadow-lg"
              style={{ background: recording ? "#1D9E75" : dark ? "#2a2a4a" : "#F7F8FA" }}>
              <Mic size={32} className={recording ? "text-white" : dark ? "text-gray-300" : "text-[#1A1A2E]"} />
            </motion.button>
          </div>
          <p className={`text-sm ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>
            {recording ? "Listening… tap to stop" : "Tap to speak"}
          </p>
        </div>

        <div className="flex gap-2 mb-4">
          <div className={`flex-1 flex items-center gap-2 rounded-xl px-4 py-3 border ${dark ? "bg-[#0f0f1a] border-white/10" : "bg-[#F7F8FA] border-gray-100"}`}>
            <input value={text} onChange={e => setText(e.target.value)} placeholder="Type item name & quantity…"
              className={`flex-1 bg-transparent outline-none placeholder:text-gray-400 ${dark ? "text-white" : "text-[#1A1A2E]"}`}
              style={{ fontFamily: "Plus Jakarta Sans", fontSize: "15px" }} />
            <button className={dark ? "text-gray-500" : "text-[#6B7280]"}>
              <ScanBarcode size={18} />
            </button>
          </div>
        </div>

        <div className="mb-4">
          <p className={`text-xs uppercase tracking-wider mb-2 ${dark ? "text-gray-500" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>Recent in this room</p>
          <div className="flex flex-wrap gap-2">
            {suggestions.map(s => (
              <button key={s} onClick={() => setText(s)} className="px-3 py-1.5 bg-[#E8F5E9] rounded-full text-[#1D9E75] text-sm font-medium border border-[#1D9E75]/20" style={{ fontFamily: "Plus Jakarta Sans" }}>{s}</button>
            ))}
          </div>
        </div>

        <div className="mb-6">
          <p className={`text-xs uppercase tracking-wider mb-2 ${dark ? "text-gray-500" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>Quick add</p>
          <div className="flex flex-wrap gap-2">
            {quickItems.map(item => (
              <motion.button key={item} whileTap={{ scale: 0.94 }} onClick={() => addItem(item.replace(/^[^\s]+\s/, ""))}
                className={`flex items-center gap-1 px-3 py-1.5 rounded-full text-sm border transition-all ${
                  added.includes(item.replace(/^[^\s]+\s/, ""))
                    ? "bg-[#1D9E75] text-white border-[#1D9E75]"
                    : dark ? "bg-white/10 text-gray-300 border-white/10" : "bg-white text-[#1A1A2E] border-gray-200"
                }`}
                style={{ fontFamily: "Plus Jakarta Sans" }}>
                <span>{item}</span>
                <Plus size={12} className={added.includes(item.replace(/^[^\s]+\s/, "")) ? "text-white" : dark ? "text-gray-400" : "text-[#6B7280]"} />
              </motion.button>
            ))}
          </div>
        </div>

        <motion.button onClick={handleAdd} whileTap={{ scale: 0.97 }} className="w-full py-4 rounded-2xl text-white shadow-lg" style={{ background: "#1D9E75", fontFamily: "Nunito", fontWeight: 700, fontSize: "16px" }}>
          {added.length > 0 ? `Add ${added.length + (text ? 1 : 0)} item${added.length + (text ? 1 : 0) > 1 ? "s" : ""} to Room` : "Add to Room"}
        </motion.button>
      </div>
    </motion.div>
  );
}
