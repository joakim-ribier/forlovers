# Pack d'icônes forlovers

Icône « cœur entrouvert » : le trait néon de la page d'accueil, qui arrive par la gauche, dessine
un cœur sans refermer son côté bas gauche, et repart vers la droite, comme un tracé qui continue.
Fond nuit, néon rose.

Ce dossier est la source de toutes les icônes : le site en utilise des copies (`public/`).
Pour changer une icône, la changer ici, puis relancer `./render.sh`, qui refait les PNG et le
`.ico` et recopie les fichiers servis dans `public/`.

## Fichiers

| Fichier | Usage |
|---|---|
| `icon.svg` | SVG maître (512), avec la lueur |
| `favicon.svg` | Favicon SVG pour 16–48 px : traits épaissis, sans flou |
| `favicon.ico` | 16 + 32 + 48 px, pour `/favicon.ico` et les vieux navigateurs |
| `favicon-16.png`, `favicon-32.png` | Favicons PNG |
| `apple-touch-icon.png` | 180 px, plein cadre (iOS arrondit lui-même), tiré de la version maskable |
| `icon-192.png`, `icon-512.png` | Icônes de l'écran d'accueil (Android, PWA) |
| `icon-maskable.svg`, `icon-maskable-512.png` | Version maskable Android : le cœur tient dans la zone de sécurité (72 %) |
| `og-image.html`, `og-image.png` | Image de partage 1200 × 630, rendue depuis la page HTML |
| `site.webmanifest` | Manifest de la page |
| `render.sh`, `ico.py` | Le rendu des PNG et l'assemblage du `.ico` |

## Palette

- Fond : `#1c1020` → `#07070b` (la nuit de la page), halo `#ff2d78` à 22 %
- Néon : `#ff2d78` (la lueur), `#ffe0eb` (le cœur du trait)
- Favicon : fond `#120a14`, traits pleins
- Arrondis : tuile `rx 112/512`, comme glowtrail

## Où chaque fichier est utilisé

| Où | Fichiers | Déclarés dans |
|---|---|---|
| Le site — `public/` | `favicon.ico`, `favicon.svg`, `apple-touch-icon.png`, `icon-192.png`, `icon-512.png`, `icon-maskable-512.png`, `site.webmanifest`, `og-image.png` | `src/layouts/Base.astro` ; `favicon.svg` sert aussi d'icône à la ligne forlovers.app de la liste (`src/data/apps.ts`) |

`icon.svg`, `icon-maskable.svg`, `favicon-16.png` et `favicon-32.png` ne sont copiés nulle part :
ce sont les sources et les variantes à disposition.

## Refaire les PNG

```bash
./brand/render.sh
```

Pas d'ImageMagick ni de convertisseur SVG nécessaire : Chrome sans fenêtre rend chaque SVG en
512 px (`--headless=new --default-background-color=00000000 --screenshot`), `sips` (macOS) le
réduit aux autres tailles, et `ico.py` assemble les PNG 16, 32 et 48 dans `favicon.ico` (le
format accepte des PNG). Chrome refuse les fenêtres trop petites, d'où le rendu en 512 puis la
réduction.
