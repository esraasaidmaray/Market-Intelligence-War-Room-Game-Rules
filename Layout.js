import React from "react";
import { Link, useLocation } from "react-router-dom";
import { createPageUrl } from "@/utils";
import { 
  Zap, 
  Users, 
  Target, 
  Trophy, 
  Settings,
  Home
} from "lucide-react";

export default function Layout({ children, currentPageName }) {
  const location = useLocation();
  
  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-black to-gray-800">
      {/* Cyber grid background effect */}
      <div className="fixed inset-0 opacity-30 pointer-events-none">
        <div className="absolute inset-0 bg-black bg-opacity-80" />
        <div className="absolute inset-0" 
             style={{
               backgroundImage: `url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.02'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")`,
               backgroundSize: "60px 60px"
             }}
        />
      </div>
      
      {/* Main App Container */}
      <div className="relative z-10 flex flex-col min-h-screen">
        {/* Top Navigation Bar */}
        <nav className="bg-black/50 backdrop-blur-sm border-b border-cyan-500/20 px-4 py-3">
          <div className="flex items-center justify-between max-w-7xl mx-auto">
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 bg-gradient-to-r from-cyan-400 to-blue-500 rounded-lg flex items-center justify-center">
                <Zap className="w-5 h-5 text-black font-bold" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-white tracking-tight">
                  Intelligence War Room
                </h1>
                <p className="text-xs text-cyan-400/80">Market Research Battle System</p>
              </div>
            </div>
            
            {/* Quick Nav Icons */}
            <div className="flex items-center gap-2">
              <Link 
                to={createPageUrl("Home")} 
                className={`p-2 rounded-lg transition-all duration-200 ${
                  currentPageName === "Home" 
                    ? "bg-cyan-500/20 text-cyan-400" 
                    : "text-gray-400 hover:text-white hover:bg-gray-800/50"
                }`}
              >
                <Home className="w-5 h-5" />
              </Link>
              <Link 
                to={createPageUrl("Matches")} 
                className={`p-2 rounded-lg transition-all duration-200 ${
                  currentPageName === "Matches" 
                    ? "bg-cyan-500/20 text-cyan-400" 
                    : "text-gray-400 hover:text-white hover:bg-gray-800/50"
                }`}
              >
                <Trophy className="w-5 h-5" />
              </Link>
            </div>
          </div>
        </nav>

        {/* Main Content */}
        <main className="flex-1 overflow-hidden">
          {children}
        </main>

        {/* Footer */}
        <footer className="bg-black/30 backdrop-blur-sm border-t border-gray-800 px-4 py-3 text-center">
          <p className="text-sm text-gray-400">
            Base44 Intelligence War Room &copy; {new Date().getFullYear()}
          </p>
        </footer>
      </div>
      
      {/* Ambient lighting effects */}
      <div className="fixed top-0 left-1/4 w-96 h-96 bg-cyan-500/10 rounded-full blur-3xl pointer-events-none" />
      <div className="fixed bottom-0 right-1/4 w-96 h-96 bg-blue-500/10 rounded-full blur-3xl pointer-events-none" />
    </div>
  );
}