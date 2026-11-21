# Content Schema

This is the content contract for the approved single-ship MVP. Godot Resources are the current implementation format; definitions remain separate from saved instances. Add fields only when a documented system needs them.

## Ship status

`food` and `fuel` are capped travel supplies and drain continuously in space. `hull` and `armor` are combat durability, do not passively drain, and are not the same as the stationary economy values `credits` and `reputation`. Base food/fuel caps are 100; an approved equipment effect may raise fuel maximum to 120. Hull maximum is fixed at 5. Armor maximum/current can increase through equipment.

## ItemDefinition and ItemInstance

`ItemDefinition`: stable id, display name, type (`Cargo` or `Equipment`), occupied shape cells, tags, rarity (Common/Uncommon/Rare/Exceptional), origin, description, credit price metadata, effects, placement rules, and optional durability policy. `ItemInstance`: instance id, definition reference, grid position, rotation quarter-turns, state, optional durability, and delivered/lost state where applicable.

Cargo and equipment share a grid. No overlap, stacking, mirroring, weight or adjacency bonus. Rotation is 90 degrees. Invalid placement returns a reason. Fixed core ship cells are not item cells. Civilization hubs permit adding/removing and rearranging. Other worlds permit rearranging already-carried items only. No inventory changes in flight/combat.

### Approved initial ship

One 13×3 bounding grid: central 7×3 body, with a 3×1 wing on each side centered vertically. Cockpit, engine and energy room are fixed cells. The drawing supplied by the user is a visual reference, not a precise trace. Equipment loadout and exact component cell assignment should be authored as data and kept visually coherent.

### Approved initial equipment

| Equipment | Shape | Effect |
|---|---|---|
| Circular Recycling System | 2×1 | Every 5 food consumed grants 2 fuel, up to current fuel maximum; preserve fractional consumption between triggers. |
| Auxiliary Fuel Cell | 1×2 | Raises max fuel by 20; no instant refill. Maximum becomes 120 while installed. |
| Armor Plating | 2×1 | Raises armor maximum by 2; no instant repair. |
| ASECA satellite defense | 5-cell plus | Once per combat, absorbs one incoming projectile; activate with key 1. |

Start with Circular Recycling System and Armor Plating installed. Auxiliary Fuel Cell and ASECA are available at Civilization hubs. Basic equipment costs 200–350 Credits; starting credits are zero. No hidden effect from rarity or placement is implied.

## Planet and system

`PlanetDefinition`: stable id, display name, world type (`Civilization`, `Colony`, `Extraction`), system id, owner, resource notes, and hub permissions. Arrival does not refill supplies. The current side map is implemented by `GalaxyMapView`: it owns the 10-system presentation, selection, pan/zoom, current-system focus, planet orbit preview and six saved sigil markers. Names and positions remain duplicated between `GalaxyMapView` and demo setup until a dedicated `GalaxySystem` resource is introduced for production content.

## TravelDefinition

`TravelDefinition`: id, origin/destination planet ids, segment durations, resource drain rates and event/combat hooks. Direct destinations are unrestricted. ETA is 30 seconds within a system and linearly interpolated from 120 to 600 seconds between different systems according to map distance. Rates are food 0.018/s and fuel 0.12/s. Event schedule is runtime timed at about 60 seconds, pauses during combat and player choice, and has at most one pending event.

## EventDefinition

Exactly two choice labels and effects. Early outcomes usually trade one ship status for another: either uneven exchange (for example −1 food, +2 fuel) or even exchange (−1 food, +1 fuel). Clamp to resource limits. No event during combat. Event voice defaults to assistant; crew voice is deferred.

## MissionDefinition and progression

MVP mission requires cargo at a delivery planet in one trip, has no deadline, and fails if cargo is lost. Reward data uses Credits (50–100 typical) and reputation (+5–15 typical). Multi-trip story/high-tier missions are deferred. Seven cumulative reputation thresholds: 100, 300, 900, 2,700, 8,100, 24,300, 72,900. Rank unlocks are deferred.

Persist delivery failure counts per Civilization. At five failures, require a 1,000 Credit fine on next hub visit. Paying restores access; refusing blocks hub and its missions for the save.

## CombatDefinition

Initial combat duration is 45 seconds, with at most two weak enemies. Enemies enter from screen edges, orbit/circle the centered player ship, and fire; they do not ram or charge directly. Survivors retreat at timeout. Resolve on timer expiry or zero enemies. Armor absorbs hits before hull; one hit is one point. Special equipment maps to number keys. Keep encounter data content-driven; do not add weapon stats or damage rules beyond approved scope.

## Save schema

Save player resources, hull/armor, credits, reputation points/rank, inventory positions/states, current planet, missions, Civilization failure/access state and sigils. One autosave checkpoint immediately before each departure; manual saves are player-controlled and available only while docked. No timed/in-flight autosave. Death offers new game, latest save, or manual save selection.
