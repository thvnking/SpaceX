# Implementation status

The Godot project now has a placeholder-art interface and data-driven runtime foundations. A small temporary scenario in `scripts/data/demo_content.gd` supplies basic demo values; these are not final design decisions and can be replaced by Resources under `data/`.

## Implemented foundations

- Ship and item definitions, shared inventory placement validation, cell tags, configurable placement rules, 90-degree rotation, and a grid view with invalid-placement feedback.
- A content catalog for item, ship, planet, travel, event, combat, and mission resources.
- A functional sector map with 10 stars and 20 planets. Selecting a star lists its planets; zooming in shows a schematic system view, and six player-defined neon sigils can be saved on stars.
- Direct travel is available between every ordered pair of the 20 demo planets (380 journeys). The map displays travel time and food/fuel estimates; departure is blocked when either resource is insufficient. Event costs use the worst negative choice for preflight. Resource drain, arrival refills, and food-zero death handling run through the travel/session systems.
- A combat encounter model for the three documented resolution conditions. Encounter triggers, weapons, enemy behavior, and damage tuning still require design data.
- Manual save/load, five-minute autosave, saved travel/event state, and previous-save restoration on death.
- Layouts for ship management, map, orders, events, and the MVP hub services.
- Demo delivery and market flows using a single currency, plus a small route event and timed combat encounter.
- Main menu, continue/new/load flows, settings for audio and display, three manual save slots plus autosave, save overwrite/delete confirmations, credits, and an Escape pause menu.

## Temporary demo profile

These values exist only to run the demo and are expected to change:

| Area | Demo data |
|---|---|
| Ship | 5×4 cells; cockpit at (0,1), engine at (4,1), energy room at (3,1); one high-heat cell at (3,3). |
| Start | Launch Port; 40 food, 40 fuel, 20 hull HP, 30 credits. |
| Galaxy map | 10 provisional system names, 20 planets (two per system), all marked as Mars colonies; civilization worlds are in systems 01, 04, 07 and 09. |
| Travel | Every planet can be selected as a direct destination. Demo ETA is `max(8, map distance × 70)` seconds between systems and 8 seconds within a system; the formula is temporary. |
| Travel drain/refill | 0.1 food and 0.2 fuel per second. Demo refill values vary by planet; all values are temporary. |
| Map markers | Six abstract geometric neon sigils in cyan, pink, yellow, purple, green and orange. Players assign their own meanings; marker values are saved. |
| Cargo | Survey Parcel, one cell; buy for 18 credits, sell for 15 credits, selling costs 1 reputation XP. |
| Mission | Deliver one Survey Parcel to Harbor Station; reward 12 credits and 1 reputation XP. |
| Event | Hold course costs 1 food and 1 fuel; recover the pod costs 2 food and grants 3 fuel. |
| Combat | One threat on the Launch Port to Waystation route; attack lasts 4 seconds; the special-equipment resolution is enabled. |
| Equipment | Recycling Unit occupies two horizontal cells, costs 24 credits to buy, sells for 12, and avoids the high-heat cell. |

## Still needed before a complete playable MVP

## Demo star systems

All names and resource notes below are provisional demo content. The four civilization points are in systems 01, 04, 07 and 09; other planets are colonies or extraction sites.

| System | Demo planets |
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

The extraction resource names currently appear as map information only; collection into mission or upgrade inventory remains to be implemented. The outstanding design decisions in `ROADMAP.md` remain open for the final game. All demo values and names are intentionally temporary.
