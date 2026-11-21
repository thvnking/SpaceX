# CODEX_CONTEXT

## Source of truth

Read: `README.md` → `docs/GAME_DESIGN.md` → `docs/SYSTEMS.md` → `docs/CONTENT_SCHEMA.md` → `docs/IMPLEMENTATION.md` → `docs/ROADMAP.md` → UI specification and examples. The user's direct decisions and approvals take precedence. `SYSTEMS.md` is the authoritative numeric/mechanical baseline; `IMPLEMENTATION.md` describes the code as it exists and must not turn demo values into design.

## Approved design baseline (2026-11-21)

- Space Courier is a courier/ship-management adventure with occasional light combat. Keep crew and narrative content deferred.
- 10 systems, direct travel to any planet, 3 planet types, four Civilization hubs and six player-assigned sigils. Existing map names are provisional.
- The completed MAP screen is a side-map workflow: select systems on the sector canvas, zoom/pan, reset or jump to the current system, inspect planets and launch direct routes from the side panel. The side panel shows ETA and food/fuel quote and disables departure when docked/quote rules are not satisfied.
- Food and fuel start at 100 and drain continuously in space; food cap is 100, fuel cap is 100 base or 120 with the starter cell, rates are 0.018/s and 0.12/s. Hull is fixed at 5 and cannot be increased. Armor starts at 3, is static outside combat, and its maximum can be raised with equipment. Fuel zero strands the ship; food zero kills.
- Travel takes 30 seconds in-system and 2–10 minutes between systems by proportional map distance. No arrival refill.
- One two-choice tradeoff event roughly each 60 seconds; event clock pauses during combat and choice; no event in combat.
- Combat lasts at most 45 seconds; up to two weak enemies retreat at timeout or are eliminated.
- One ship, central 7×3 hull with two 3×1 side wings, based on supplied reference. Shared grid, fixed core cells, no stacking/overlap, 90-degree rotation, no mirroring/weight/adjacency bonus.
- At Civilization hubs: buy/sell the four basic equipment items, add/remove and rearrange. Elsewhere: rearrange carried items only. No inventory changes in flight/combat.
- Credit economy, single-trip no-deadline MVP deliveries, 50–100 Credit rewards, 5–15 reputation per delivery, seven cumulative reputation thresholds, fifth-failure Civilization fine/access choice. Details in `SYSTEMS.md`.
- Losing or selling required cargo before delivery fails that mission.
- One pre-departure autosave checkpoint, overwritten before next departure; manual saves; death choices New Game, Load Latest, Load Save.
- Equipment baseline: Recycling System, Auxiliary Fuel Cell, Armor Plating, ASECA. See `SYSTEMS.md` and `data/examples/items.md`.
- Extraction gathering, multi-trip/story missions, new equipment lines, ship purchases/upgrades/unlocks, additional ships, crew and extra hub services are deferred. The four basic equipment pieces are sold at Civilization hubs. Do not add gameplay beyond the documented baseline.

## Flight architecture clarification

The labels “A/B/D” appeared only in old notes and were never defined in the project files. They are not an approved technical decision and must not be used as a requirement. The approved behavior is described directly: autonomous, distance-timed travel; continuous resource drain; minute-scale event clock; event pause during combat/choice; fuel-zero stranding; pre-departure checkpoint. Choose a simple implementation that meets those behaviors.

## Demo data and implementation

The user has authorized replacing old demo assumptions with the values in `SYSTEMS.md`. When updating runtime data, make it consistent with the approved values; do not retain obsolete demo values just because they currently run. Use the supplied ship image as a visual guide, not as lore. Keep authored content separate from runtime logic and validate placements in the model layer.

## Change control

Do not reopen explicitly approved decisions as questions. Do not invent new features, lore, crew, missions or additional ships. If balance needs later adjustment, identify it as a proposed re-tune and update all affected documents/data together. See `ROADMAP.md` for the deferred scope and `IMPLEMENTATION.md` for the implementation gap list.
