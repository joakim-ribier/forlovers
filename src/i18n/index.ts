import en from './en.json';

/** English is the reference: every other locale must provide the same keys. */
export type Key = keyof typeof en;
export type Dict = Record<Key, string>;

const dictionaries = { en } satisfies Record<string, Dict>;

export type Locale = keyof typeof dictionaries;
export const defaultLocale: Locale = 'en';
export const locales = Object.keys(dictionaries) as Locale[];

/** Returns t(key, vars): looks up the key in the locale, falls back to English, fills {placeholders}. */
export function useTranslations(locale: Locale) {
  const dict: Dict = dictionaries[locale] ?? dictionaries[defaultLocale];
  return (key: Key, vars: Record<string, string> = {}) =>
    (dict[key] ?? en[key]).replace(/\{(\w+)\}/g, (_, name: string) => vars[name] ?? `{${name}}`);
}
