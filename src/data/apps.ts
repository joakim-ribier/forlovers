import type { Key } from '../i18n';

/** The apps listed on the home page. Texts live in src/i18n, under apps.<id>.*. */
export interface App {
  id: 'glowtrail' | 'hashboard' | 'forlovers';
  name: string;
  url: string;
  icon: string;
  /** The app's own accent, used when its row is open. */
  accent: string;
  /** Technology names: not translated. */
  stack: string[];
  /** Public source only: private repositories would be a 404 for visitors. */
  source?: { label: string; url: string };
  /** The page the visitor is on: no "Open" button, a "You're here" note instead. */
  here?: boolean;
  keys: { tagline: Key; body: Key; access: Key };
}

export const apps: App[] = [
  {
    id: 'glowtrail',
    name: 'glowtrail',
    url: 'https://glowtrail.forlovers.app',
    icon: '/apps/glowtrail.svg',
    accent: '#22d6ff',
    stack: ['Go', 'TypeScript', 'D3'],
    keys: {
      tagline: 'apps.glowtrail.tagline',
      body: 'apps.glowtrail.body',
      access: 'apps.glowtrail.access',
    },
  },
  {
    id: 'hashboard',
    name: 'hashboard',
    url: 'https://hashboard.forlovers.app',
    icon: '/apps/hashboard.svg',
    accent: '#00b4ff',
    stack: ['Go', 'React'],
    source: { label: 'axeos-dashboard', url: 'https://github.com/joakim-ribier/axeos-dashboard' },
    keys: {
      tagline: 'apps.hashboard.tagline',
      body: 'apps.hashboard.body',
      access: 'apps.hashboard.access',
    },
  },
  {
    id: 'forlovers',
    name: 'forlovers.app',
    url: 'https://www.forlovers.app',
    icon: '/favicon.svg',
    accent: '#ff2d78',
    stack: ['Astro', 'TypeScript', 'SVG'],
    here: true,
    keys: {
      tagline: 'apps.forlovers.tagline',
      body: 'apps.forlovers.body',
      access: 'apps.forlovers.access',
    },
  },
];
