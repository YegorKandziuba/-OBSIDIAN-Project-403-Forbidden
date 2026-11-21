# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Start here

Before doing anything else, read **`90 MD для Claude/CLAUDE - Рабочий контекст.md`**. It holds how the GM likes to work, the current status, the open questions and the style references. Update it whenever a decision or the status changes, and keep it short (one or two screens): history of decisions goes into the journals described below, not into the working context.

## What this is

An Obsidian vault, not a software project: there is no build, lint, or test step. It holds worldbuilding and game-master notes for the tabletop RPG setting **Project 403: Forbidden**, run in **Pathfinder 2e** (remaster terms). All content is in **Russian**, so write new notes and edits in Russian unless asked otherwise.

Campaigns live in `20 Кампании/`: the finished **«Сумеречная Сфера Риверкель»**, the running mini-campaign **«Сломанная бусина»**, the next one **«Красная Вуаль»** (canon for the Kingdom of Мэн and the province of Пиверия; read it when a task touches Мэн), plus the projects **«Пепел Пророчества»** and **«Экспедиторы Её Величества»**. The old separate vault at `D:\Obsidian\Красная Вуаль\Красная Вуаль` is obsolete: ignore it.

## Layout

### Top level and git

- Top-level folders are numbered so they sort logically: `10 Сеттинг` (world), `20 Кампании` (one subfolder per campaign), `30 Ваншоты` (one-shots, currently none), `40 Соло-отыгровки`, `50 Мастерская`, `80 Картинки`, `90 MD для Claude`. Keep this scheme for new top-level folders (free numbers in between). Subfolders of `10 Сеттинг` are numbered too (`1 Космология`, `2 География Мира`, `3 Организации`, `4 NPC`, `5 Повествовательные записки`), as are the Riverkel NPC tiers and the subfolders of «Сломанная бусина»; other campaign subfolders are not.
- The vault is a **git repository** (private, GitHub `YegorKandziuba/-OBSIDIAN-Project-403-Forbidden`, branch `main`). `.gitignore` excludes workspace state, the trash and plugin caches. Commit or push only when the GM asks.
- `Project 403 - Forbidden.md` (vault root, alias «Project 403: Forbidden») is the **home hub**: the entry point that links to every section hub. When you create a new section or a key note, add it there or to the matching section hub.
- Images live in `80 Картинки/`. Vector maps (SVG with Inkscape layers) and their PowerShell generators live in `80 Картинки/Карты/` (guide: `Карты - как работать.md`). Generators overwrite the SVG; scripts must be saved as UTF-8 with BOM for Windows PowerShell 5.1.

### Setting (`10 Сеттинг/`)

- World-level lore that doesn't depend on any one campaign: geography (continents → states, with `ШАБЛОН - Государство.md` as the template for a new state), organizations (the Church of the Great Seven / «Великая Семерка» and the Order of the Eighth — both ~400 years gone in the current year 385, cults), world-shaping NPCs, in-world narrative texts, and the notes on allowed heritages and backgrounds.
- City material lives in the city's own folder (`Кирия/Города/Бордо/`), state material in the state's folder (`Кирия/Государства/Королевство Дэлюн/`), working methods (not lore) in `2 География Мира/Методика/`.
- `1 Космология/` holds the cosmology: hub `Космология.md`, `Космология - план работы.md` (the step plan), the glossary, the transcription of the GM's handwritten notebook (the primary source) and topic notes. `Project 403 - Запрет.md` there is GM-only.
- `FVTT/` holds world-level Foundry VTT JSON (e.g. the Bordeaux city guard); import guide `FVTT сеттинга - импорт.md`.

### Campaigns (`20 Кампании/`)

