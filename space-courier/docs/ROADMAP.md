# Roadmap and decisions

This file tracks the delivery order. The approved gameplay baseline lives in `GAME_DESIGN.md` and `SYSTEMS.md`; this file must not contradict them.

## Phase 1 — playable single-ship MVP

- One authored ship, galaxy map with 10 provisional systems, direct planet-to-planet travel, ETA and resource preflight.
- Food and fuel drain continuously while the ship is in space, including when stopped. Fuel zero stops travel; food zero kills the player.
- Two-choice events at roughly one-minute intervals outside combat. No events run during combat.
- One ship physical grid shared by cargo and equipment. At Civilization hubs players may buy/sell the four basic equipment items, add/remove items and rearrange; elsewhere they may rearrange carried items only. All inventory changes are locked in flight.
- Single-trip delivery missions, credit rewards, reputation ranks, failure counts and Civilization access penalty.
- Basic equipment buy/sell market at Civilization hubs, light combat, manual saves, one pre-departure autosave checkpoint and death choices.
- Complete side map: select systems, inspect planets, assign saved sigils, reset/jump map view and launch direct routes from side-panel planet actions.

## Phase 2 — balance and content

- Tune routes, event pools, enemy variants, cargo, equipment prices and reward ranges using play sessions.
- Playtest and tune the approved basic equipment effects, combat controls and route balance.
- Playtest side-map readability and improve map/item content authoring while retaining direct, unrestricted destination selection.

## Phase 3 — deferred expansion

- Multi-trip high-tier/story missions; extraction and resource gathering; additional ships and physical layouts; new equipment lines and ship upgrade/unlock progression.
- Crew, NPC story content, additional hub services and exploration systems.
- Do not build these as MVP features. UI references may reserve space for later work.

## Decisions still open

The user has authorized the baseline values below as official starting design, with balancing permitted after playtesting. These are not open decisions. Remaining content choices are limited to:

- Canonical names and lore for systems, planets, factions and characters. Current map names remain provisional labels.
- Final art assets, exact visual silhouette interpretation and visual-cell artwork for the supplied ship reference.
- Specific story mission plots and event writing; no story or crew content is being authored now.
- Enemy roster and detailed movement/weapon patterns beyond the documented non-rushing orbiting behavior; keep early enemies weak.
- Extraction resource loop, multi-trip mission rules and additional ship layouts, all explicitly deferred.
- Final numeric balance after the game is playable. Any rebalance must update `SYSTEMS.md`, `GAME_DESIGN.md`, `IMPLEMENTATION.md`, and relevant data examples together.

## Change control

The resource model, travel ranges, combat baseline, economy, save behavior and inventory access in `SYSTEMS.md` are official decisions from 2026-11-21. Do not restore the old demo values as canon. Clearly label later proposals until approved; update all linked documents when changing an approved rule.
