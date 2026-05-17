import type { Config } from 'tailwindcss';

const config: Config = {
  content: ['./app/**/*.{ts,tsx}', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        accent: {
          primary: 'rgb(var(--color-accent-primary) / <alpha-value>)',
          secondary: 'rgb(var(--color-accent-secondary))',
        },
        surface: {
          primary: 'rgb(var(--color-surface-primary) / <alpha-value>)',
          secondary: 'rgb(var(--color-surface-secondary) / <alpha-value>)',
          tertiary: 'rgb(var(--color-surface-tertiary) / <alpha-value>)',
        },
        label: {
          primary: 'rgb(var(--color-label-primary) / <alpha-value>)',
          secondary: 'rgb(var(--color-label-secondary) / <alpha-value>)',
          tertiary: 'rgb(var(--color-label-tertiary) / <alpha-value>)',
          quaternary: 'rgb(var(--color-label-quaternary) / <alpha-value>)',
          quinary: 'rgb(var(--color-label-quinary) / <alpha-value>)',
        },
        separator: 'rgb(var(--color-separator) / <alpha-value>)',
        mark: 'rgb(var(--color-mark) / <alpha-value>)',
        'mark-muted': 'rgb(var(--color-mark-muted))',
        warning: 'rgb(var(--color-warning) / <alpha-value>)',
        'warning-muted': 'rgb(var(--color-warning-muted))',
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
