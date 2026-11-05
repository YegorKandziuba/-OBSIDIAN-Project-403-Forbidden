# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Start here

Before doing anything else, read **`90 MD для Claude/CLAUDE - Рабочий контекст.md`**. It holds how the GM likes to work, the canon decided so far, the current status and the open questions. Update it whenever a decision or the status changes.

## What this is

An Obsidian vault, not a software project: there is no build, lint, or test step. It holds worldbuilding and game-master notes for the tabletop RPG setting **Project 403: Forbidden**, run in **Pathfinder 2e** (remaster terms). All content is in **Russian**, so write new notes and edits in Russian unless asked otherwise.

The past campaign is **«Сумеречная Сфера Риверкель»**. The next one, **«Красная Вуаль»**, lives in this vault in `20 Кампании/Красная Вуаль/` (canon for the Kingdom of Мэн and the province of Пиверия); read it when a task touches Мэн. The old separate vault at `D:\Programs\Obsidian\Красная Вуаль\Красная Вуаль` is obsolete: ignore it.

## Layout

- Top-level folders are numbered so they sort logically: `10 Сеттинг` (world), `20 Кампании` (one subfolder per campaign), `30 Ваншоты`, `80 Картинки`, `90 MD для Claude`. Keep this scheme for new top-level folders (free numbers in between). Subfolders of `10 Сеттинг` are numbered too (`1 Космология`, `2 География Мира`, `3 Организации`, `4 NPC`, `5 Повествовательные записки`), as are the Riverkel NPC tiers; other campaign subfolders are not.
- The vault is a **git repository** (private, GitHub `YegorKandziuba/-OBSIDIAN-Project-403-Forbidden`, branch `main`). `.gitignore` excludes workspace state, the trash and plugin caches. Commit or push only when the GM asks.
- `Project 403 - Forbidden.md` (vault root, alias «Project 403: Forbidden») is the **home hub**: the entry point that links to every section hub. When you create a new section or a key note, add it there or to the matching section hub.
- `10 Сеттинг/` holds world-level lore that doesn't depend on any one campaign: geography (continents → states, with `ШАБЛОН - Государство.md` as the template for a new state), organizations (the Church of the Great Seven / «Великая Семерка» and the Order of the Eighth — both ~400 years gone in the current year 385, cults), world-shaping NPCs, in-world narrative texts, and `Допустимость наследий.md` (which PF2e heritages are allowed). `10 Сеттинг/1 Космология/` holds the world's cosmology: hub `Космология.md`, `Космология - план работы.md` (plan plus the decision log), the glossary, the transcription of the GM's handwritten notebook (the primary source), and topic notes. `Project 403 - Запрет.md` there is GM-only.
- `20 Кампании/Сумеречная Сфера Риверкель/` holds the campaign. The hub note `Сумеречная Сфера Риверкель.md` has frontmatter (`tags: campaign`, `status`, `system`, `start_date`) and links to the PCs, key NPCs and locations. Subfolders split the material by type: NPCs by importance tier in numbered folders (`1 Сюжетные`, `2 Второстепенные`, `3 Третьестепенные`, `4 Компаньоны`), PCs, locations, quests, treasures, homebrew rules (fate tokens, ability points), enemies, and sessions grouped by season (`Сезон 1`, `Сезон 2`).
  - Season 2 session prep uses `.canvas` files and the scene template `Сессии/Сезон 2/Сессия 1/Сцена - Шаблон.md` (purpose → exposition → social → encounter → consequences/transitions). Follow that structure for new scenes.
