import { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { X, LogIn, AlertCircle } from "lucide-react";
import { useTheme } from "../context/ThemeContext";

interface JoinRoomSheetProps {
  onClose: () => void;
  onJoin: (roomId: string) => void;
}

export function JoinRoomSheet({ onClose, onJoin }: JoinRoomSheetProps) {
  const { theme } = useTheme();
  const dark = theme === "dark";
  const [roomId, setRoomId] = useState("");
  const [error, setError] = useState("");

  const handleJoin = () => {
    const trimmedId = roomId.trim().toUpperCase();
    if (!trimmedId) { setError("Please enter a Room ID"); return; }
    if (trimmedId.length !== 6) { setError("Room ID must be 6 characters"); return; }
    onJoin(trimmedId);
    onClose();
  };

  const handleInputChange = (value: string) => {
    const cleaned = value.replace(/[^a-zA-Z0-9]/g, '').toUpperCase();
    setRoomId(cleaned.slice(0, 6));
    setError("");
  };

  return (
    <AnimatePresence>
      <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="absolute inset-0 bg-black/50 z-50" onClick={onClose}>
        <motion.div initial={{ y: "100%" }} animate={{ y: 0 }} exit={{ y: "100%" }} transition={{ type: "spring", damping: 28, stiffness: 280 }}
          onClick={(e) => e.stopPropagation()}
          className={`absolute bottom-0 left-0 right-0 rounded-t-[28px] shadow-2xl ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
          <div className="w-full pt-3 pb-2 flex justify-center">
            <div className={`w-10 h-1 rounded-full ${dark ? "bg-white/20" : "bg-gray-200"}`} />
          </div>

          <div className={`flex items-center justify-between px-5 pb-4 border-b ${dark ? "border-white/5" : "border-gray-100"}`}>
            <h2 style={{ fontFamily: "Nunito", fontWeight: 800, fontSize: "20px", color: dark ? "#ffffff" : "#1A1A2E" }}>Join Room</h2>
            <button onClick={onClose} className={`w-8 h-8 rounded-full flex items-center justify-center ${dark ? "bg-white/10" : "bg-gray-100"}`}>
              <X size={18} className={dark ? "text-gray-300" : "text-[#6B7280]"} />
            </button>
          </div>

          <div className="px-5 pt-6 pb-6">
            <div className="flex justify-center mb-6">
              <div className="w-16 h-16 rounded-2xl bg-[#E8F5E9] flex items-center justify-center">
                <LogIn size={28} className="text-[#1D9E75]" />
              </div>
            </div>

            <div className="text-center mb-6">
              <p className={`text-sm ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>
                Enter the 6-character Room ID shared by your family member to join their shopping room.
              </p>
            </div>

            <div className="mb-4">
              <label className="block mb-3">
                <span style={{ fontFamily: "Plus Jakarta Sans", fontWeight: 600, fontSize: "14px", color: dark ? "#ffffff" : "#1A1A2E" }}>Room ID</span>
              </label>
              <input type="text" value={roomId} onChange={(e) => handleInputChange(e.target.value)} placeholder="Enter 6-digit code" maxLength={6}
                className={`w-full px-4 py-4 rounded-xl border-2 border-transparent focus:border-[#1D9E75] outline-none transition-colors text-center tracking-widest uppercase ${dark ? "bg-[#0f0f1a] text-white" : "bg-[#F7F8FA] text-[#1A1A2E]"}`}
                style={{ fontFamily: "Nunito", fontSize: "24px", fontWeight: 700, letterSpacing: "0.2em" }} />
              {error && (
                <motion.div initial={{ opacity: 0, y: -5 }} animate={{ opacity: 1, y: 0 }}
                  className={`flex items-center gap-2 mt-3 px-3 py-2 rounded-lg ${dark ? "bg-red-900/20" : "bg-red-50"}`}>
                  <AlertCircle size={14} className="text-red-500" />
                  <span className="text-xs text-red-500" style={{ fontFamily: "Plus Jakarta Sans" }}>{error}</span>
                </motion.div>
              )}
            </div>

            <div className={`rounded-xl p-4 mb-6 ${dark ? "bg-white/5" : "bg-[#F7F8FA]"}`}>
              <p className={`text-xs ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>
                💡 <strong>Tip:</strong> Ask your family member to share their Room ID from the room details screen.
              </p>
            </div>
          </div>

          <div className={`border-t px-5 py-4 ${dark ? "border-white/5" : "border-gray-100"}`}>
            <button onClick={handleJoin} disabled={roomId.length !== 6}
              className="w-full py-4 rounded-xl font-bold text-white transition-all"
              style={{ fontFamily: "Nunito", fontSize: "16px", background: roomId.length === 6 ? "#1D9E75" : dark ? "#2a2a4a" : "#e5e7eb", color: roomId.length === 6 ? "white" : dark ? "#6B7280" : "#9ca3af" }}>
              Join Room
            </button>
          </div>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  );
}