- **Сумеречная Сфера Риверкель:** the hub note `Сумеречная Сфера Риверкель.md` has frontmatter (`tags: campaign`, `status`, `system`, `start_date`) and links to the PCs, key NPCs and locations. Subfolders split the material by type: NPCs by importance tier in numbered folders (`1 Сюжетные`, `2 Второстепенные`, `3 Третьестепенные`, `4 Компаньоны`), PCs, locations, quests, treasures, homebrew rules (fate tokens, ability points), enemies, and sessions grouped by season (`Сезон 1`, `Сезон 2`). Its hub has a «Все материалы кампании» section listing every campaign note; keep it updated when adding or removing files. Season 2 session prep uses `.canvas` files and the scene template `Сессии/Сезон 2/Сессия 1/Сцена - Шаблон.md` (purpose → exposition → social → encounter → consequences/transitions); follow that structure for new scenes.
- **Сломанная бусина:** a mini-campaign that began as an adaptation of Paizo's one-shot *Mark of the Mantis* and outgrew it. Act I «Два дня в Бордо» is being played, Act II «Операция в Вертмюре» is scenes 01–05 and 03.5; a later act is not decided. Where there is no reason to deviate, stay close to the original adventure.
  - `00 - Концепция.md` is the source of truth for the story (world, antagonists, roles). Decisions, open questions, plan and archive of rejected variants live in `8 Служебное/Журнал решений - Сломанная бусина.md`. `00 - Хаб мастера.md` is the at-the-table hub and the campaign hub (frontmatter `tags: campaign`).
  - Only those two sit in the campaign root; everything else goes into numbered subfolders: `1 Сценарий`, `2 Персонажи игроков`, `3 НПС и враги` (incl. `НПС — Два дня в Бордо` for NPCs improvised at the table), `4 Правила`, `5 Раздатки` (incl. `Шифр/`), `6 Сессии` (`Сессия N - Сломанная бусина` logs: what was played, decisions after it), `7 Арты` (art prompts), `8 Служебное` («Отличия от оригинала», `FVTT/` JSON export — an archive; the live Foundry world, edited through fvtt-world-cli, is the source of truth for actors and items). Put a new note into the matching subfolder and link it from the hub; never drop it in the campaign root. Notes of this campaign carry the tag `сломанная-бусина`.
- **Красная Вуаль:** the next campaign (in preparation).
- **Пепел Пророчества:** a separate campaign/project in development.
- **Экспедиторы Её Величества:** a finished mini-campaign set in 114 НЭ (played in D&D 5e before the vault existed). Treat it as lore canon for that era; do not port its 5e mechanics.

### Other folders

- `50 Мастерская/` holds the GM's working methods that apply to every campaign (not lore). **Before helping to design or write any combat encounter, read `50 Мастерская/Принципы боевых сцен.md` and follow it** (XP budget, map, enemy roles, morale and retreat, enemy algorithm written two ways: a 3-round script plus ~5 prioritised if-then options).
- `40 Соло-отыгровки/` holds one-on-one roleplays where Claude is the GM and the vault owner plays. One subfolder per story (hub, PC, log `<Name> - журнал`, GM secrets `<Name> - тайны мастера`). To resume, read the hub, the log and the secrets, continue from the last scene and append each new scene to the log. Not setting canon unless the GM decides so; must not affect the campaigns.
- `90 MD для Claude/` is service material, not for reading at the table:
  - condensed «CLAUDE - …» digests of key lore (NPCs, religion, the Riverkel disappearance, geography, cosmology), indexed by `CLAUDE - ссылки.md`; they are hand-written summaries of the fuller notes elsewhere, so when canon changes in a source note, update the matching digest too;
  - decision journals («CLAUDE - Бордо - журнал решений», «CLAUDE - Космология - журнал решений»): what was decided and when;
  - the working-context note.
  Read full source notes directly (e.g. `Писания о Великой Семерке`); no split copies are needed.

## Working rules

