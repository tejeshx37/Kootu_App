import { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { X, Copy, Share2, Check, Users, Hash } from "lucide-react";
import { useTheme } from "../context/ThemeContext";

interface RoomInfoSheetProps {
  onClose: () => void;
  roomName: string;
  roomEmoji: string;
  roomId: string;
  members: string[];
}

export function RoomInfoSheet({ onClose, roomName, roomEmoji, roomId, members }: RoomInfoSheetProps) {
  const { theme } = useTheme();
  const dark = theme === "dark";
  const [copied, setCopied] = useState(false);

  const handleCopyRoomId = () => {
    navigator.clipboard.writeText(roomId);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleShare = () => {
    const shareText = `Join my Kootu room "${roomName}" ${roomEmoji}\nRoom ID: ${roomId}\n\nDownload Kootu to start shopping together!`;
    if (navigator.share) { navigator.share({ text: shareText }); }
    else { navigator.clipboard.writeText(shareText); setCopied(true); setTimeout(() => setCopied(false), 2000); }
  };

  return (
    <AnimatePresence>
      <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="absolute inset-0 bg-black/50 z-50" onClick={onClose}>
        <motion.div initial={{ y: "100%" }} animate={{ y: 0 }} exit={{ y: "100%" }} transition={{ type: "spring", damping: 28, stiffness: 280 }}
          onClick={(e) => e.stopPropagation()}
          className={`absolute bottom-0 left-0 right-0 rounded-t-[28px] shadow-2xl ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}
          style={{ maxHeight: "85%" }}>
          <div className="w-full pt-3 pb-2 flex justify-center">
            <div className={`w-10 h-1 rounded-full ${dark ? "bg-white/20" : "bg-gray-200"}`} />
          </div>

          <div className={`flex items-center justify-between px-5 pb-4 border-b ${dark ? "border-white/5" : "border-gray-100"}`}>
            <h2 style={{ fontFamily: "Nunito", fontWeight: 800, fontSize: "20px", color: dark ? "#ffffff" : "#1A1A2E" }}>Room Info</h2>
            <button onClick={onClose} className={`w-8 h-8 rounded-full flex items-center justify-center ${dark ? "bg-white/10" : "bg-gray-100"}`}>
              <X size={18} className={dark ? "text-gray-300" : "text-[#6B7280]"} />
            </button>
          </div>

          <div className="overflow-y-auto px-5 pt-6 pb-6" style={{ maxHeight: "calc(85vh - 140px)" }}>
            <div className="flex flex-col items-center mb-6">
              <div className="w-20 h-20 rounded-2xl bg-[#E8F5E9] flex items-center justify-center text-4xl mb-4">{roomEmoji}</div>
              <h3 style={{ fontFamily: "Nunito", fontWeight: 700, fontSize: "18px", color: dark ? "#ffffff" : "#1A1A2E" }}>{roomName}</h3>
              <div className="flex items-center gap-2 mt-2">
                <Users size={14} className={dark ? "text-gray-400" : "text-[#6B7280]"} />
                <span className={`text-sm ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>{members.length} members</span>
              </div>
            </div>

            <div className="mb-4">
              <label className="flex items-center gap-2 mb-3">
                <Hash size={16} className="text-[#1D9E75]" />
                <span style={{ fontFamily: "Plus Jakarta Sans", fontWeight: 600, fontSize: "14px", color: dark ? "#ffffff" : "#1A1A2E" }}>Room ID</span>
              </label>
              <div className="bg-gradient-to-br from-[#1D9E75] to-[#17875f] rounded-2xl p-5">
                <div className="flex items-center justify-between">
                  <p className="text-white text-3xl tracking-wider" style={{ fontFamily: "Nunito", fontWeight: 800 }}>{roomId}</p>
                  <button onClick={handleCopyRoomId} className="w-10 h-10 rounded-xl bg-white/20 flex items-center justify-center backdrop-blur">
                    {copied ? <Check size={18} className="text-white" /> : <Copy size={18} className="text-white" />}
                  </button>
                </div>
              </div>
            </div>

            <div className="mb-4">
              <label className="flex items-center gap-2 mb-3">
                <Users size={16} className="text-[#1D9E75]" />
                <span style={{ fontFamily: "Plus Jakarta Sans", fontWeight: 600, fontSize: "14px", color: dark ? "#ffffff" : "#1A1A2E" }}>Members</span>
              </label>
              <div className={`rounded-2xl border overflow-hidden ${dark ? "bg-[#0f0f1a] border-white/5" : "bg-white border-gray-100"}`}>
                {members.map((member, idx) => (
                  <div key={idx} className={`flex items-center gap-3 px-4 py-3 ${idx < members.length - 1 ? `border-b ${dark ? "border-white/5" : "border-gray-50"}` : ""}`}>
                    <div className="w-10 h-10 rounded-full bg-[#E8F5E9] flex items-center justify-center text-xl">{member}</div>
                    <div className="flex-1">
                      <p style={{ fontFamily: "Plus Jakarta Sans", fontWeight: 500, fontSize: "14px", color: dark ? "#ffffff" : "#1A1A2E" }}>{idx === 0 ? "You" : `Member ${idx + 1}`}</p>
                      <p className={`text-xs ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>{idx === 0 ? "Admin" : "Member"}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            <div className="bg-[#E8F5E9] rounded-xl p-4 mb-4">
              <p className="text-sm text-[#1A1A2E]" style={{ fontFamily: "Plus Jakarta Sans" }}>
                💡 Share the Room ID with family members so they can join and collaborate on your shopping list!
              </p>
            </div>

            <button onClick={handleShare} className="w-full py-4 rounded-xl font-bold flex items-center justify-center gap-2 bg-[#1D9E75] text-white" style={{ fontFamily: "Nunito", fontSize: "16px" }}>
              <Share2 size={18} />Share Room ID
            </button>
          </div>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  );
}
