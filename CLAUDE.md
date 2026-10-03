# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Start here

Before doing anything else, read **`90 MD для Claude/CLAUDE - Рабочий контекст.md`**. It holds how the GM likes to work, the canon decided so far, the current status and the open questions. Update it whenever a decision or the status changes.

## What this is

An Obsidian vault, not a software project: there is no build, lint, or test step. It holds worldbuilding and game-master notes for the tabletop RPG setting **Project 403: Forbidden**, run in **Pathfinder 2e** (remaster terms). All content is in **Russian**, so write new notes and edits in Russian unless asked otherwise.

The past campaign is **«Сумеречная Сфера Риверкель»**. The next one, **«Красная Вуаль»**, lives in this vault in `20 Кампании/Красная Вуаль/` (canon for the Kingdom of Мэн and the province of Пиверия); read it when a task touches Мэн. The old separate vault at `D:\Programs\Obsidian\Красная Вуаль\Красная Вуаль` is obsolete: ignore it.

## Layout

- Top-level folders are numbered so they sort logically: `10 Сеттинг` (world), `20 Кампании` (one subfolder per campaign), `30 Ваншоты`, `80 Картинки`, `90 MD для Claude`. Keep this scheme for new top-level folders (free numbers in between).
- The vault is a **git repository** (private, GitHub `YegorKandziuba/-OBSIDIAN-Project-403-Forbidden`, branch `main`). `.gitignore` excludes workspace state, the trash and plugin caches. Commit or push only when the GM asks.
- `Project 403 - Forbidden.md` (vault root, alias «Project 403: Forbidden») is the **home hub**: the entry point that links to every section hub. When you create a new section or a key note, add it there or to the matching section hub.
- `10 Сеттинг/` holds world-level lore that doesn't depend on any one campaign: geography (continents → states, with `ШАБЛОН - Государство.md` as the template for a new state), organizations (the Church of the Great Seven / «Великая Семерка» and the Order of the Eighth — both ~400 years gone in the current year 385, cults), world-shaping NPCs, in-world narrative texts, and `Допустимость наследий.md` (which PF2e heritages are allowed). `10 Сеттинг/Космология/` holds the world's cosmology: hub `Космология.md`, `Космология - план работы.md` (plan plus the decision log), the glossary, the transcription of the GM's handwritten notebook (the primary source), and topic notes. `Project 403 - Запрет.md` there is GM-only.
- `20 Кампании/Сумеречная Сфера Риверкель/` holds the campaign. The hub note `Сумеречная Сфера Риверкель.md` has frontmatter (`tags: campaign`, `status`, `system`, `start_date`) and links to the PCs, key NPCs and locations. Subfolders split the material by type: NPCs by importance tier (Сюжетные / Второстепенные / Третьестепенные / Компаньоны), PCs, locations, quests, treasures, homebrew rules (fate tokens, ability points), enemies, and sessions grouped by season (`Сезон 1`, `Сезон 2`).
  - Season 2 session prep uses `.canvas` files and the scene template `Сессии/Сезон 2/Сессия 1/Сцена - Шаблон.md` (purpose → exposition → social → encounter → consequences/transitions). Follow that structure for new scenes.
- `30 Ваншоты/` holds one-shots. `Приговор до полуночи/` is the adaptation of Paizo's *Mark of the Mantis*; its `00 - Концепция.md` is the source of truth (decisions, open questions, archive of rejected variants), and `FVTT/` holds Foundry VTT import files.
- `20 Кампании/Красная Вуаль/` is the next campaign (in preparation).
- `20 Кампании/Пепел Пророчества/` is a separate campaign/project in development.
- `90 MD для Claude/` contains condensed «CLAUDE - …» digests of key lore (NPCs, religion, the Riverkel disappearance, geography, cosmology) and the working-context note above. `CLAUDE - ссылки.md` indexes them. They are hand-written summaries of the fuller notes elsewhere in the vault. When canon changes in a source note, the matching digest may need the same update. Keep the two consistent. Read full source notes directly (e.g. `Писания о Великой Семерке`); no split copies are needed.
- The Riverkel campaign hub has a «Все материалы кампании» section listing every campaign note; keep it updated when adding or removing campaign files.
- Images live in `80 Картинки/`.
- Move, rename and delete files through the Obsidian CLI (`obsidian vault="Project 403" move|delete path=...`) so links update; it is enabled.

## Obsidian conventions

- Link notes with wikilinks (`[[Note]]`, `[[Note|alias]]`) and embed images with `![[image.png]]`. `alwaysUpdateLinks` is on, so renaming a file through Obsidian updates links automatically. Renaming it from the filesystem does **not**, so fix the links by hand if you rename or move files. Many links point to notes that don't exist yet; that's intentional (planned content), not a bug.
- Filenames are unique titles because wikilinks resolve by filename. Don't create a duplicate name in another folder.
- Callouts (`> [!info]`, `> [!quote]` for read-aloud text) are used throughout. Older notes contain ```` ```statblock ```` blocks, but **the GM does not use statblock plugins**: creatures, feats and items go to **Foundry VTT JSON** (PF2e system, remaster schema, UTF-8 without BOM, validated after writing). Game mechanics should be PF2e (3-action economy, PF2e traits/DCs), not D&D 5e.
- Don't edit `.obsidian/` or `.claudian/` unless explicitly asked.
