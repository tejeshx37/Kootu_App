import { useState } from "react";
import { Outlet, useNavigate, useLocation } from "react-router";
import { AnimatePresence, motion } from "motion/react";
import { Home, Tag, Compass, User } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { RoomDetailScreen } from "./RoomDetailScreen";
import { AddItemSheet } from "./AddItemSheet";
import { CreateRoomSheet } from "./CreateRoomSheet";
import { JoinRoomSheet } from "./JoinRoomSheet";
import { MerchantProfileScreen } from "./MerchantProfileScreen";
import { NotificationsScreen } from "./NotificationsScreen";
import { MerchantDashScreen } from "./MerchantDashScreen";

export type Category = { label: string; emoji: string; color: string; bg: string };

export const CATEGORIES: Category[] = [
  { label: "Vegetables", emoji: "🥦", color: "#16a34a", bg: "#dcfce7" },
  { label: "Grains & Dal", emoji: "🌾", color: "#d97706", bg: "#fef3c7" },
  { label: "Dairy", emoji: "🥛", color: "#2563eb", bg: "#dbeafe" },
  { label: "Fish & Meat", emoji: "🐟", color: "#dc2626", bg: "#fee2e2" },
  { label: "Spices", emoji: "🫙", color: "#7c3aed", bg: "#ede9fe" },
  { label: "Snacks", emoji: "🍫", color: "#db2777", bg: "#fce7f3" },
  { label: "Household", emoji: "🧹", color: "#0891b2", bg: "#cffafe" },
  { label: "Personal Care", emoji: "🧴", color: "#059669", bg: "#d1fae5" },
  { label: "Other", emoji: "🛒", color: "#6b7280", bg: "#f3f4f6" },
];

export interface ListItem {
  id: number;
  name: string;
  bought: boolean;
  category: Category;
  showCatPicker: boolean;
  addedAt: Date;
  addedBy: string;
  boughtAt?: Date;
  boughtBy?: string;
}

export const rooms = [
  { id: 1, name: "Family Room", emoji: "🏠", members: ["👩", "👨", "👧"], count: 8, needed: 3, budget: { spent: 2340, total: 3500 } },
  { id: 2, name: "Work Lunch", emoji: "🍱", members: ["👩", "👦"], count: 5, needed: 1, budget: null },
  { id: 3, name: "Weekend BBQ", emoji: "🍖", members: ["👨", "👩", "👦", "👧"], count: 12, needed: 5, budget: { spent: 850, total: 2000 } },
];

const initialItems: Record<number, ListItem[]> = {
  1: [
    { id: 101, name: "Basmati Rice", bought: false, category: CATEGORIES[1], showCatPicker: false, addedAt: new Date(Date.now() - 3 * 86400000), addedBy: "Priya" },
    { id: 102, name: "Toor Dal", bought: false, category: CATEGORIES[1], showCatPicker: false, addedAt: new Date(Date.now() - 3 * 86400000), addedBy: "Priya" },
    { id: 103, name: "Tomatoes", bought: true, category: CATEGORIES[0], showCatPicker: false, addedAt: new Date(Date.now() - 2 * 86400000), addedBy: "Rajan", boughtAt: new Date(Date.now() - 86400000), boughtBy: "Priya" },
    { id: 104, name: "Milk (2L)", bought: false, category: CATEGORIES[2], showCatPicker: false, addedAt: new Date(Date.now() - 86400000), addedBy: "Kavya" },
    { id: 105, name: "Ghee", bought: false, category: CATEGORIES[2], showCatPicker: false, addedAt: new Date(Date.now() - 3600000), addedBy: "Priya" },
    { id: 106, name: "Vim Bar", bought: false, category: CATEGORIES[6], showCatPicker: false, addedAt: new Date(Date.now() - 1800000), addedBy: "Rajan" },
  ],
  2: [
    { id: 201, name: "Sandwich Bread", bought: false, category: CATEGORIES[1], showCatPicker: false, addedAt: new Date(Date.now() - 3600000), addedBy: "Anand" },
    { id: 202, name: "Curd", bought: false, category: CATEGORIES[2], showCatPicker: false, addedAt: new Date(Date.now() - 7200000), addedBy: "Meena" },
    { id: 203, name: "Chips", bought: true, category: CATEGORIES[5], showCatPicker: false, addedAt: new Date(Date.now() - 86400000), addedBy: "Anand", boughtAt: new Date(Date.now() - 3600000), boughtBy: "Meena" },
  ],
  3: [
    { id: 301, name: "Chicken", bought: false, category: CATEGORIES[3], showCatPicker: false, addedAt: new Date(Date.now() - 86400000), addedBy: "Rajan" },
    { id: 302, name: "Paneer", bought: false, category: CATEGORIES[2], showCatPicker: false, addedAt: new Date(Date.now() - 86400000), addedBy: "Priya" },
    { id: 303, name: "Tomatoes", bought: false, category: CATEGORIES[0], showCatPicker: false, addedAt: new Date(Date.now() - 43200000), addedBy: "Rajan" },
    { id: 304, name: "Garam Masala", bought: false, category: CATEGORIES[4], showCatPicker: false, addedAt: new Date(Date.now() - 43200000), addedBy: "Priya" },
    { id: 305, name: "Charcoal", bought: true, category: CATEGORIES[8], showCatPicker: false, addedAt: new Date(Date.now() - 2 * 86400000), addedBy: "Rajan", boughtAt: new Date(Date.now() - 86400000), boughtBy: "Rajan" },
  ],
};

