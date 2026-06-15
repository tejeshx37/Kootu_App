import { RouterProvider } from "react-router";
import { router } from "./routes";
import { ThemeProvider, useTheme } from "./context/ThemeContext";

function AppShell() {
  const { theme } = useTheme();
  const dark = theme === "dark";

  return (
    <div className="min-h-screen w-full flex items-center justify-center"
      style={{ background: dark ? "linear-gradient(135deg, #0a0a12 0%, #1a1a2e 100%)" : "linear-gradient(135deg, #0d7a5a 0%, #1D9E75 40%, #156b82 100%)" }}>

      <div
        className="relative overflow-hidden shadow-2xl flex-shrink-0"
        style={{
          width: 390,
          height: 844,
          borderRadius: 44,
          border: "8px solid #1a1a1a",
          boxShadow: "0 0 0 2px #333, 0 30px 80px rgba(0,0,0,0.5)",
          background: dark ? "#0f0f1a" : "#F7F8FA",
        }}
      >
        <div className="absolute top-0 left-1/2 -translate-x-1/2 z-50 w-28 h-7 bg-[#1a1a1a] rounded-b-2xl" />
        <div className={`absolute inset-0 overflow-hidden ${dark ? "dark" : ""}`} style={{ borderRadius: 38 }}>
          <RouterProvider router={router} />
        </div>
        <div className="absolute bottom-2 left-1/2 -translate-x-1/2 w-28 h-1 bg-black/20 rounded-full z-50" />
      </div>

      <div className="absolute bottom-6 left-1/2 -translate-x-1/2 text-white/60 text-xs text-center"
        style={{ fontFamily: "Plus Jakarta Sans" }}>
        kootu — hyperlocal social shopping for Indian families
      </div>
    </div>
  );
}

export default function App() {
  return (
    <ThemeProvider>
      <AppShell />
    </ThemeProvider>
  );
}
