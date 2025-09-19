import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Layout from "./Layout";
import Home from "./Pages/Home";
import Setup from "./Pages/Setup";
import Lobby from "./Pages/Lobby";
import Battle from "./Pages/Battle";
import LeaderDashboard from "./Pages/LeaderDashboard";
import Matches from "./Pages/Matches";
import MatchSummary from "./Pages/MatchSummary";

function App() {
  return (
    <Router>
      <div className="App">
        <Routes>
          <Route path="/" element={<Layout currentPageName="Home"><Home /></Layout>} />
          <Route path="/setup" element={<Layout currentPageName="Setup"><Setup /></Layout>} />
          <Route path="/lobby" element={<Layout currentPageName="Lobby"><Lobby /></Layout>} />
          <Route path="/battle" element={<Layout currentPageName="Battle"><Battle /></Layout>} />
          <Route path="/leader-dashboard" element={<Layout currentPageName="LeaderDashboard"><LeaderDashboard /></Layout>} />
          <Route path="/matches" element={<Layout currentPageName="Matches"><Matches /></Layout>} />
          <Route path="/match-summary" element={<Layout currentPageName="MatchSummary"><MatchSummary /></Layout>} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;
