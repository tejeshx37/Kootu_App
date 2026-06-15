import { useState, useRef, useEffect } from "react";
import { motion, AnimatePresence } from "motion/react";
import { useNavigate } from "react-router";
import { ChevronDown, CheckCircle, ArrowLeft } from "lucide-react";

export function AuthScreen() {
  const navigate = useNavigate();
  const [stage, setStage] = useState<"phone" | "otp" | "verifying" | "done">("phone");
  const [phone, setPhone] = useState("");
  const [otp, setOtp] = useState(["", "", "", "", "", ""]);
  const [resend, setResend] = useState(29);
  const otpRefs = useRef<(HTMLInputElement | null)[]>([]);

  useEffect(() => {
    if (stage !== "otp") return;
    const t = setInterval(() => setResend(r => Math.max(0, r - 1)), 1000);
    return () => clearInterval(t);
  }, [stage]);

  const sendOtp = () => {
    if (phone.length < 10) return;
    setStage("otp");
    setResend(29);
    setTimeout(() => otpRefs.current[0]?.focus(), 300);
  };

  const handleOtpChange = (i: number, val: string) => {
    if (!/^\d*$/.test(val)) return;
    const next = [...otp];
    next[i] = val.slice(-1);
    setOtp(next);
    if (val && i < 5) otpRefs.current[i + 1]?.focus();
    if (next.every(d => d !== "") && next.join("").length === 6) {
      setTimeout(() => {
        setStage("verifying");
        setTimeout(() => { setStage("done"); setTimeout(() => navigate('/app'), 600); }, 1200);
      }, 300);
    }
  };

  const handleOtpKey = (i: number, e: React.KeyboardEvent) => {
    if (e.key === "Backspace" && !otp[i] && i > 0) otpRefs.current[i - 1]?.focus();
  };

  return (
    <div className="h-full w-full bg-white flex flex-col">
      {/* Header */}
      <div className="flex items-center px-4 pt-12 pb-4 gap-3">
        <button onClick={() => navigate('/')} className="w-10 h-10 rounded-full bg-[#F7F8FA] flex items-center justify-center">
          <ArrowLeft size={20} className="text-[#1A1A2E]" />
        </button>
        <div>
          <h1 style={{ fontFamily: "Nunito", fontWeight: 800, fontSize: "22px", color: "#1A1A2E", lineHeight: 1.2 }}>
            {stage === "phone" ? "Enter your number" : "Verify OTP"}
          </h1>
          <p className="text-[#6B7280] text-sm" style={{ fontFamily: "Plus Jakarta Sans" }}>
            {stage === "phone" ? "We'll send a 6-digit code" : `Sent to +91 ${phone}`}
          </p>
        </div>
      </div>

      {/* Logo area */}
      <div className="flex justify-center py-6">
        <div className="flex items-center gap-2">
          <div className="w-10 h-10 rounded-xl bg-[#1D9E75] flex items-center justify-center">
            <span className="text-white font-black text-xl" style={{ fontFamily: "Nunito" }}>K</span>
          </div>
          <span style={{ fontFamily: "Nunito", fontWeight: 800, fontSize: "24px", color: "#1A1A2E" }}>kootu</span>
        </div>
      </div>

      <div className="flex-1 px-6">
        <AnimatePresence mode="wait">
          {stage === "phone" && (
            <motion.div key="phone" initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -20 }}>
              <label className="text-[#1A1A2E] text-sm mb-2 block" style={{ fontFamily: "Plus Jakarta Sans", fontWeight: 500 }}>
                Mobile Number
              </label>
              <div className="flex gap-2 mb-6">
                <button className="flex items-center gap-1.5 px-3 py-4 bg-[#F7F8FA] rounded-xl border border-gray-100">
                  <span className="text-lg">🇮🇳</span>
                  <span className="text-[#1A1A2E] text-sm font-medium" style={{ fontFamily: "Plus Jakarta Sans" }}>+91</span>
                  <ChevronDown size={14} className="text-[#6B7280]" />
                </button>
                <input
                  type="tel"
                  maxLength={10}
                  value={phone}
                  onChange={e => setPhone(e.target.value.replace(/\D/g, ""))}
                  placeholder="Enter 10-digit number"
                  className="flex-1 px-4 py-4 bg-[#F7F8FA] rounded-xl border border-gray-100 outline-none focus:border-[#1D9E75] text-[#1A1A2E] placeholder:text-gray-400 transition-colors"
                  style={{ fontFamily: "Plus Jakarta Sans" }}
                />
              </div>
              <button
                onClick={sendOtp}
                disabled={phone.length < 10}
                className="w-full py-4 rounded-2xl text-white font-bold disabled:opacity-40 transition-all active:scale-95"
                style={{ background: "#1D9E75", fontFamily: "Nunito", fontWeight: 700, fontSize: "16px" }}
              >
                Send OTP
              </button>
            </motion.div>
          )}

          {(stage === "otp" || stage === "verifying" || stage === "done") && (
            <motion.div key="otp" initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -20 }}>
              <label className="text-[#1A1A2E] text-sm mb-4 block" style={{ fontFamily: "Plus Jakarta Sans", fontWeight: 500 }}>
                6-digit OTP
              </label>
              <div className="flex gap-2 mb-6 justify-between">
                {otp.map((d, i) => (
                  <motion.input
                    key={i}
                    ref={el => { otpRefs.current[i] = el; }}
                    type="text"
                    inputMode="numeric"
                    maxLength={1}
                    value={d}
                    onChange={e => handleOtpChange(i, e.target.value)}
                    onKeyDown={e => handleOtpKey(i, e)}
                    animate={stage === "verifying" ? { scale: [1, 1.08, 1], borderColor: "#1D9E75" } : {}}
                    transition={{ delay: i * 0.05 }}
                    className="w-12 h-14 text-center bg-[#F7F8FA] rounded-xl border-2 outline-none focus:border-[#1D9E75] text-[#1A1A2E] transition-all"
                    style={{ fontFamily: "Nunito", fontWeight: 700, fontSize: "22px", borderColor: d ? "#1D9E75" : "#e5e7eb" }}
                  />
                ))}
              </div>

              {/* Verify state */}
              <AnimatePresence>
                {stage === "verifying" && (
                  <motion.div initial={{ opacity: 0, scale: 0.8 }} animate={{ opacity: 1, scale: 1 }}
                    className="flex items-center justify-center gap-2 mb-6">
                    <div className="w-5 h-5 border-2 border-[#1D9E75] border-t-transparent rounded-full animate-spin" />
                    <span className="text-[#1D9E75] text-sm font-medium" style={{ fontFamily: "Plus Jakarta Sans" }}>Verifying…</span>
                  </motion.div>
                )}
                {stage === "done" && (
                  <motion.div initial={{ opacity: 0, scale: 0.8 }} animate={{ opacity: 1, scale: 1 }}
                    className="flex items-center justify-center gap-2 mb-6">
                    <CheckCircle size={20} className="text-[#1D9E75]" />
                    <span className="text-[#1D9E75] text-sm font-medium" style={{ fontFamily: "Plus Jakarta Sans" }}>Verified!</span>
                  </motion.div>
                )}
              </AnimatePresence>

              {stage === "otp" && (
                <p className="text-center text-sm text-[#6B7280] mb-6" style={{ fontFamily: "Plus Jakarta Sans" }}>
                  {resend > 0 ? (
                    <span>Resend in <span className="text-[#1D9E75] font-medium">{resend}s</span></span>
                  ) : (
                    <button onClick={() => { setResend(29); setOtp(["", "", "", "", "", ""]); }} className="text-[#1D9E75] font-medium">
                      Resend OTP
                    </button>
                  )}
                </p>
              )}

              <button
                onClick={() => handleOtpChange(5, "2")}
                className="w-full py-3 rounded-xl text-[#1D9E75] font-medium border border-[#1D9E75]/30 bg-[#E8F5E9] transition-all active:scale-95 text-sm"
                style={{ fontFamily: "Plus Jakarta Sans" }}
              >
                Auto-fill demo OTP
              </button>
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      <div className="px-6 pb-8">
        <p className="text-center text-xs text-[#6B7280]" style={{ fontFamily: "Plus Jakarta Sans" }}>
          By continuing, you agree to our{" "}
          <span className="text-[#1D9E75]">Terms of Service</span> and{" "}
          <span className="text-[#1D9E75]">Privacy Policy</span>
        </p>
      </div>
    </div>
  );
}
