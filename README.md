<p align="center">
  <img src="brand/icon.svg" alt="forlovers" width="128">
</p>

# forlovers

🌐 **[www.forlovers.app](https://www.forlovers.app)**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Astro](https://img.shields.io/badge/Astro-7-BC52EE?logo=astro&logoColor=white)](package.json)
[![TypeScript](https://img.shields.io/badge/TypeScript-strict-3178C6?logo=typescript&logoColor=white)](tsconfig.json)

![forlovers.app](docs/screenshot.png)

Prérequis : Node 26, Google Chrome (pour `make brand`).

## Commandes

```bash
make help       # toutes les commandes
make init       # écrit .env (FORLOVERS_DEPLOY_HOST)
make dev        # http://localhost:4321, rechargé à chaque modification
make build      # astro check + build → dist/
make preview    # sert dist/
make brand      # refait les PNG et le .ico depuis brand/
make deploy     # build + rsync vers le serveur
```

## Fichiers

| Chemin | Contenu |
|---|---|
| `src/components/Home.astro` | la page |
| `src/components/NeonHeart.astro` | le cœur néon |
| `src/components/AppList.astro` | la liste des apps |
| `src/data/apps.ts` | les apps |
| `src/i18n/en.json` | les textes |
| `brand/` | logo et icônes ([`brand/README.md`](brand/README.md)) |
| `deploy/` | nginx et raccourcis du serveur |
| `public/` | fichiers servis tels quels |

## Ajouter une app

1. Une entrée dans `src/data/apps.ts`.
2. Ses textes `apps.<id>.*` dans `src/i18n/en.json`.
3. Son icône dans `public/apps/`.

`source` : seulement pour un dépôt public.

## Ajouter une langue

1. `src/i18n/en.json` → `src/i18n/fr.json`, traduit.
2. `src/i18n/index.ts` : `const dictionaries = { en, fr }`.
3. `astro.config.mjs` : `locales: ['en', 'fr']`.
4. `src/pages/fr/index.astro` : `<Home locale="fr" />`.

## Déploiement

### 1re fois

1. DNS : `A @` et `A www` → l'IP du serveur, sans proxy.
2. Sur le Mac :

   ```bash
   make init
   make deploy
   ```

3. Sur le serveur :

   ```bash
   cd forlovers && make install
   ```

### Ensuite

```bash
make deploy
```

`make install` seulement si `deploy/` a changé. Relançable sans risque.

### Raccourcis serveur

| Raccourci | Rôle |
|---|---|
| `forlovers` | `cd ~/forlovers` |
| `forlovers-install` | `make install` |
| `forlovers-status` | réponse du site, expiration du certificat |
| `forlovers-logs` | logs nginx en direct |
| `forlovers-help` | la liste |

## Licence

[MIT](LICENSE) © 2026 Joakim Ribier