- **Backups.** Before editing a note, copy it **outside the vault** to `D:\Obsidian\Project 403\_backup-claude\` (as `<Note>.<date>.md`), never into the vault itself.
- **Moving files.** Move, rename and delete files through the Obsidian CLI (`obsidian vault="Project 403" move|delete path=...`) so links update; it is enabled.
- **Bulk edits.** Replace whole phrases, never single characters, and make sure a one-pair list is not unrolled by the script. After a scripted edit compare each file with its backup: only the intended lines may differ. Report only discrepancies, not full dumps (it saves the GM's usage limit).
- **Working in steps.** Do one file or one group at a time, then stop for the GM's check. Show a short summary: what changed, what you decided yourself and what to verify.

## Obsidian conventions

- Link notes with wikilinks (`[[Note]]`, `[[Note|alias]]`) and embed images with `![[image.png]]`. `alwaysUpdateLinks` is on, so renaming a file through Obsidian updates links automatically. Renaming it from the filesystem does **not**, so fix the links by hand if you rename or move files.
- Links to notes that don't exist yet are allowed (planned content). But once a missing target is mentioned in three or more notes, create a short placeholder in the right folder: `status: Заглушка`, a few bullets with what is already known from the vault, and a collapsed idea block for guesses.
- Filenames are unique titles because wikilinks resolve by filename. Don't create a duplicate name in another folder.
- Callouts (`> [!info]`, `> [!quote]` for read-aloud text) are used throughout. Older notes contain ```` ```statblock ```` blocks, but **the GM does not use statblock plugins**: creatures, feats and items go to **Foundry VTT JSON** (PF2e system, remaster schema, UTF-8 without BOM, validated after writing; use the full Foundry export format — `system._migration` with the schema version (0.955 for PF2e 7.10.x; without it PF2e silently drops the import), plus `folder`, `effects`, `flags`, `ownership`, `_stats`, and `_id` on embedded items). Game mechanics should be PF2e (3-action economy, PF2e traits/DCs), not D&D 5e. Do not change PF2e rules with homebrew; reskin and narrative justification are fine.
- Don't edit `.obsidian/` or `.claudian/` unless explicitly asked.

## Writing Style & Human-First Formatting (CRITICAL)

The primary vault (`10 Сеттинг`, `20 Кампании`, `30 Ваншоты`) is read directly by the GM both for leisurely prep and under time pressure at the table (10–20 second lookup). Write for a human reader, never as a machine log.

1. **Canon by Default (NO inline status tags):**
   - Everything written in the main body of a note is canon by default.
   - **NEVER** write `*(утверждено)*`, dates of approval, or meta-comments (`не путать с...`, `собрано из решений`) inside the text of lore or adventure notes.
   - Put decision history, timestamps, and meta-warnings strictly into `90 MD для Claude/`, the campaign's decision journal, or its `00 - Концепция.md`.
   - If a note contains unapproved ideas or proposals, isolate them at the very bottom of the section/note inside a collapsed callout: `> [!todo]- Идеи и предложения (не канон)`.

2. **Two-Layer Structure (Bullets + Literary Prose):**
   - For locations, districts, factions, NPCs, and scenes, use a two-tier layout:
     - **Top layer (At-the-table quick scan):** 2–4 clean bullet points summarizing key facts (Status/Role, Atmosphere/Sensory details, Key Places/NPCs/Hooks, DCs).
     - **Bottom layer (Immersive reading):** short, natural prose, only if it adds something (see rule 7).

3. **Natural Russian Language (No "AI-ese") and bold:**
   - Write in clear, idiomatic Russian. Avoid bureaucratic phrasing (канцелярит), clumsy literal translations from English, stacked dashes (`— ... — ...`), and nested parentheses.
   - **Bold is for skimming.** It marks the few most important words (a name, a term, a number, a DC, a key consequence) so the eye can catch the gist of a text by running down it diagonally. Rules: bold only the 1–3 words that carry the meaning of a bullet or paragraph, never a whole clause, never every second word. If bolding every bold word of a note in a row does not tell the gist, the choice is wrong. Bold at the start of a bullet (the term or title) is the usual case, not the only one.

4. **Readable Hubs (No link walls):**
   - Never string 5+ wikilinks together on a single line separated by dots (`·`).
   - Format hub links as vertical lists where each link has a short, 5–10 word human-readable summary of what happens there or why the GM needs it.

5. **Tables only for numbers/short keys:**
   - Never put multi-sentence paragraphs into Markdown table cells (like NPC bios or long faction descriptions).
   - Use tables strictly for numbers, stats, schedules, or short 2–5 word lookups. A page that is about numbers (economy, prices, DCs) keeps its tables.
   - Format NPCs, factions, and multi-sentence descriptions as bulleted lists with sub-bullets: **Name** *(who)* — one or two living sentences; then *Чего хочет:* and *Крючок:* as sub-bullets when they are decided.

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

8. **Status of a note.** `status` in frontmatter takes one of: `Идея`, `Заглушка`, `Черновик`, `В игре`, `Сыграно`, `Канон`, `Архив`. Every note in the primary vault has frontmatter with `tags` and `status`.
