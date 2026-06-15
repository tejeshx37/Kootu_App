import { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { useOutletContext } from "react-router";
import { MapPin, Star, Tag, TrendingUp, Clock, Search, ChevronRight, ArrowLeft, Mic } from "lucide-react";
import { useTheme } from "../context/ThemeContext";

const PRODUCT_CATS = ["All", "Grocery", "Vegetables", "Dairy", "Grains & Dal", "Snacks", "Household", "Spices"];

const offers = [
  { id: 1, merchant: "FreshMart Velachery", dist: "2.0 km", logo: "🛒", offer: "15% off on Rice, Dal & Pulses", savings: "₹85", expiry: "4h 23m", cat: "Grains & Dal", match: 2, rating: 4.2 },
  { id: 2, merchant: "Velachery Veggie Hub", dist: "500 m", logo: "🥦", offer: "₹50 off on vegetables above ₹200", savings: "₹50", expiry: "2h 15m", cat: "Vegetables", match: 1, rating: 4.5 },
  { id: 3, merchant: "Daily Needs Store", dist: "1.2 km", logo: "🏪", offer: "Buy 2 Get 1 on dairy products", savings: "₹120", expiry: "8h", cat: "Dairy", match: 2, rating: 4.0 },
  { id: 4, merchant: "South Fresh Dairy", dist: "300 m", logo: "🥛", offer: "Fresh curd 500g at ₹45", savings: "₹15", expiry: "6h", cat: "Dairy", match: 1, rating: 4.7 },
  { id: 5, merchant: "Raja Kirana & Co.", dist: "800 m", logo: "🫙", offer: "10% off on all spices", savings: "₹40", expiry: "12h", cat: "Spices", match: 1, rating: 3.9 },
  { id: 6, merchant: "Nilgiris Supermart", dist: "1.5 km", logo: "🧴", offer: "₹100 off on household items above ₹500", savings: "₹100", expiry: "1d", cat: "Household", match: 0, rating: 4.3 },
  { id: 7, merchant: "Haldiram's Outlet", dist: "900 m", logo: "🍿", offer: "3 packs for ₹99 on namkeen", savings: "₹30", expiry: "3h", cat: "Snacks", match: 0, rating: 4.1 },
];

interface SubCat { label: string; emoji: string }
interface ServiceCat { id: string; label: string; emoji: string; color: string; bg: string; subs: SubCat[] }

const SERVICE_CATS: ServiceCat[] = [
  { id: "home", label: "Home Services", emoji: "🏠", color: "#1D9E75", bg: "#E8F5E9", subs: [{ label: "AC Repair & Service", emoji: "❄️" }, { label: "Pest Control", emoji: "🪲" }, { label: "Plumbing", emoji: "🔧" }, { label: "Electrical", emoji: "⚡" }, { label: "Deep Cleaning", emoji: "🧹" }, { label: "Carpentry", emoji: "🪚" }] },
  { id: "delivery", label: "Delivery", emoji: "🚚", color: "#3B82F6", bg: "#EFF6FF", subs: [{ label: "Grocery Delivery", emoji: "🛒" }, { label: "Medicine Delivery", emoji: "💊" }, { label: "Tiffin Delivery", emoji: "🍱" }, { label: "Courier", emoji: "📦" }] },
  { id: "health", label: "Health", emoji: "🏥", color: "#EF4444", bg: "#FEE2E2", subs: [{ label: "Doctors", emoji: "👨‍⚕️" }, { label: "Pharmacy", emoji: "💊" }, { label: "Lab Tests", emoji: "🧪" }, { label: "Physiotherapy", emoji: "🤸" }, { label: "Nursing Care", emoji: "👩‍⚕️" }] },
  { id: "beauty", label: "Beauty", emoji: "💇", color: "#EC4899", bg: "#FDF2F8", subs: [{ label: "Salon at Home", emoji: "✂️" }, { label: "Spa & Massage", emoji: "💆" }, { label: "Makeup Artist", emoji: "💄" }, { label: "Nail Art", emoji: "💅" }, { label: "Threading & Waxing", emoji: "🪡" }] },
  { id: "education", label: "Education", emoji: "📚", color: "#F59E0B", bg: "#FFFBEB", subs: [{ label: "Schools", emoji: "🏫" }, { label: "Colleges", emoji: "🎓" }, { label: "Coaching", emoji: "📝" }, { label: "Hobbies & Arts", emoji: "🎨" }, { label: "Vocational Training", emoji: "🔨" }] },
  { id: "repairs", label: "Repairs", emoji: "🔧", color: "#8B5CF6", bg: "#F5F3FF", subs: [{ label: "Electronics Repair", emoji: "📱" }, { label: "Appliance Repair", emoji: "🪛" }, { label: "Vehicle Service", emoji: "🚗" }, { label: "Furniture Repair", emoji: "🛋️" }] },
  { id: "food", label: "Food & Cook", emoji: "🍳", color: "#FF6B35", bg: "#FFF0EB", subs: [{ label: "Home Cook", emoji: "👩‍🍳" }, { label: "Tiffin Service", emoji: "🍱" }, { label: "Catering", emoji: "🍽️" }, { label: "Bakers & Sweets", emoji: "🎂" }] },
  { id: "movers", label: "Packers & Movers", emoji: "📦", color: "#0891B2", bg: "#CFFAFE", subs: [{ label: "Home Shifting", emoji: "🏡" }, { label: "Office Shifting", emoji: "🏢" }, { label: "Vehicle Transport", emoji: "🚛" }, { label: "Storage", emoji: "🏭" }] },
  { id: "cleaning", label: "Cleaning", emoji: "🧹", color: "#059669", bg: "#D1FAE5", subs: [{ label: "Home Cleaning", emoji: "🏠" }, { label: "Sofa & Carpet", emoji: "🛋️" }, { label: "Kitchen Deep Clean", emoji: "🍽️" }, { label: "Water Tank Cleaning", emoji: "💧" }] },
  { id: "bills", label: "Pay Bills", emoji: "💳", color: "#6B7280", bg: "#F3F4F6", subs: [{ label: "Electricity", emoji: "⚡" }, { label: "Water", emoji: "💧" }, { label: "Gas", emoji: "🔥" }, { label: "Mobile Recharge", emoji: "📱" }, { label: "DTH & Cable", emoji: "📺" }] },
  { id: "shopping", label: "Shopping", emoji: "🛍️", color: "#DB2777", bg: "#FCE7F3", subs: [{ label: "Grocery Stores", emoji: "🛒" }, { label: "Supermarkets", emoji: "🏪" }, { label: "Online Stores", emoji: "💻" }, { label: "Wholesale", emoji: "🏭" }] },
  { id: "more", label: "More", emoji: "⋯", color: "#1A1A2E", bg: "#F3F4F6", subs: [{ label: "B2B Suppliers", emoji: "🤝" }, { label: "Consultants", emoji: "👔" }, { label: "Event Services", emoji: "🎉" }, { label: "Pet Care", emoji: "🐾" }] },
];

const FEATURED_SECTIONS = [
  { title: "Home Services", catId: "home", items: [{ label: "AC Repair\n& Service", emoji: "❄️", bg: "linear-gradient(135deg,#1D9E75,#0d7a5a)" }, { label: "Pest\nControl", emoji: "🪲", bg: "linear-gradient(135deg,#EF4444,#b91c1c)" }, { label: "Packers &\nMovers", emoji: "📦", bg: "linear-gradient(135deg,#0891B2,#0e7490)" }, { label: "Deep\nCleaning", emoji: "🧹", bg: "linear-gradient(135deg,#8B5CF6,#7c3aed)" }] },
  { title: "Food & Delivery", catId: "food", items: [{ label: "Home\nCook", emoji: "👩‍🍳", bg: "linear-gradient(135deg,#FF6B35,#ea580c)" }, { label: "Tiffin\nService", emoji: "🍱", bg: "linear-gradient(135deg,#F59E0B,#d97706)" }, { label: "Grocery\nDelivery", emoji: "🛒", bg: "linear-gradient(135deg,#1D9E75,#059669)" }, { label: "Catering", emoji: "🍽️", bg: "linear-gradient(135deg,#EC4899,#db2777)" }] },
];

interface OutletContext { onMerchantTap: () => void }

export function MapExploreScreen() {
  const { onMerchantTap } = useOutletContext<OutletContext>();
  const { theme } = useTheme();
  const dark = theme === "dark";
  const [tab, setTab] = useState<"products" | "services">("products");
  const [selCat, setSelCat] = useState("All");
  const [activeSvcCat, setActiveSvcCat] = useState<ServiceCat | null>(null);

  const filtered = selCat === "All" ? offers : offers.filter(o => o.cat === selCat);

  return (
    <div className={`h-full flex flex-col ${dark ? "bg-[#0f0f1a]" : "bg-[#F7F8FA]"}`}>
      <div className={`px-5 pt-12 pb-0 shadow-sm ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
        <div className="flex items-center gap-3 mb-3">
          {activeSvcCat && (
            <button onClick={() => setActiveSvcCat(null)} className={`w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 ${dark ? "bg-white/10" : "bg-[#F7F8FA]"}`}>
              <ArrowLeft size={16} className={dark ? "text-white" : "text-[#1A1A2E]"} />
            </button>
          )}
          <div className="flex-1">
            <h1 style={{ fontFamily: "Nunito", fontWeight: 800, fontSize: "20px", color: dark ? "#ffffff" : "#1A1A2E" }}>
              {activeSvcCat ? activeSvcCat.label : "Explore"}
            </h1>
            {!activeSvcCat && (
              <div className="flex items-center gap-1 mt-0.5">
                <MapPin size={11} className="text-[#1D9E75]" />
                <span className={`text-xs ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>Velachery, Chennai</span>
              </div>
            )}
          </div>
        </div>

        {!activeSvcCat && (
          <div className={`flex border-b ${dark ? "border-white/5" : "border-gray-100"}`}>
            {(["products", "services"] as const).map(t => (
              <button key={t} onClick={() => setTab(t)}
                className="flex-1 py-3 relative text-sm font-medium transition-colors"
                style={{ fontFamily: "Plus Jakarta Sans", color: tab === t ? "#1D9E75" : dark ? "#6B7280" : "#9CA3AF" }}>
                {t === "products" ? "Products" : "Services"}
                {tab === t && <motion.div layoutId="tabUnderline" className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#1D9E75] rounded-full" />}
              </button>
            ))}
          </div>
        )}
      </div>

      <AnimatePresence mode="wait">
        {tab === "products" && (
          <motion.div key="products" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="flex-1 overflow-y-auto">
            <div className="px-5 pt-4 pb-2">
              <div className="flex gap-2 overflow-x-auto no-scrollbar pb-1">
                {PRODUCT_CATS.map(cat => (
                  <button key={cat} onClick={() => setSelCat(cat)}
                    className="flex-shrink-0 px-3.5 py-1.5 rounded-full text-xs font-medium transition-all"
                    style={{ fontFamily: "Plus Jakarta Sans", background: selCat === cat ? "#1D9E75" : dark ? "#2a2a4a" : "white", color: selCat === cat ? "white" : dark ? "#9CA3AF" : "#4B5563", boxShadow: dark ? "none" : "0 1px 3px rgba(0,0,0,0.08)", border: dark && selCat !== cat ? "1px solid rgba(255,255,255,0.08)" : "none" }}>
                    {cat}
                  </button>
                ))}
              </div>
            </div>
            <div className="px-5 pb-24 flex flex-col gap-3">
              {filtered.map((offer, idx) => (
                <motion.button key={offer.id} onClick={onMerchantTap}
                  initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: idx * 0.05 }}
                  whileTap={{ scale: 0.98 }}
                  className={`rounded-2xl p-4 shadow-sm text-left w-full ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
                  <div className="flex items-center gap-3 mb-2">
                    <div className={`w-11 h-11 rounded-full flex items-center justify-center text-2xl flex-shrink-0 ${dark ? "bg-white/10" : "bg-[#E8F5E9]"}`}>{offer.logo}</div>
                    <div className="flex-1 min-w-0">
                      <p style={{ fontFamily: "Nunito", fontWeight: 700, fontSize: "14px", color: dark ? "#ffffff" : "#1A1A2E" }}>{offer.merchant}</p>
                      <div className="flex items-center gap-2 mt-0.5">
                        <div className="flex items-center gap-0.5">
                          <Star size={10} className="text-amber-400 fill-amber-400" />
                          <span className={`text-[10px] ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>{offer.rating}</span>
                        </div>
                        <MapPin size={10} className={dark ? "text-gray-500" : "text-[#6B7280]"} />
                        <span className={`text-[10px] ${dark ? "text-gray-400" : "text-[#6B7280]"}`} style={{ fontFamily: "Plus Jakarta Sans" }}>{offer.dist}</span>
                      </div>
                    </div>
                    <span className="flex items-center gap-1 text-[10px] px-2 py-0.5 bg-[#EF4444]/10 text-[#EF4444] rounded-full font-medium" style={{ fontFamily: "Plus Jakarta Sans" }}>
                      <Clock size={9} /> {offer.expiry}
                    </span>
                  </div>
                  <p className={`text-sm mb-2 ${dark ? "text-white" : "text-[#1A1A2E]"}`} style={{ fontFamily: "Plus Jakarta Sans", fontWeight: 500 }}>{offer.offer}</p>
                  <div className="flex items-center gap-2">
                    <span className="flex items-center gap-1 px-2.5 py-1 bg-[#E8F5E9] rounded-full text-[10px] text-[#1D9E75] font-medium" style={{ fontFamily: "Plus Jakarta Sans" }}><Tag size={9} /> {offer.cat}</span>
                    <span className="flex items-center gap-1 px-2.5 py-1 bg-[#FF6B35]/10 rounded-full text-[10px] text-[#FF6B35] font-medium" style={{ fontFamily: "Plus Jakarta Sans" }}><TrendingUp size={9} /> Save {offer.savings}</span>
                    {offer.match > 0 && <span className="px-2.5 py-1 bg-amber-50 rounded-full text-[10px] text-amber-600 font-medium" style={{ fontFamily: "Plus Jakarta Sans" }}>{offer.match} list match</span>}
                  </div>
                </motion.button>
              ))}
            </div>
          </motion.div>
        )}

        {tab === "services" && !activeSvcCat && (
          <motion.div key="services-home" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="flex-1 overflow-y-auto pb-24">
            <div className="px-5 pt-4 pb-3">
              <div className={`flex items-center gap-3 rounded-2xl px-4 py-3 shadow-sm border ${dark ? "bg-[#1a1a2e] border-white/5" : "bg-white border-gray-100"}`}>
                <Search size={16} className="text-[#9CA3AF] flex-shrink-0" />
                <span className="flex-1 text-sm text-[#9CA3AF]" style={{ fontFamily: "Plus Jakarta Sans" }}>Search services…</span>
                <Mic size={16} className="text-[#1D9E75] flex-shrink-0" />
              </div>
            </div>

            <div className="px-5 mb-4">
              <div className="grid grid-cols-4 gap-3">
                {SERVICE_CATS.map((cat, idx) => (
                  <motion.button key={cat.id} onClick={() => setActiveSvcCat(cat)}
                    initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: idx * 0.03 }}
                    whileTap={{ scale: 0.94 }} className="flex flex-col items-center gap-1.5">
                    <div className="w-14 h-14 rounded-2xl flex items-center justify-center text-2xl shadow-sm" style={{ background: cat.bg }}>{cat.emoji}</div>
                    <span className={`text-[10px] text-center leading-tight ${dark ? "text-gray-300" : "text-[#1A1A2E]"}`} style={{ fontFamily: "Plus Jakarta Sans", fontWeight: 500 }}>{cat.label}</span>
                  </motion.button>
                ))}
              </div>
            </div>

            {FEATURED_SECTIONS.map(section => (
              <div key={section.title} className="mb-5">
                <div className="flex items-center justify-between px-5 mb-3">
                  <h3 style={{ fontFamily: "Nunito", fontWeight: 700, fontSize: "15px", color: dark ? "#ffffff" : "#1A1A2E" }}>{section.title}</h3>
                  <button onClick={() => setActiveSvcCat(SERVICE_CATS.find(c => c.id === section.catId) ?? null)}
                    className="flex items-center gap-0.5 text-xs text-[#1D9E75] font-medium" style={{ fontFamily: "Plus Jakarta Sans" }}>
                    See all <ChevronRight size={13} />
                  </button>
                </div>
                <div className="flex gap-3 px-5 overflow-x-auto no-scrollbar">
                  {section.items.map((item, i) => (
                    <motion.button key={i} whileTap={{ scale: 0.95 }}
                      className="flex-shrink-0 w-24 h-24 rounded-2xl flex flex-col items-center justify-center gap-1.5 shadow-sm"
                      style={{ background: item.bg }}>
                      <span className="text-2xl">{item.emoji}</span>
                      <span className="text-[10px] text-white font-medium text-center leading-tight whitespace-pre-line px-1" style={{ fontFamily: "Plus Jakarta Sans" }}>{item.label}</span>
                    </motion.button>
                  ))}
                </div>
              </div>
            ))}
          </motion.div>
        )}

        {tab === "services" && activeSvcCat && (
          <motion.div key={`sub-${activeSvcCat.id}`} initial={{ x: "30%", opacity: 0 }} animate={{ x: 0, opacity: 1 }} exit={{ x: "-30%", opacity: 0 }}
            transition={{ type: "spring", damping: 28, stiffness: 280 }} className="flex-1 overflow-y-auto pb-24">
            <div className={`mx-5 mt-4 rounded-2xl shadow-sm overflow-hidden ${dark ? "bg-[#1a1a2e]" : "bg-white"}`}>
              {activeSvcCat.subs.map((sub, i) => (
                <motion.button key={i} onClick={onMerchantTap} whileTap={{ scale: 0.99 }}
                  initial={{ opacity: 0, x: 12 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: i * 0.05 }}
                  className={`w-full flex items-center gap-4 px-5 py-4 text-left ${i < activeSvcCat.subs.length - 1 ? `border-b ${dark ? "border-white/5" : "border-gray-50"}` : ""}`}>
                  <div className="w-10 h-10 rounded-xl flex items-center justify-center text-xl flex-shrink-0" style={{ background: activeSvcCat.bg }}>{sub.emoji}</div>
                  <span className={`flex-1 text-sm ${dark ? "text-white" : "text-[#1A1A2E]"}`} style={{ fontFamily: "Plus Jakarta Sans", fontWeight: 500 }}>{sub.label}</span>
                  <ChevronRight size={16} className={dark ? "text-white/20" : "text-gray-300"} />
                </motion.button>
              ))}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
