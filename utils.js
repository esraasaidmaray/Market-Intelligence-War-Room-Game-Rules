/**
 * Utility functions for the Market Intelligence War Room game
 */

/**
 * Creates a page URL for navigation
 * @param {string} pageName - The name of the page
 * @param {Object} params - Query parameters as key-value pairs
 * @returns {string} The formatted URL
 */
export const createPageUrl = (pageName, params = {}) => {
  const basePath = `/${pageName.toLowerCase()}`;
  
  if (Object.keys(params).length === 0) {
    return basePath;
  }
  
  const queryString = new URLSearchParams(params).toString();
  return `${basePath}?${queryString}`;
};

/**
 * Generates a unique match ID
 * @returns {string} A unique match identifier
 */
export const generateMatchId = () => {
  return `match_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
};

/**
 * Formats time remaining in MM:SS format
 * @param {number} seconds - Time in seconds
 * @returns {string} Formatted time string
 */
export const formatTimeRemaining = (seconds) => {
  const minutes = Math.floor(seconds / 60);
  const remainingSeconds = seconds % 60;
  return `${String(minutes).padStart(2, '0')}:${String(remainingSeconds).padStart(2, '0')}`;
};

/**
 * Calculates progress percentage
 * @param {number} completed - Number of completed items
 * @param {number} total - Total number of items
 * @returns {number} Progress percentage (0-100)
 */
export const calculateProgress = (completed, total) => {
  if (total === 0) return 0;
  return Math.round((completed / total) * 100);
};

/**
 * Validates email format
 * @param {string} email - Email address to validate
 * @returns {boolean} True if valid email format
 */
export const isValidEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

/**
 * Validates URL format
 * @param {string} url - URL to validate
 * @returns {boolean} True if valid URL format
 */
export const isValidUrl = (url) => {
  try {
    new URL(url);
    return true;
  } catch {
    return false;
  }
};

/**
 * Debounces a function call
 * @param {Function} func - Function to debounce
 * @param {number} wait - Wait time in milliseconds
 * @returns {Function} Debounced function
 */
export const debounce = (func, wait) => {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
};

/**
 * Gets team color classes
 * @param {string} team - Team name (Alpha or Delta)
 * @returns {Object} Color classes for the team
 */
export const getTeamColors = (team) => {
  const colors = {
    Alpha: {
      primary: 'from-cyan-400 to-blue-500',
      secondary: 'from-cyan-500 to-blue-600',
      border: 'border-cyan-500/30',
      text: 'text-cyan-400',
      bg: 'bg-cyan-500/10'
    },
    Delta: {
      primary: 'from-orange-400 to-red-500',
      secondary: 'from-orange-500 to-red-600',
      border: 'border-orange-500/30',
      text: 'text-orange-400',
      bg: 'bg-orange-500/10'
    }
  };
  return colors[team] || colors.Alpha;
};

/**
 * Maps sub-team to battle ID
 * @param {string} subTeam - Sub-team identifier (A1-D5)
 * @returns {string} Battle ID
 */
export const getBattleIdFromSubTeam = (subTeam) => {
  const battleMap = {
    'A1': 'leadership_recon',
    'D1': 'leadership_recon',
    'A2': 'product_arsenal',
    'D2': 'product_arsenal',
    'A3': 'funding_fortification',
    'D3': 'funding_fortification',
    'A4': 'customer_frontlines',
    'D4': 'customer_frontlines',
    'A5': 'alliance_forge',
    'D5': 'alliance_forge'
  };
  return battleMap[subTeam] || 'leadership_recon';
};

/**
 * Gets battle name from battle ID
 * @param {string} battleId - Battle identifier
 * @returns {string} Human-readable battle name
 */
export const getBattleName = (battleId) => {
  const battleNames = {
    'leadership_recon': 'Leadership Recon & Market Dominance',
    'product_arsenal': 'Product Arsenal & Social Signals Strike',
    'funding_fortification': 'Funding Fortification',
    'customer_frontlines': 'Customer Frontlines',
    'alliance_forge': 'Alliance Forge & Growth Offensive'
  };
  return battleNames[battleId] || 'Unknown Battle';
};

/**
 * Local storage helpers
 */
export const storage = {
  set: (key, value) => {
    try {
      localStorage.setItem(key, JSON.stringify(value));
    } catch (error) {
      console.error('Failed to save to localStorage:', error);
    }
  },
  
  get: (key, defaultValue = null) => {
    try {
      const item = localStorage.getItem(key);
      return item ? JSON.parse(item) : defaultValue;
    } catch (error) {
      console.error('Failed to read from localStorage:', error);
      return defaultValue;
    }
  },
  
  remove: (key) => {
    try {
      localStorage.removeItem(key);
    } catch (error) {
      console.error('Failed to remove from localStorage:', error);
    }
  }
};