- `10 Сеттинг/FVTT/` holds world-level Foundry VTT JSON (e.g. the Bordeaux city guard); import guide `FVTT сеттинга - импорт.md`.
- `30 Ваншоты/` holds one-shots (currently none).
- `20 Кампании/Сломанная бусина/` is a mini-campaign (moved from `30 Ваншоты/` on 2026-11-03; it began as an adaptation of Paizo's one-shot *Mark of the Mantis* and outgrew it). Act I «Два дня в Бордо» (being played), Act II «Операция в Вертмюре» (scenes 01–05, 03.5); a later act is not decided. Its `00 - Концепция.md` is the source of truth (decisions, open questions, archive of rejected variants), and `00 - Хаб мастера.md` is the at-the-table hub and campaign hub (frontmatter `tags: campaign`). Only those two sit in the campaign root; everything else goes into numbered subfolders (kept numbered here, unlike other campaigns): `1 Сценарий` (scenes 01–05, 03.5, «Два дня в Бордо», «Изыскания»), `2 Персонажи игроков`, `3 НПС и враги` (incl. `НПС — Два дня в Бордо` for NPCs improvised at the table), `4 Правила` (archetype, rituals), `5 Раздатки` (incl. `Шифр/`), `6 Сессии` (`Сессия N - Сломанная бусина` logs: what was played, decisions after it), `7 Арты` (art prompts), `8 Служебное` («Отличия от оригинала», `FVTT/` JSON export — an archive; the live Foundry world, edited through fvtt-world-cli, is the source of truth for actors and items). Put a new note into the matching subfolder and link it from the hub — never drop it in the campaign root. Notes of this campaign carry the tag `сломанная-бусина`.
- Backup copies made before edits go **outside the vault**, to `D:\Programs\Obsidian\Project 403\_backup-claude\` (as `<Note>.<date>.md`), never into the vault itself.
- Setting notes follow the same idea: city material in the city's own folder (`Кирия/Города/Бордо/`), state material in the state's folder (`Кирия/Государства/Королевство Дэлюн/`), working methods (not lore) in `2 География Мира/Методика/`.
- `40 Соло-отыгровки/` holds one-on-one roleplays where Claude is the GM and the vault owner plays. One subfolder per story (hub, PC, log `<Name> - журнал`, GM secrets `<Name> - тайны мастера`). To resume, read the hub, the log and the secrets, continue from the last scene and append each new scene to the log. Not setting canon unless the GM decides so; must not affect the one-shot or campaigns.
- `20 Кампании/Красная Вуаль/` is the next campaign (in preparation).
- `20 Кампании/Пепел Пророчества/` is a separate campaign/project in development.
- `20 Кампании/Экспедиторы Её Величества/` is a finished mini-campaign set in 114 НЭ (played in D&D 5e before the vault existed). Treat it as lore canon for that era; do not port its 5e mechanics.
- `90 MD для Claude/` contains condensed «CLAUDE - …» digests of key lore (NPCs, religion, the Riverkel disappearance, geography, cosmology) and the working-context note above. `CLAUDE - ссылки.md` indexes them. They are hand-written summaries of the fuller notes elsewhere in the vault. When canon changes in a source note, the matching digest may need the same update. Keep the two consistent. Read full source notes directly (e.g. `Писания о Великой Семерке`); no split copies are needed.
- The Riverkel campaign hub has a «Все материалы кампании» section listing every campaign note; keep it updated when adding or removing campaign files.
- Images live in `80 Картинки/`. Vector maps (SVG with Inkscape layers) and their PowerShell generators live in `80 Картинки/Карты/` (guide: `Карты - как работать.md`). Generators overwrite the SVG; scripts must be saved as UTF-8 with BOM for Windows PowerShell 5.1.
- Move, rename and delete files through the Obsidian CLI (`obsidian vault="Project 403" move|delete path=...`) so links update; it is enabled.

## Obsidian conventions

- Link notes with wikilinks (`[[Note]]`, `[[Note|alias]]`) and embed images with `![[image.png]]`. `alwaysUpdateLinks` is on, so renaming a file through Obsidian updates links automatically. Renaming it from the filesystem does **not**, so fix the links by hand if you rename or move files. Many links point to notes that don't exist yet; that's intentional (planned content), not a bug.
- Filenames are unique titles because wikilinks resolve by filename. Don't create a duplicate name in another folder.
- Callouts (`> [!info]`, `> [!quote]` for read-aloud text) are used throughout. Older notes contain ```` ```statblock ```` blocks, but **the GM does not use statblock plugins**: creatures, feats and items go to **Foundry VTT JSON** (PF2e system, remaster schema, UTF-8 without BOM, validated after writing; use the full Foundry export format — `system._migration` with the schema version (0.955 for PF2e 7.10.x; without it PF2e silently drops the import), plus `folder`, `effects`, `flags`, `ownership`, `_stats`, and `_id` on embedded items). Game mechanics should be PF2e (3-action economy, PF2e traits/DCs), not D&D 5e.
- Don't edit `.obsidian/` or `.claudian/` unless explicitly asked.

## Writing Style & Human-First Formatting (CRITICAL)

The primary vault (`10 Сеттинг`, `20 Кампании`, `30 Ваншоты`) is read directly by the GM both for leisurely prep and under time pressure at the table (10–20 second lookup). Write for a human reader, never as a machine log.

1. **Canon by Default (NO inline status tags):**
   - Everything written in the main body of a note is canon by default.
   - **NEVER** write `*(утверждено)*`, dates of approval, or meta-comments (`не путать с...`, `собрано из решений`) inside the text of lore or adventure notes.
   - Put decision history, timestamps, and meta-warnings strictly into `90 MD для Claude/` or dedicated `00 - Концепция.md` files.
   - If a note contains unapproved ideas or proposals, isolate them at the very bottom of the section/note inside a collapsed callout: `> [!todo]- Идеи и предложения (не канон)`.

2. **Two-Layer Structure (Bullets + Literary Prose):**
   - For locations, districts, factions, NPCs, and scenes, always use a two-tier layout:
     - **Top layer (At-the-table quick scan):** 2–4 clean bullet points summarizing key facts (Status/Role, Atmosphere/Sensory details, Key Places/NPCs/Hooks).
     - **Bottom layer (Immersive reading):** Smooth, engaging literary/publicistic prose in natural Russian. Let the text breathe.

3. **Natural Russian Language (No "AI-ese"):**
   - Write in clear, idiomatic, literary Russian. Avoid bureaucratic phrasing (канцелярит), clumsy literal translations from English, stacked dashes (`— ... — ...`), and nested parentheses.
   - **Bold restraint:** Only bold the title/term at the very start of a bullet point. Never bold entire clauses or every second word inside a paragraph.

4. **Readable Hubs (No link walls):**
   - Never string 5+ wikilinks together on a single line separated by dots (`·`).
   - Format hub links as vertical lists where each link has a short, 5–10 word human-readable summary of what happens there or why the GM needs it.

5. **Tables only for numbers/short keys:**
   - Never put multi-sentence paragraphs into Markdown table cells (like NPC bios or long faction descriptions).
   - Use tables strictly for numbers, stats, schedules, or short 2–5 word lookups.
   - Format NPCs, factions, and multi-sentence descriptions as bulleted lists with sub-bullets.

6. **Keep `[!todo]-` blocks brief:**
   - Collapsed idea blocks (`> [!todo]- Идеи и предложения`) must stay short (max 3–5 concise bullet points).
   - Never dump multi-paragraph essays into a todo callout.
   - What goes into a todo block: content that was individually marked as a proposal and has not yet been played at the table. Anything already played in a session is an event and stays in the main text. A blanket "everything here is a proposal" header does not by itself move content into todo.

7. **Prose: less, plainer, earned:**
   - Write a prose paragraph only when it adds something the bullets don't (atmosphere of a place, an NPC's manner). If there is nothing to add, write no paragraph. Prose must not restate the bullets.
   - Test every sentence: would the GM say this aloud at the table? If not, rewrite or delete it.
   - Stop-list (the GM finds these artificial in Russian):
     - Empty flourish with no fact behind it: «Наставник — голос без лица: несколько строк шифра, которые спускаются с крыльев собора и решают, кому жить».
     - Calques from English: «ему отчаянно нужна вторая пара рук», «знает о муже больше, чем думает».
     - The "not X but Y" device: «глаза сухие — от бессонницы, а не от бесчувствия».
     - Bureaucratic phrasing (канцелярит): «это стыкуется со сделкой».
     - Rhythmic triads and colon chains that sound like advertising copy.
   - When the GM rewrites a paragraph in his own words, save it to `90 MD для Claude/CLAUDE - Рабочий контекст.md` as a style reference and imitate it. The GM's own older texts (written without Claude) are the model voice.
