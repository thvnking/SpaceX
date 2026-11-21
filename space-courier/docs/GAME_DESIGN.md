# Game Design

## Vision

Space Courier is a 2D space adventure about an independent courier. The central play is choosing destinations, planning supplies, arranging cargo and equipment, making tradeoff choices, delivering cargo, and surviving occasional light combat. Discovery and ship building support the courier loop. Story, named characters and crew are later work; this baseline adds no lore or cast.

## Core loop

```text
Choose a system and destination
  → check ETA and food/fuel quote
  → at a Civilization hub: accept delivery, trade/add/remove items
  → arrange shared cargo/equipment grid
  → save a pre-departure checkpoint and launch
  → autonomous flight; food/fuel drain continuously
  → roughly one two-choice event per minute outside combat
  → optional weak combat; route continues and events pause
  → arrive; rearrange inventory, deliver cargo, plan next trip
```

## Region and travel

The initial region shows 10 systems and 20 provisional planets. The MAP screen is a complete side-map workflow: the sector canvas supports click selection, wheel zoom, drag pan, reset view, jump to the current system, and a right-side system panel. The side panel shows the selected system, current-system state, six persistent sigils, planet types and direct travel quotes/actions. Players can travel directly to any planet; the map does not require neighbor routes. Four Civilization hubs are placed in systems 01, 04, 07 and 09. All 10 systems are Mars colonies as a setting note. The three planet categories are Civilization, Colony and Extraction. Extraction worlds currently display notes only; gathering is deferred. Six abstract sigils can be assigned by the player to systems.

Travel uses distance-dependent ETA: 30 seconds within a system and 2–10 minutes between systems, proportional to displayed map distance. Autonomous travel continuously consumes food and fuel. Fuel zero stops the ship; food zero causes death. Events trade resources through exactly two options and never run during combat. Planets do not automatically replenish supplies.

## Cargo, delivery and hub access

Civilization hubs allow players to buy/sell basic cargo and equipment, add/remove items, and rearrange the ship grid. Other planets allow rearranging items already aboard, not adding or removing them. All changes are locked while flying or in combat. MVP deliveries require one trip, have no deadline, and fail if their cargo is lost or sold before delivery. Multi-trip story/high-tier missions are deferred.

Standard deliveries pay 50–100 Credits and 5–15 reputation points according to difficulty and cargo rarity. Selling cargo at a Civilization hub pays more than delivery but costs 1 reputation per item (minimum 0); selling required mission cargo fails that mission. Basic equipment costs 200–300 Credits. Seven reputation ranks use cumulative thresholds 100, 300, 900, 2,700, 8,100, 24,300, 72,900. Rank unlock effects are deferred. Five failed deliveries linked to one Civilization trigger a 1,000 Credit fine at its hub. Refusal permanently blocks that hub and its missions for the save. Mission cargo loss, not deadlines, causes failure.

## Ship and equipment

Only one ship is in scope. Its abstract layout is a central 7×3 body with 3×1 wings on both sides, based on the supplied reference image. Cockpit, engine and energy room are fixed core cells. Cargo and equipment occupy the same physical grid without overlap or stacking; items rotate by 90 degrees and cannot be mirrored. No weight or adjacency bonus exists. Invalid placements are rejected with a reason.

Four rarity labels are Common, Uncommon, Rare and Exceptional. Equipment and choices are the sources of resource gains. Hull maximum is fixed at 5; armor can be raised by equipment. Start with the Recycling System and Armor Plating installed. All four basic equipment items can be purchased at Civilization hubs for 200–300 Credits, about 3–5 average delivery rewards. Additional ship purchases, ship upgrades and content unlock systems come after the single-ship loop works well.

## Combat

Combat is secondary and occasional. The player ship stays centered; weak early enemies enter from the edges, circle/orbit and attack with projectiles rather than ramming or charging straight at the ship. Combat has a 45-second timer and ends when it expires or all enemies (at most two in a basic encounter) are eliminated; survivors retreat at timeout. Hull/armor use one point per hit: armor absorbs first, then hull. Special equipment uses number keys. The route continues and event cadence pauses during combat.

## Death and saving

One autosave checkpoint is written before each departure. Manual saves are player controlled and can be loaded from the death screen. Death offers New Game, Load Latest Save or Load Save. Food zero is fatal. Starting a new game preserves existing manual saves.

## MVP boundary

Build the one-ship courier loop, map/travel, resources, two-choice events, single-trip deliveries, basic equipment market, light survival combat, manual saves and pre-departure autosave. Defer crew, story, extraction gathering, multi-trip missions, extra ships, ship purchases/upgrades/unlocks and nonessential hub services. The UI specification may describe future spaces for crew, but must label them future-facing and must not imply that crew is implemented or in the MVP.
