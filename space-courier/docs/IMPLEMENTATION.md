# Implementation status and gap analysis

The project has a Godot runtime, data definitions and a playable official MVP profile. This file records the implemented baseline and the intentionally deferred scope.

## Present in code

- Content definitions for ships, items, planets, travel, events, combat and missions; shared cargo/equipment grid; overlap, boundary, tag-rule validation, 90-degree rotation and rejection reasons.
- Complete ten-system side-map flow: click selection, wheel zoom, drag pan, reset/current-system controls, schematic system view, selected-system panel, direct planet route buttons with ETA/resource quote, and player-assigned six-sigil markers.
- Direct travel definitions among demo planets, ETA/resource quote, travel drain, event pause, arrival and food-zero death handling.
- Delivery, buy/sell economy, 45-second combat encounter model, manual save slots, pre-departure checkpoint and death choices.
- Menu, map, ship, orders, hub, settings, credits, save UI, event and combat overlays.

## Intentionally deferred or simplified

- The map display and demo content still duplicate system data until a dedicated system resource is introduced; this is the remaining authoring debt, not a missing player-facing feature.
- Crew, extraction, multi-leg missions, additional ships, unlock trees and narrative content remain deferred.
- Combat is intentionally light: enemies orbit the ship in the encounter model, the player can fire or use ASECA, and weak incoming damage is applied on a fixed cadence.
- UI contains future crew/navigation references and an empty crew concept; these are visual planning only. Crew is deferred.
- `project.godot` currently configures a 1440×900 viewport (16:10), while the UI specification names 2560×1440 as a 16:9 reference. Treat the latter as a reference mock size; responsive scaling and the final player viewport still need to be aligned in the UI implementation pass.

## Approved design data

| Area | Official baseline | Implementation status |
|---|---|---|
| Ship | One central 7×3 footprint, two 3×1 side wings; core cockpit/engine/energy room | Official layout implemented |
| Starting ship values | Food 100, fuel 100, hull 5, armor 3; installed cell raises fuel capacity to 120, installed plating raises armor maximum to 5 | Old start values; replace |
| Passive rates | Food 0.018/s, fuel 0.12/s; 100 base caps; hull fixed, armor static | Official values implemented |
| Travel | 30s within system, 2–10min inter-system by map distance | Official formula implemented |
| Arrival | No automatic refill | Implemented |
| Events | About every 60s; exactly two choices; pause cadence during combat | Runtime timing implemented; one authored MVP event |
| Economy | Credit; delivery 50–100, reputation +5–15, seven ranks; 5 failures cause fine/block choice | Official MVP values implemented |
| Basic market | Recycling System + Armor start installed; Auxiliary Fuel Cell 250 Credits; ASECA 300 Credits | Implemented; all four items stocked at Civilization hubs |
| Saves | Single checkpoint before departure plus manual saves; death choices | Implemented |
| Combat | 45-second timer, at most two weak enemies | Official MVP loop implemented |

Starter equipment: Circular Recycling System (2×1; every 5 food consumed grants 2 fuel), Auxiliary Fuel Cell (1×2; +20 fuel capacity, no instant refill), Armor Plating (2×1; +2 armor capacity, no instant repair), ASECA satellite defense (5-cell plus shape; absorb one projectile once per combat; key 1). Capacity bonuses do not restore consumed resources on installation. These effects are implemented and are the complete initial equipment set.

## Build order

1. Playtest the completed side-map → route quote → departure flow and tune readability.
2. Balance route durations, resource drain, event cadence, combat damage and equipment prices.
3. Replace duplicated demo map arrays with a dedicated `GalaxySystem` resource when production content begins.
4. Add only the approved deferred systems after the single-ship loop is stable.

## Provisional authored map content

Names and resources below remain placeholder labels, not canon lore. Civilization worlds are in systems 01, 04, 07, 09.

| System | Current labels |
|---|---|
| 01 Orison | Launch Port (Civilization); Pallas Reach (Colony) |
| 02 Veyra | Waystation (Colony); Cobalt Shelf (Extraction: Cobalt, Nickel) |
| 03 Serein | Lumen (Colony); Orrery-3 (Extraction: Silicates) |
| 04 Caldera | Harbor Station (Civilization); Redoubt (Colony) |
| 05 Morrow | Morrow Haven (Colony); The Shards (Extraction: Iron, Rare earths) |
| 06 Ilyon | Sable (Colony); Vesper Quarry (Extraction: Titanium) |
| 07 Aster | Aster Commons (Civilization); Verdant Moon (Extraction: Bio-gel) |
| 08 Nacre | Nacre One (Colony); Deepwell (Extraction: Helium-3) |
| 09 Cinder | Cinderfall (Civilization); Ashline (Colony) |
| 10 Pelagos | Pelagos Station (Colony); Blue Vault (Extraction: Water ice) |
