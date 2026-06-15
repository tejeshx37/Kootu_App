import { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { ArrowLeft, Pencil, Check, X } from "lucide-react";
import { useNavigate } from "react-router";
import { useTheme } from "../context/ThemeContext";

interface Contact { id: number; realName: string; emoji: string; phone: string; rooms: string[] }
interface NicknameMap { [id: number]: string }

const contacts: Contact[] = [
  { id: 1, realName: "Rajan Kumar", emoji: "👨", phone: "+91 98400 12345", rooms: ["Family Room", "Weekend BBQ"] },
  { id: 2, realName: "Kavya Rajan", emoji: "👧", phone: "+91 98400 23456", rooms: ["Family Room"] },
  { id: 3, realName: "Arjun Mehta", emoji: "👦", phone: "+91 98400 34567", rooms: ["Work Lunch", "Weekend BBQ"] },
  { id: 4, realName: "Deepa Nair", emoji: "👩", phone: "+91 98400 45678", rooms: ["Work Lunch"] },
  { id: 5, realName: "Suresh Pillai", emoji: "👴", phone: "+91 98400 56789", rooms: ["Weekend BBQ"] },
];

export function ProfileNicknamesScreen() {
  const navigate = useNavigate();
  const { theme } = useTheme();
  const dark = theme === "dark";
  const [nicknames, setNicknames] = useState<NicknameMap>({ 1: "Appa", 2: "Kavya" });
  const [editing, setEditing] = useState<number | null>(null);
  const [draft, setDraft] = useState("");

  function startEdit(contact: Contact) { setEditing(contact.id); setDraft(nicknames[contact.id] ?? ""); }
  function saveEdit(id: number) { setNicknames(prev => ({ ...prev, [id]: draft.trim() })); setEditing(null); }
  function clearNickname(id: number) { setNicknames(prev => { const next = { ...prev }; delete next[id]; return next; }); setEditing(null); }

  return (
    <div className={`h-full flex flex-col ${dark ? "bg-[#0f0f1a]" : "bg-[#F7F8FA]"}`}>
      <div className={`px-5 pt-12 pb-4 shadow-sm flex items-center gap-3 ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
        <button onClick={() => navigate("/app/profile")} className={`w-9 h-9 rounded-full flex items-center justify-center flex-shrink-0 ${dark ? "bg-white/10" : "bg-[#F7F8FA]"}`}>
          <ArrowLeft size={18} className={dark ? "text-white" : "text-[#1A1A2E]"} />
        </button>
        <div>
          <h1 style={{ fontFamily: "Nunito", fontWeight: 800, fontSize: "20px", color: dark ? "#ffffff" : "#1A1A2E" }}>Contact Nicknames</h1>
          <p className={`text-xs mt-0.5 ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>Only visible to you inside the app</p>
        </div>
      </div>

      <div className="mx-5 mt-4 px-4 py-3 bg-[#E8F5E9] rounded-2xl flex items-start gap-2">
        <span className="text-lg">💬</span>
        <p className="text-xs text-[#1D9E75] leading-relaxed" style={{ fontFamily: "Plus Jakarta Sans" }}>
          Nicknames replace real names only for you. Other members still see their original names.
        </p>
      </div>

      <div className="flex-1 overflow-y-auto px-5 pt-4 pb-24">
        <div className={`rounded-2xl shadow-sm overflow-hidden ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
          {contacts.map((contact, i) => (
            <div key={contact.id} className={i < contacts.length - 1 ? `border-b ${dark ? "border-white/5" : "border-gray-50"}` : ""}>
              <motion.div initial={{ opacity: 0, y: 6 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.05 }}
                className="flex items-center gap-3 px-4 py-3.5">
                <div className="w-10 h-10 rounded-full bg-[#E8F5E9] flex items-center justify-center text-xl flex-shrink-0">{contact.emoji}</div>
                <div className="flex-1 min-w-0">
                  <p style={{ fontFamily: "Nunito", fontWeight: 700, fontSize: "14px", color: dark ? "#ffffff" : "#1A1A2E" }}>
                    {nicknames[contact.id]
                      ? <><span>{nicknames[contact.id]}</span> <span className="text-[#9CA3AF] font-normal text-xs">({contact.realName})</span></>
                      : contact.realName}
                  </p>
                  <p className="text-xs text-[#9CA3AF] mt-0.5" style={{ fontFamily: "Plus Jakarta Sans" }}>{contact.phone}</p>
                </div>
                <button onClick={() => startEdit(contact)} className={`w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 ${dark ? "bg-white/10" : "bg-[#F7F8FA]"}`}>
                  <Pencil size={13} className="text-[#6B7280]" />
                </button>
              </motion.div>

              <AnimatePresence>
                {editing === contact.id && (
                  <motion.div initial={{ height: 0, opacity: 0 }} animate={{ height: "auto", opacity: 1 }} exit={{ height: 0, opacity: 0 }} transition={{ duration: 0.18 }}
                    className={`overflow-hidden border-t ${dark ? "bg-[#111124] border-white/5" : "bg-[#F7F8FA] border-gray-100"}`}>
                    <div className="px-4 py-3 flex items-center gap-2">
                      <input autoFocus value={draft} onChange={e => setDraft(e.target.value)}
                        onKeyDown={e => { if (e.key === "Enter") saveEdit(contact.id); if (e.key === "Escape") setEditing(null); }}
                        placeholder={`Nickname for ${contact.realName}…`}
                        className={`flex-1 rounded-xl px-3 py-2 text-sm border outline-none placeholder-gray-300 ${dark ? "bg-[#1a1a2e] text-white border-white/10" : "bg-white text-[#1A1A2E] border-gray-200"}`}
                        style={{ fontFamily: "Plus Jakarta Sans" }} />
                      {nicknames[contact.id] && (
                        <button onClick={() => clearNickname(contact.id)} className="w-8 h-8 rounded-full bg-red-50 flex items-center justify-center flex-shrink-0">
                          <X size={13} className="text-red-400" />
                        </button>
                      )}
                      <button onClick={() => saveEdit(contact.id)} className="w-8 h-8 rounded-full bg-[#1D9E75] flex items-center justify-center flex-shrink-0">
                        <Check size={13} className="text-white" />
                      </button>
                    </div>
                    {nicknames[contact.id] && (
                      <p className="px-4 pb-2 text-[10px] text-[#9CA3AF]" style={{ fontFamily: "Plus Jakarta Sans" }}>Tap ✕ to remove nickname and show real name</p>
                    )}
                  </motion.div>
                )}
              </AnimatePresence>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
