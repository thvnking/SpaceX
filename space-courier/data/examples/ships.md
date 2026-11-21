# Official initial ship layout

There is one ship in the MVP. Its visual reference is the user-provided `ship.jpg` (the top-side concept drawing is the closest grid reference). Do not trace every pixel as a cell; map the shape to a readable physical grid.

## Footprint

- Central body: 7 columns × 3 rows.
- Left wing: 3 columns × 1 row, centered on the middle row and attached to the body's left edge.
- Right wing: 3 columns × 1 row, centered on the middle row and attached to the body's right edge.
- Total bounding rectangle: 13 × 3; non-hull cells are invalid placement cells.
- Cockpit, engine and energy room are fixed core components, not movable inventory.
- Cargo and equipment share the usable cells. No item overlaps, stacking, mirroring, weight or adjacency bonuses; rotate by 90 degrees.

The precise fixed cell coordinates are an implementation detail of the approved silhouette and must be authored once, checked against the image, and used consistently for inventory and rendering. No additional ship, upgrade or unlock is in MVP.
