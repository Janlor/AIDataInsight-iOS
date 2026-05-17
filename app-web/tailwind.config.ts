import type { Config } from 'tailwindcss';

const config: Config = {
  content: ['./app/**/*.{ts,tsx}', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        accent: {
          primary: '#2F7BFF',
          secondary: '#1A2F7BFF',
        },
        surface: {
          primary: '#FFFFFF',
          secondary: '#F4F7FB',
          tertiary: '#EEF3FA',
        },
        label: {
          primary: '#111827',
          secondary: '#5B6475',
          tertiary: '#8A94A6',
        },
        separator: '#E5EAF3',
        mark: '#FF5A6B',
      },
      borderRadius: {
        control: '6px',
      },
      boxShadow: {
        panel: '0 16px 40px rgb(15 23 42 / 0.08)',
      },
    },
  },
  plugins: [],
};

export default config;
