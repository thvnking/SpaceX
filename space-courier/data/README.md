# Runtime content

Runtime content is loaded from Godot Resources (`.tres` / `.res`) in these folders:

- `data/items/` — `ItemDefinition` resources.
- `data/ships/` — `ShipDefinition` resources.
- `data/planets/` — `PlanetDefinition` resources.
- `data/travel/` — `TravelDefinition` resources.
- `data/events/` — `EventDefinition` resources.
- `data/combat/` — `CombatDefinition` resources.
- `data/missions/` — `MissionDefinition` resources.
- `data/game_setup.tres` — the approved starting planet, ship, resources, hull value and optional starting items.

If `game_setup.tres` is absent, the project installs a small temporary scenario from `scripts/data/demo_content.gd` so the MVP loop can be exercised. These values were authorized for demo use and are not final design decisions. Replace them with approved Resources as the design is refined; remaining production decisions are listed in `docs/ROADMAP.md`.

The current map demo contains 10 star systems and 20 planets. Planet definitions carry a system id, one of three world types (Civilization, Colony, Extraction), Mars ownership information, resource notes, and refill data. The star names, map coordinates, planetary names, resource notes, direct-trip timing formula, and rates are temporary demo content. The system list is currently mirrored in `scripts/galaxy_map.gd` and `scripts/data/demo_content.gd`; keep these definitions synchronized until the map is migrated to dedicated GalaxySystem resources. Direct travel is generated between every ordered pair of distinct planets, with food/fuel affordability checked before departure.
