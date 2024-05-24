// config/jest/cssTransform.js

module.exports = {
    process() {
      return 'module.exports = {};';
    },
    getCacheKey() {
      return 'cssTransform';
    },
  };
  