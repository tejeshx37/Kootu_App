import { motion } from "motion/react";
import { ArrowLeft, Plus, LogIn } from "lucide-react";
import { useNavigate } from "react-router";
import { useOutletContext } from "react-router";
import { useTheme } from "../context/ThemeContext";

const myRooms = [
  { name: "Family Room", emoji: "🏠", members: ["👩", "👨", "👧"], count: 8, needed: 3 },
  { name: "Work Lunch", emoji: "🍱", members: ["👩", "👦"], count: 5, needed: 1 },
  { name: "Weekend BBQ", emoji: "🍖", members: ["👨", "👩", "👦", "👧"], count: 12, needed: 5 },
];

interface OutletContext {
  onRoomTap: () => void;
  onCreateRoom: () => void;
  onJoinRoom: () => void;
}

export function ProfileRoomsScreen() {
  const navigate = useNavigate();
  const { onRoomTap, onCreateRoom, onJoinRoom } = useOutletContext<OutletContext>();
  const { theme } = useTheme();
  const dark = theme === "dark";

  return (
    <div className={`h-full flex flex-col ${dark ? "bg-[#0f0f1a]" : "bg-[#F7F8FA]"}`}>
      <div className={`px-5 pt-12 pb-4 shadow-sm flex items-center gap-3 ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
        <button onClick={() => navigate("/app/profile")} className={`w-9 h-9 rounded-full flex items-center justify-center flex-shrink-0 ${dark ? "bg-white/10" : "bg-[#F7F8FA]"}`}>
          <ArrowLeft size={18} className={dark ? "text-white" : "text-[#1A1A2E]"} />
        </button>
        <div>
          <h1 style={{ fontFamily: "Nunito", fontWeight: 800, fontSize: "20px", color: dark ? "#ffffff" : "#1A1A2E" }}>My Rooms</h1>
          <p className={`text-xs mt-0.5 ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>{myRooms.length} shared shopping spaces</p>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-5 pt-4 pb-24">
        <div className={`rounded-2xl shadow-sm overflow-hidden mb-4 ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
          {myRooms.map((room, i) => (
            <motion.button key={i} onClick={onRoomTap} whileTap={{ scale: 0.99 }}
              initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.07 }}
              className={`w-full flex items-center gap-4 px-4 py-4 text-left ${i < myRooms.length - 1 ? `border-b ${dark ? "border-white/5" : "border-gray-50"}` : ""}`}>
              <div className="w-14 h-14 rounded-2xl bg-[#E8F5E9] flex items-center justify-center text-3xl flex-shrink-0">{room.emoji}</div>
              <div className="flex-1">
                <p style={{ fontFamily: "Nunito", fontWeight: 700, fontSize: "15px", color: dark ? "#ffffff" : "#1A1A2E" }}>{room.name}</p>
                <div className="flex items-center gap-2 mt-1">
                  <div className="flex -space-x-1">
                    {room.members.map((m, j) => (
                      <div key={j} className={`w-5 h-5 rounded-full flex items-center justify-center text-xs border ${dark ? "bg-white/10 border-[#1a1a2e]" : "bg-gray-100 border-white"}`}>{m}</div>
                    ))}
                  </div>
                  <span className={`text-xs ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>{room.count} items</span>
                </div>
              </div>
              {room.needed > 0 && (
                <span className="px-2.5 py-1 bg-[#FF6B35]/10 text-[#FF6B35] rounded-full text-xs font-bold" style={{ fontFamily: "Nunito" }}>{room.needed} needed</span>
              )}
            </motion.button>
          ))}
        </div>

        <div className="flex gap-3">
          <button onClick={onCreateRoom}
            className={`flex-1 border-2 border-dashed rounded-2xl py-5 flex items-center justify-center gap-2 transition-colors ${dark ? "border-white/10 text-gray-400 hover:border-[#1D9E75] hover:text-[#1D9E75] bg-[#1a1a2e]" : "border-gray-200 text-[#6B7280] hover:border-[#1D9E75] hover:text-[#1D9E75] bg-white"}`}>
            <Plus size={20} />
            <span style={{ fontFamily: "Plus Jakarta Sans", fontSize: "14px", fontWeight: 500 }}>Create Room</span>
          </button>
          <button onClick={onJoinRoom}
            className={`flex-1 border-2 border-dashed rounded-2xl py-5 flex items-center justify-center gap-2 transition-colors ${dark ? "border-white/10 text-gray-400 hover:border-[#1D9E75] hover:text-[#1D9E75] bg-[#1a1a2e]" : "border-gray-200 text-[#6B7280] hover:border-[#1D9E75] hover:text-[#1D9E75] bg-white"}`}>
            <LogIn size={20} />
            <span style={{ fontFamily: "Plus Jakarta Sans", fontSize: "14px", fontWeight: 500 }}>Join Room</span>
          </button>
        </div>
      </div>
    </div>
  );
}
