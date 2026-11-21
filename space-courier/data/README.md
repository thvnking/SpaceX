# Runtime content

Godot Resources (`.tres` / `.res`) are the current runtime format:

- `data/items/` — item definitions.
- `data/ships/` — ship footprints and fixed core cells.
- `data/planets/` — planets, Civilization access and basic market inventory.
- `data/travel/` — route durations and resource rates.
- `data/events/` — exactly two choices and their effects.
- `data/combat/` — encounter duration and enemy setup.
- `data/missions/` — single-trip delivery requirements and rewards.
- `data/game_setup.tres` — starting ship, planet, resources and loadout when authored.

`DemoContent` is the fallback used when no setup Resource exists and is synchronized with the official baseline. The complete side map is rendered by `scripts/galaxy_map.gd`; system-map definitions are still duplicated in `scripts/data/demo_content.gd` until a dedicated system resource is implemented.

Official start values and rules: food 100/100 at 0.018 per second, fuel 100/100 at 0.12 per second (the starter cell raises capacity to 120), hull 5 fixed, armor 3 baseline; 30-second same-system flights and 2–10-minute inter-system flights; no automatic planet refill; events roughly every minute outside combat; one autosave checkpoint before each departure; 45-second combat. See `docs/SYSTEMS.md` for full details.
