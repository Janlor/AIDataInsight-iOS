'use client';

import { create } from 'zustand';

export type AppLocale = 'zh-Hans' | 'en';

const storageKey = 'aidatainsight.locale';

interface I18nStore {
  locale: AppLocale;
  isHydrated: boolean;
  hydrate: () => void;
  setLocale: (locale: AppLocale) => void;
}

export const useI18nStore = create<I18nStore>((set) => ({
  locale: 'zh-Hans',
  isHydrated: false,
  hydrate: () => {
    if (typeof window === 'undefined') {
      set({ isHydrated: true });
      return;
    }

    const stored = normalizeLocale(window.localStorage.getItem(storageKey));
    const detected = normalizeLocale(window.navigator.language);
    set({ locale: stored ?? detected ?? 'zh-Hans', isHydrated: true });
  },
  setLocale: (locale) => {
    if (typeof window !== 'undefined') {
      window.localStorage.setItem(storageKey, locale);
      document.documentElement.lang = locale === 'en' ? 'en' : 'zh-Hans';
    }
    set({ locale });
  },
}));

function normalizeLocale(value: string | null | undefined): AppLocale | null {
  if (!value) {
    return null;
  }
  return value.toLowerCase().startsWith('en') ? 'en' : 'zh-Hans';
}

