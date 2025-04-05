module.exports = {
  env: {
    es6: true,
    node: true,
    es2020: true, // Add this to enable ES2020+ features
  },
  parserOptions: {
    ecmaVersion: 2020, // Update to 2020 (or 12 for Node 18 compatibility)
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "quotes": ["error", "double", {"allowTemplateLiterals": true}],
  },
  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true,
      },
      rules: {},
    },
  ],
  globals: {},
};
