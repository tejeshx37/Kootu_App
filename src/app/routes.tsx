import { createBrowserRouter } from "react-router";
import { Navigate } from "react-router";
import { OnboardingScreen } from "./components/OnboardingScreen";
import { AuthScreen } from "./components/AuthScreen";
import { MainLayout } from "./components/MainLayout";
import { HomeScreen } from "./components/HomeScreen";
import { OffersScreen } from "./components/OffersScreen";
import { MapExploreScreen } from "./components/MapExploreScreen";
import { ProfileScreen } from "./components/ProfileScreen";
import { ProfileRoomsScreen } from "./components/ProfileRoomsScreen";
import { ProfileNicknamesScreen } from "./components/ProfileNicknamesScreen";
import { RoomsScreen } from "./components/RoomsScreen";

export const router = createBrowserRouter([
  {
    path: "/",
    Component: OnboardingScreen,
  },
  {
    path: "/auth",
    Component: AuthScreen,
  },
  {
    path: "/app",
    Component: MainLayout,
    children: [
      { index: true, element: <Navigate to="/app/home" replace /> },
      { path: "home", Component: HomeScreen },
      { path: "rooms", Component: RoomsScreen },
      { path: "offers", Component: OffersScreen },
      { path: "explore", Component: MapExploreScreen },
      { path: "profile", Component: ProfileScreen },
      { path: "profile/rooms", Component: ProfileRoomsScreen },
      { path: "profile/nicknames", Component: ProfileNicknamesScreen },
    ],
  },
]);
