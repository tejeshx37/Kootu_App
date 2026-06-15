import { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { useNavigate } from "react-router";
import { ChevronRight, ShoppingCart, MapPin, PiggyBank } from "lucide-react";

const slides = [
  {
    id: 0,
    icon: <ShoppingCart size={64} strokeWidth={1.5} className="text-white" />,
    bg: "from-[#1D9E75] to-[#0d7a5a]",
    illustrationBg: "bg-[#17875f]",
    title: "Shop Together,\nSave Together",
    subtitle: "Add items to shared lists with your family. Everyone stays in sync — no more duplicate purchases.",
    emoji: "🛒",
    avatarRow: (
      <div className="flex -space-x-3 justify-center mt-6 mb-4">
        {["👩", "👨", "👧", "👦"].map((e, i) => (
          <div key={i} className="w-12 h-12 rounded-full bg-white/20 backdrop-blur flex items-center justify-center text-2xl border-2 border-white/40">
            {e}
          </div>
        ))}
      </div>
    ),
  },
  {
    id: 1,
    icon: <MapPin size={64} strokeWidth={1.5} className="text-white" />,
    bg: "from-[#1D9E75] to-[#156b82]",
    illustrationBg: "bg-[#1185a0]",
    title: "Discover Nearby\nDeals Instantly",
    subtitle: "Local vendors and kirana stores post live offers matched to your shopping list. Save on what you actually need.",
    emoji: "📍",
    avatarRow: (
      <div className="flex gap-2 justify-center mt-6 mb-4 flex-wrap">
        {["FreshMart", "Raja Store", "Veggie Hub", "Daily Needs"].map((s, i) => (
          <div key={i} className="px-3 py-1.5 bg-white/20 rounded-full text-white text-sm backdrop-blur border border-white/30">
            {s}
          </div>
        ))}
      </div>
    ),
  },
  {
    id: 2,
    icon: <PiggyBank size={64} strokeWidth={1.5} className="text-white" />,
    bg: "from-[#FF6B35] to-[#e5501a]",
    illustrationBg: "bg-[#d04516]",
    title: "Save More Every\nMonth as a Family",
    subtitle: "Track your household budget, see what you've saved, and celebrate milestones together.",
    emoji: "💰",
    avatarRow: (
      <div className="flex gap-4 justify-center mt-6 mb-4">
        {[{ label: "Saved", val: "₹2,340" }, { label: "Deals", val: "48" }, { label: "Items", val: "156" }].map((s, i) => (
          <div key={i} className="flex flex-col items-center">
            <span className="text-white font-bold text-xl" style={{ fontFamily: "Nunito" }}>{s.val}</span>
            <span className="text-white/70 text-xs">{s.label}</span>
          </div>
        ))}
      </div>
    ),
  },
];

export function OnboardingScreen() {
  const navigate = useNavigate();
  const [current, setCurrent] = useState(0);

  const next = () => {
    if (current < slides.length - 1) setCurrent(current + 1);
    else navigate('/auth');
  };

  const slide = slides[current];

  return (
    <div className={`h-full w-full bg-gradient-to-b ${slide.bg} flex flex-col transition-all duration-500`}>
      {/* Skip */}
      <div className="flex justify-end px-6 pt-12">
        {current < slides.length - 1 && (
          <button onClick={() => navigate('/auth')} className="text-white/70 text-sm px-4 py-1.5 rounded-full border border-white/30">
            Skip
          </button>
        )}
      </div>

      {/* Illustration area */}
      <div className="flex-1 flex flex-col items-center justify-center px-8">
        <AnimatePresence mode="wait">
          <motion.div
            key={current}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            transition={{ duration: 0.35 }}
            className="w-full flex flex-col items-center"
          >
            {/* Illustration circle */}
            <div className={`w-48 h-48 rounded-full ${slide.illustrationBg} flex items-center justify-center shadow-2xl mb-2`}>
              <div className="text-7xl">{slide.emoji}</div>
            </div>
            {slide.avatarRow}
          </motion.div>
        </AnimatePresence>
      </div>

      {/* Bottom card */}
      <motion.div
        key={`card-${current}`}
        initial={{ opacity: 0, y: 30 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.4, delay: 0.1 }}
        className="bg-white rounded-t-[32px] px-6 pt-8 pb-10"
      >
        <h2 className="text-[#1A1A2E] text-center whitespace-pre-line mb-3" style={{ fontFamily: "Nunito", fontWeight: 800, fontSize: "24px", lineHeight: "1.25" }}>
          {slide.title}
        </h2>
        <p className="text-[#6B7280] text-center text-sm leading-relaxed mb-8" style={{ fontFamily: "Plus Jakarta Sans" }}>
          {slide.subtitle}
        </p>

        {/* Progress dots */}
        <div className="flex justify-center gap-2 mb-6">
          {slides.map((_, i) => (
            <button key={i} onClick={() => setCurrent(i)}
              className={`rounded-full transition-all duration-300 ${i === current ? "w-8 h-2 bg-[#1D9E75]" : "w-2 h-2 bg-gray-200"}`}
            />
          ))}
        </div>

        {/* CTA */}
        <button
          onClick={next}
          className="w-full py-4 rounded-2xl text-white flex items-center justify-center gap-2 shadow-lg active:scale-95 transition-transform"
          style={{ background: current === 2 ? "#FF6B35" : "#1D9E75", fontFamily: "Nunito", fontWeight: 700, fontSize: "16px" }}
        >
          {current === slides.length - 1 ? "Get Started" : "Next"}
          <ChevronRight size={20} />
        </button>
      </motion.div>
    </div>
  );
}