type SubScreen =
  | null
  | "roomDetail"
  | "merchantProfile"
  | "notifications"
  | "merchantDash";

type MainTab = "home" | "rooms" | "offers" | "explore" | "profile";

const navItems: { id: MainTab; icon: typeof Home; label: string }[] = [
  { id: "home", icon: Home, label: "Home" },
  { id: "offers", icon: Tag, label: "Offers" },
  { id: "explore", icon: Compass, label: "Explore" },
];

export function MainLayout() {
  const navigate = useNavigate();
  const location = useLocation();
  const { theme } = useTheme();
  const dark = theme === "dark";
  const [subScreen, setSubScreen] = useState<SubScreen>(null);
  const [showAddItem, setShowAddItem] = useState(false);
  const [showCreateRoom, setShowCreateRoom] = useState(false);
  const [showJoinRoom, setShowJoinRoom] = useState(false);

  // Shared room + list state (persists across tab switches)
  const [selectedRoomId, setSelectedRoomId] = useState(rooms[0].id);
  const [listItemsByRoom, setListItemsByRoom] = useState<Record<number, ListItem[]>>(initialItems);

  const closeSubScreen = () => setSubScreen(null);

  const getActiveTab = (): MainTab => {
    const path = location.pathname;
    if (path.includes("/rooms")) return "rooms";
    if (path.includes("/offers")) return "offers";
    if (path.includes("/explore")) return "explore";
    if (path.includes("/profile")) return "profile";
    return "home";
  };

  const activeTab = getActiveTab();

  const handleTabClick = (tabId: MainTab) => {
    setSubScreen(null);
    navigate(`/app/${tabId}`);
  };

  return (
    <div className="absolute inset-0 flex flex-col">
      {/* Main screen content */}
      <div className="flex-1 relative overflow-hidden">
        <AnimatePresence mode="wait">
          {subScreen === "roomDetail" && (
            <motion.div key="roomDetail" className="absolute inset-0"
              initial={{ x: "100%" }} animate={{ x: 0 }} exit={{ x: "100%" }}
              transition={{ type: "spring", damping: 28, stiffness: 280 }}>
              <RoomDetailScreen
                roomId={1}
                onBack={closeSubScreen}
                onAddItem={() => setShowAddItem(true)}
              />
            </motion.div>
          )}

          {subScreen === "merchantProfile" && (
            <motion.div key="merchantProfile" className="absolute inset-0"
              initial={{ x: "100%" }} animate={{ x: 0 }} exit={{ x: "100%" }}
              transition={{ type: "spring", damping: 28, stiffness: 280 }}>
              <MerchantProfileScreen onBack={closeSubScreen} />
            </motion.div>
          )}

          {subScreen === "notifications" && (
            <motion.div key="notifications" className="absolute inset-0"
              initial={{ x: "100%" }} animate={{ x: 0 }} exit={{ x: "100%" }}
              transition={{ type: "spring", damping: 28, stiffness: 280 }}>
              <NotificationsScreen onBack={closeSubScreen} />
            </motion.div>
          )}

          {subScreen === "merchantDash" && (
            <motion.div key="merchantDash" className="absolute inset-0"
              initial={{ x: "100%" }} animate={{ x: 0 }} exit={{ x: "100%" }}
              transition={{ type: "spring", damping: 28, stiffness: 280 }}>
              <MerchantDashScreen />
            </motion.div>
          )}

          {!subScreen && (
            <motion.div key={location.pathname} className="absolute inset-0"
              initial={{ opacity: 0, y: 6 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -6 }}
              transition={{ duration: 0.2 }}>
              <Outlet context={{
                onRoomTap: () => setSubScreen("roomDetail"),
                onOfferTap: () => navigate("/app/offers"),
                onAddItem: () => setShowAddItem(true),
                onNotifications: () => setSubScreen("notifications"),
                onMerchantTap: () => setSubScreen("merchantProfile"),
                onMerchantDash: () => setSubScreen("merchantDash"),
                onCreateRoom: () => setShowCreateRoom(true),
                onJoinRoom: () => setShowJoinRoom(true),
                selectedRoomId,
                setSelectedRoomId,
                listItemsByRoom,
                setListItemsByRoom,
              }} />
            </motion.div>
          )}
        </AnimatePresence>

        {/* Add Item Sheet */}
        <AnimatePresence>
          {showAddItem && (
            <AddItemSheet
              onClose={() => setShowAddItem(false)}
              onAdd={() => setShowAddItem(false)}
            />
          )}
        </AnimatePresence>

        {/* Create Room Sheet */}
        <AnimatePresence>
          {showCreateRoom && (
            <CreateRoomSheet
              onClose={() => setShowCreateRoom(false)}
              onCreate={() => setShowCreateRoom(false)}
            />
          )}
        </AnimatePresence>

        {/* Join Room Sheet */}
        <AnimatePresence>
          {showJoinRoom && (
            <JoinRoomSheet
              onClose={() => setShowJoinRoom(false)}
              onJoin={() => setShowJoinRoom(false)}
            />
          )}
        </AnimatePresence>
      </div>

      {/* Bottom Navigation */}
      {!subScreen && (
        <div className="flex-shrink-0 border-t px-2 pb-2 pt-1.5"
          style={{
            background: dark ? "#1a1a2e" : "#ffffff",
            borderColor: dark ? "rgba(255,255,255,0.06)" : "#f3f4f6",
            paddingBottom: "max(8px, env(safe-area-inset-bottom))",
          }}>
          <div className="flex">
            {navItems.map(({ id, icon: Icon, label }) => {
              const active = activeTab === id;
              return (
                <button key={id} onClick={() => handleTabClick(id)}
                  className="flex-1 flex flex-col items-center py-1.5 gap-0.5 relative transition-colors">
                  {active && (
                    <motion.div layoutId="navIndicator"
                      className="absolute top-0.5 w-6 h-1 rounded-full bg-[#1D9E75]" />
                  )}
                  <Icon size={22}
                    className={active ? "text-[#1D9E75]" : dark ? "text-gray-500" : "text-gray-400"}
                    strokeWidth={active ? 2.2 : 1.7}
                  />
                  <span className="text-[10px] font-medium"
                    style={{ fontFamily: "Plus Jakarta Sans", color: active ? "#1D9E75" : dark ? "#6b7280" : "#9CA3AF" }}>
                    {label}
                  </span>
                </button>
              );
            })}
          </div>
        </div>
      )}
    </div>
  );
}
