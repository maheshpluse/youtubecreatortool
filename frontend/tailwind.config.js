/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: 'class',
  content: [
    "./web/**/*.{html,js}",
    "./lib/**/*.dart"
  ],
  theme: {
    extend: {
      fontFamily: {
        'sans': ['Roboto', 'system-ui', '-apple-system', 'sans-serif'],
      },
      colors: {
        // YouTube Brand Colors
        yt: {
          red: '#FF0000',
          darkred: '#CC0000',
          blue: {
            light: '#3EA6FF', // Dark mode links
            dark: '#065FD4',  // Light mode links
          },
          // Grays used in YouTube UI
          gray: {
            50: '#F9F9F9',
            100: '#F1F1F1',
            200: '#E5E5E5',
            300: '#CCCCCC',
            400: '#AAAAAA',
            500: '#909090',
            600: '#717171',
            700: '#606060',
            800: '#282828', // Cards/Search bar in dark mode
            900: '#0F0F0F', // Main background in dark mode
            950: '#000000',
          }
        }
      },
    }
  },
  plugins: [],
}
