// @ts-check
import { defineConfig } from 'astro/config';

export default defineConfig({
  site: 'https://www.forlovers.app',
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
    routing: { prefixDefaultLocale: false },
  },
  build: { inlineStylesheets: 'always' },
});
