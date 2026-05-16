/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Onboarding from './pages/Onboarding';
import Login from './pages/Login';
import Register from './pages/Register';
import Home from './pages/Home';
import Boutique from './pages/Boutique';
import Referral from './pages/Referral';
import Profile from './pages/Profile';
import PhotoMode from './pages/PhotoMode';
import Processing from './pages/Processing';
import Result from './pages/Result';
import Credits from './pages/Credits';

export default function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Onboarding />} />
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />
        <Route path="/home" element={<Home />} />
        <Route path="/boutique" element={<Boutique />} />
        <Route path="/referral" element={<Referral />} />
        <Route path="/profile" element={<Profile />} />
        <Route path="/photo-mode" element={<PhotoMode />} />
        <Route path="/processing" element={<Processing />} />
        <Route path="/result" element={<Result />} />
        <Route path="/credits" element={<Credits />} />
      </Routes>
    </Router>
  );
}
