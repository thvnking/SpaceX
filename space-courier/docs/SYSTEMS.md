# Systems Specification — approved baseline

This is the authoritative gameplay reference. Values below are the official initial balance authorized on 2026-11-21. Rebalance through playtesting, not by treating the old demo profile as canon.

## Ship resources and survival

The four ship status values are:

| Status | Start | Maximum | Passive behavior |
|---|---:|---:|---|
| Food | 100 | 100 | Drains continuously while in space at 0.018 points/second (1.08/minute). |
| Fuel | 100 | 100 base; 120 with cell installed | Drains continuously while in space at 0.12 points/second (7.2/minute). |
| Hull | 5 | 5 | Does not regenerate. Cannot be increased by equipment. Each unblocked hit removes 1. |
| Armor | 3 | 3 baseline; 5 maximum with Armor Plating | Does not drain. Equipment can increase maximum armor. Each hit consumes 1 armor before hull. |

Only food and fuel drain passively. Hull and armor are combat durability, not consumable travel supplies. Credits and reputation are progression values, not ship resources. Resource gains come from equipment effects or event choices; reaching a planet does not automatically refill food or fuel. Food is capped at 100. Fuel is capped at 100 without the Auxiliary Fuel Cell and 120 while it is installed. Equipment and choices cannot raise hull above its fixed maximum of 5. Starting current values remain food 100, fuel 100, hull 5, armor 3; capacity bonuses do not refill current supply on installation.

If fuel reaches zero in flight, travel stops immediately and the ship remains stranded at its current route position. Food continues to drain while stranded. The MVP has no refuel service; the player can return to the pre-departure checkpoint or a manual save. If food reaches zero at any point, the player dies. A route that arrives on the same simulation step as fuel exhaustion completes arrival first; food reaching zero always causes death. No grace period. Death opens choices: start a new game, load the latest save, or choose a manual save.

## Galaxy map and travel

- Initial region: 10 systems and 20 provisional planets; 4 Civilization hubs in systems 01, 04, 07 and 09. All 10 systems have Mars-colony ownership as a setting note, not a player faction.
- Planet types: Civilization (hub access), Colony (delivery/arrival), Extraction (resource notes only; gathering deferred).
- Select any planet directly. The map is informational and never enforces a neighbor graph or route requirement. Six abstract player-assigned sigils are saved by system.
- The MAP screen is the official side-map interface: the left sector canvas supports click selection, wheel zoom and drag pan; Reset View restores the full sector; Current System returns focus to the ship's system. The right panel shows selected-system identity, whether it is current, marker controls, planet type/resource notes, and direct travel buttons with ETA, food cost and fuel cost. Buttons are disabled when the ship is not docked or the quote is unaffordable.
- In-system trips take 30 seconds. Inter-system ETA scales linearly with displayed map distance: nearest distinct systems take 2 minutes; farthest pair takes 10 minutes; intermediate pairs interpolate between these values. This keeps nearby interstellar legs within the requested 2–10 minute band.
- Food/fuel travel quote = route ETA × the rates above, plus the worst food/fuel loss among event choices known for that route. Refuse departure if the safe quote exceeds either current supply. A stranded ship cannot resume until an event or equipment effect supplies fuel; no unapproved refuel service is assumed.
- Save one autosave checkpoint immediately before every departure. This checkpoint is overwritten by the next departure. Do not autosave during flight, combat, or an event. Planet arrival itself does not refill ship resources.
- Travel is autonomous. The player can inspect map, orders and status during flight. Cargo/equipment placement is locked while flying.

## Events

- Outside combat, offer approximately one event per 60 seconds of travel. Use a clock that pauses during combat and while the player is deciding. At most one event may be pending.
- Each event has exactly two choices. Early event design focuses on tradeoffs: one resource falls while another rises. Examples of approved outcome patterns are a deep loss for a larger gain (−1 food, +2 fuel) and an even exchange (−1 food, +1 fuel); these describe patterns, not a fixed event roster.
- Outcomes may affect the four ship status values where sensible, but must respect caps and the fixed hull maximum. An event cannot cause a fuel value below zero; zero fuel strands the ship. Food reaching zero causes death.
- No event is triggered or shown during combat. The event clock resumes after combat ends. AI assistant is the default framing voice. Crew framing is deferred until crew design begins.

## Cargo, equipment and placement

