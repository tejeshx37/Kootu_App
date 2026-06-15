import { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { X, Hash, Smile, Copy, Share2, Check } from "lucide-react";
import { useTheme } from "../context/ThemeContext";

const emojiOptions = ["🏠", "🍱", "🍖", "🎉", "👨‍👩‍👧‍👦", "🛒", "🍕", "☕", "🎂", "🌮", "🍜", "🥗"];

interface CreateRoomSheetProps {
  onClose: () => void;
  onCreate: (room: { name: string; emoji: string }) => void;
}

const generateRoomId = () => Math.random().toString(36).substring(2, 8).toUpperCase();

export function CreateRoomSheet({ onClose, onCreate }: CreateRoomSheetProps) {
  const { theme } = useTheme();
  const dark = theme === "dark";
  const [step, setStep] = useState<"create" | "success">("create");
  const [roomName, setRoomName] = useState("");
  const [selectedEmoji, setSelectedEmoji] = useState("🏠");
  const [roomId, setRoomId] = useState("");
  const [copied, setCopied] = useState(false);

  const handleCreate = () => {
    if (roomName.trim()) {
      const newRoomId = generateRoomId();
      setRoomId(newRoomId);
      setStep("success");
      onCreate({ name: roomName.trim(), emoji: selectedEmoji });
    }
  };

  const handleCopyRoomId = () => {
    navigator.clipboard.writeText(roomId);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleShare = () => {
    const shareText = `Join my Kootu room "${roomName}" ${selectedEmoji}\nRoom ID: ${roomId}\n\nDownload Kootu to start shopping together!`;
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
            <h2 style={{ fontFamily: "Nunito", fontWeight: 800, fontSize: "20px", color: dark ? "#ffffff" : "#1A1A2E" }}>
              {step === "create" ? "Create New Room" : "Room Created!"}
            </h2>
            <button onClick={onClose} className={`w-8 h-8 rounded-full flex items-center justify-center ${dark ? "bg-white/10" : "bg-gray-100"}`}>
              <X size={18} className={dark ? "text-gray-300" : "text-[#6B7280]"} />
            </button>
          </div>

          {step === "create" ? (
            <>
              <div className="overflow-y-auto px-5 pt-4 pb-6" style={{ maxHeight: "calc(85vh - 140px)" }}>
                <div className="mb-5">
                  <label className="flex items-center gap-2 mb-3">
                    <Smile size={16} className="text-[#1D9E75]" />
                    <span style={{ fontFamily: "Plus Jakarta Sans", fontWeight: 600, fontSize: "14px", color: dark ? "#ffffff" : "#1A1A2E" }}>Choose an emoji</span>
                  </label>
                  <div className="grid grid-cols-6 gap-2">
                    {emojiOptions.map(emoji => (
                      <button key={emoji} onClick={() => setSelectedEmoji(emoji)}
                        className="aspect-square rounded-xl flex items-center justify-center text-2xl transition-all"
                        style={{ background: selectedEmoji === emoji ? "#E8F5E9" : dark ? "rgba(255,255,255,0.06)" : "#F7F8FA", border: selectedEmoji === emoji ? "2px solid #1D9E75" : "2px solid transparent" }}>
                        {emoji}
                      </button>
                    ))}
                  </div>
                </div>

                <div className="mb-5">
                  <label className="flex items-center gap-2 mb-3">
                    <Hash size={16} className="text-[#1D9E75]" />
                    <span style={{ fontFamily: "Plus Jakarta Sans", fontWeight: 600, fontSize: "14px", color: dark ? "#ffffff" : "#1A1A2E" }}>Room name</span>
                  </label>
                  <input type="text" value={roomName} onChange={(e) => setRoomName(e.target.value)} placeholder="e.g., Family Room, Weekend BBQ"
                    className={`w-full px-4 py-3.5 rounded-xl border-2 border-transparent focus:border-[#1D9E75] outline-none transition-colors placeholder:text-gray-400 ${dark ? "bg-[#0f0f1a] text-white" : "bg-[#F7F8FA] text-[#1A1A2E]"}`}
                    style={{ fontFamily: "Plus Jakarta Sans", fontSize: "15px" }} />
                </div>
              </div>

              <div className={`border-t px-5 py-4 ${dark ? "border-white/5" : "border-gray-100"}`}>
                <button onClick={handleCreate} disabled={!roomName.trim()}
                  className="w-full py-4 rounded-xl font-bold text-white transition-all"
                  style={{ fontFamily: "Nunito", fontSize: "16px", background: roomName.trim() ? "#1D9E75" : dark ? "#2a2a4a" : "#e5e7eb", color: roomName.trim() ? "white" : dark ? "#6B7280" : "#9ca3af" }}>
                  Create Room
                </button>
              </div>
            </>
          ) : (
            <>
              <div className="overflow-y-auto px-5 pt-6 pb-6" style={{ maxHeight: "calc(85vh - 140px)" }}>
                <div className="flex flex-col items-center mb-6">
                  <motion.div initial={{ scale: 0 }} animate={{ scale: 1 }} transition={{ type: "spring", damping: 15, stiffness: 200 }}
                    className="w-20 h-20 rounded-2xl bg-[#E8F5E9] flex items-center justify-center text-4xl mb-4">{selectedEmoji}</motion.div>
                  <h3 style={{ fontFamily: "Nunito", fontWeight: 700, fontSize: "18px", color: dark ? "#ffffff" : "#1A1A2E" }}>{roomName}</h3>
                  <p className={`text-sm mt-1 ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>Your room is ready!</p>
                </div>

                <div className="bg-gradient-to-br from-[#1D9E75] to-[#17875f] rounded-2xl p-5 mb-4">
                  <p className="text-white/70 text-xs mb-2" style={{ fontFamily: "Plus Jakarta Sans" }}>Room ID</p>
                  <div className="flex items-center justify-between">
                    <p className="text-white text-3xl tracking-wider" style={{ fontFamily: "Nunito", fontWeight: 800 }}>{roomId}</p>
                    <button onClick={handleCopyRoomId} className="w-10 h-10 rounded-xl bg-white/20 flex items-center justify-center backdrop-blur">
                      {copied ? <Check size={18} className="text-white" /> : <Copy size={18} className="text-white" />}
                    </button>
                  </div>
                </div>

                <div className="bg-[#E8F5E9] rounded-xl p-4 mb-4">
                  <p className="text-sm text-[#1A1A2E]" style={{ fontFamily: "Plus Jakarta Sans" }}>Share this Room ID with your family members so they can join and start shopping together!</p>
                </div>

                <button onClick={handleShare} className="w-full py-4 rounded-xl font-bold flex items-center justify-center gap-2 bg-[#1D9E75] text-white mb-3" style={{ fontFamily: "Nunito", fontSize: "16px" }}>
                  <Share2 size={18} />Share Room ID
                </button>
              </div>

              <div className={`border-t px-5 py-4 ${dark ? "border-white/5" : "border-gray-100"}`}>
                <button onClick={onClose} className={`w-full py-4 rounded-xl font-bold text-[#1D9E75] ${dark ? "bg-[#1D9E75]/15" : "bg-[#E8F5E9]"}`} style={{ fontFamily: "Nunito", fontSize: "16px" }}>Done</button>
              </div>
            </>
          )}
        </motion.div>
      </motion.div>
    </AnimatePresence>
  );
}