- Cargo and equipment share one physical ship grid. No stacking or overlap. Rotate in 90-degree increments; mirroring is not supported. No weight, adjacency bonus or synergy system.
- At a Civilization hub, the player may acquire/add, remove/sell, and rearrange items. On Colony or Extraction planets, the player may rearrange items already aboard, but cannot add or remove items. All item changes are locked in flight and combat.
- Invalid placements are rejected with a readable reason. Core ship cells are fixed and unavailable to items.
- Four rarity tiers, from lowest to highest: Common, Uncommon, Rare, and Exceptional. Rarity indicates relative scarcity and price band; it does not add a hidden stat multiplier.
- Item definitions include id, type, footprint, tags, rarity, origin, effects, placement rules and credit price metadata. Instances hold position, rotation, state and optional durability. Durability is used only when an equipment definition explicitly says so; zero durability disables it until a repair feature is designed.
- Only one ship is in scope: footprint is a centered 7×3 hull plus one 3×1 wing on each side (13×3 bounding grid). Cockpit, engine and energy room are fixed core cells. The supplied ship image is the visual reference; the grid is an abstract gameplay footprint, not pixel tracing. Start with Recycling System and Armor Plating installed. The four basic equipment pieces are available through the Civilization market; additional item lines and ship purchasing/upgrades/unlocks are deferred.
- Initial equipment set: Circular Recycling System (2×1; Common, 200 Credits; each 5 food consumed grants 2 fuel, capped at current maximum, fractional progress retained), Auxiliary Fuel Cell (1×2; Uncommon, 250 Credits; +20 maximum fuel, no instant refill), Armor Plating (2×1; Common, 200 Credits; +2 maximum armor, no instant repair), and ASECA satellite defense (plus-shaped 5 cells; Rare, 300 Credits; once per combat absorbs one incoming projectile; activation on number key 1). Start with Recycling System and Armor Plating installed. All four are purchasable at every Civilization hub. No other item effect is implied. Maximum fuel with the auxiliary cell installed is 120; the base cap is 100.

## Delivery, credits and reputation

- Currency is Credit. Standard single-trip delivery reward: 50–100 Credits, scaled by mission difficulty and cargo rarity. Starting credits: 0. Basic equipment costs 200–300 Credits, aimed at about 3–5 average delivery rewards. Basic equipment is available at Civilization hubs; additional ship purchases, upgrades and unlock systems are deferred.
- Selling cargo at a Civilization hub pays more than delivering that cargo, but costs 1 reputation point per item sold (reputation cannot fall below zero). Selling required mission cargo fails that active delivery and counts toward the associated Civilization's failure total. Do not add a separate sales-ban counter; the five failed deliveries rule below governs access penalties.
- Standard MVP deliveries are single-trip, have no deadline, and fail if required cargo is lost or sold before delivery. Multi-trip delivery is deferred for high-tier/story missions; do not silently treat the current MVP mission as multi-trip.
- Completing a delivery grants 5–15 reputation points, with larger amounts reserved for story missions later. Reputation has seven ranks; cumulative thresholds are 100, 300, 900, 2,700, 8,100, 24,300 and 72,900 points. Rank unlock effects are deferred and must not be invented now.
- Track failed deliveries per Civilization. On the fifth failed delivery associated with a Civilization, that hub requires a 1,000 Credit fine on the next visit. Paying restores access. Refusing permanently blocks that Civilization and its missions for the current save. Failure means required cargo is lost; no deadline failure exists.

## Combat

- Combat is an occasional, secondary encounter. The ship stays centered; enemies enter from the screen edges, move around it and attack with weapons. They do not ram or fly straight at the player ship. Early enemies are deliberately weak; types may vary movement and weapons.
- Combat has a 45-second survival timer and ends when it expires or all enemies are eliminated, whichever happens first. Surviving enemies retreat at timeout. A basic encounter contains at most two weak enemies. The travel route continues during combat. No travel events occur during combat.
- Hull starts at 5 and cannot be raised by equipment. Armor starts at 3 and equipment may increase it. One projectile hit removes 1 armor; overflow removes 1 hull per remaining damage. Hull zero causes death. There is no automatic armor regeneration; add a repair rule only with an approved equipment effect.
- Special equipment is activated on number keys (1, 2, 3, …); assigned keys show on the equipment. ASECA is the initial special equipment. No general twin-stick weapons, ammo, cooldown, or enemy damage rules beyond this baseline are assumed; implement only the smallest combat loop that exercises movement, incoming projectiles, damage, survival and elimination.

## Save/load and death

- One autosave file is a checkpoint written immediately before each departure and retained until the next departure. No timed autosave.
- Player-created manual saves remain available. Save/load during travel, event, and combat is disabled; save only while docked. Store route-independent state and item/reputation/access-failure state.
- On death, show three actions: New Game; Load Latest Save (the pre-departure autosave if present, otherwise newest manual save); Load Save (open manual save selection). Starting a new game does not silently delete existing manual saves.
- Atomic write/version migration are implementation requirements; malformed saves must fail clearly without destroying another save.

## Deferred systems

Extraction gathering, multi-trip/story deliveries, crew, additional ships, new equipment lines, ship purchasing/upgrades/unlocks, repair/refuel services, NPC/story/casino, extra hub services and additional progression unlocks are not MVP. The four basic equipment pieces may be bought/sold at Civilization hubs. Keep data/UI extensible without simulating deferred features.
