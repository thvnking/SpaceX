# Content Schema (design-level)

Schema dưới đây là hợp đồng khái niệm, không phải serialization format đã chốt. Có thể ánh xạ sang Godot Resources/JSON/CSV sau khi chọn implementation. Không điền giá trị gameplay chưa được duyệt.

## Shared conventions
- Stable `id` để save tham chiếu; display text riêng.
- Content definitions tách khỏi runtime instances.
- Arrays dùng cho tags, effects, rules và shape cells.
- Tên enum và định dạng lưu trữ còn mở.

## ItemDefinition

```text
ItemDefinition
  id
  display_name
  type: Cargo | Equipment (extendable)
  shape: occupied cell coordinates
  tags: string[]
  rarity: one of 4 levels (labels TBD)
  origin_culture: optional identifier/text
  effects: EffectDefinition[]
  placement_rules: PlacementRule[]
  price: optional economy data (values TBD)
  durability_policy: none | enabled (details TBD)
  description: optional
```

`type`, rarity, origin, tags luôn là metadata. Effects, state, placement rules có thể rỗng nếu item không có hành vi đặc biệt. Không dùng weight.

## ItemInstance

```text
ItemInstance
  instance_id
  definition_id
  durability_current: optional
  state: optional key/value or typed state (format TBD)
```

Durability chỉ có trên một số equipment; zero disables until repair. Cargo loss chỉ xảy ra khi mission đặc biệt định nghĩa điều đó.

## Shape

Tập hợp tọa độ cell tương đối. Ví dụ hình chữ nhật lưu toàn bộ cell; dấu cộng và 3 cell chéo được thể hiện bằng tọa độ. Rotation theo bội số 90°. Cell origin/rotation normalization cần được chốt implementation. Irregular cargo chỉ dành cho hàng đặc biệt; equipment có thể dùng shape đặc biệt.

## PlacementRule

```text
PlacementRule
  rule_type
  parameters
```

Ví dụ conceptual rule types: `avoid_high_heat`, `avoid_low_heat`, adjacency/contact rule theo item/ship tags, forbidden zones. Đây là khả năng kiến trúc; chỉ các rule đã được ghi trong item example mới là quyết định content. Validator phải từ chối drop và trả lý do dễ hiểu.

## EffectDefinition

```text
EffectDefinition
  effect_type
  parameters
  trigger: optional condition/event
```

Dùng cho resource conversion, defense, combat hoặc behavior; event timing, stacking, clamping và ordering còn TBD.

## ShipDefinition

```text
ShipDefinition
  id
  display_name
  layout_cells
  core_components: cockpit, engine, energy_room (fixed)
  placement_zones / cell tags (if needed)
  visual_reference: optional asset reference
  unlock/economy data: TBD
```

Layout cố định theo ship; hình ảnh gameplay và inventory cần tương ứng. Ship mới mở ra layout vật lý khác.

## PlanetDefinition

```text
PlanetDefinition
  id
  display_name
  civilization_present: bool
  world_type: Civilization | Colony | Extraction
  system_id
  owner_name
  resource_notes: string[]
  resource_refill_policy: TBD
  hub_services: optional list (MVP delivery + buy/sell only)
```

The demo implementation also stores `world_type`, `system_id`, `owner_name`, and `resource_notes` on each planet. Civilization status is reflected by the existing `civilization_present` field. A separate galaxy-system record should eventually own display name, 2D map position, and planet references; these are currently held in `GalaxyMapView.SYSTEMS` and mirrored in `DemoContent`. Keep authored map content data-driven when replacing the demo.

The current demo has 10 Mars-colony systems, 20 planets, and four civilization points in systems 01, 04, 07, and 09. Each planet is assigned one of the three world types. Extraction resource notes describe intended resources; they do not yet represent a collectable inventory or resource quantity.

## TravelDefinition

```text
TravelDefinition
  id
  origin_planet_id
  destination_planet_id
  segment_durations_seconds[]
  resource_drain_per_second: resource -> rate
  segment_events: optional segment -> event
  segment_combats: optional segment -> combat
```

Players may choose any destination planet directly; map stars do not enforce a neighbor graph. The demo generates a direct travel definition for each ordered pair of different planets. The current map position formula and resource rates are temporary demonstration values, not final design constraints. The runtime estimates total food and fuel costs, includes the worst negative event-choice delta, and refuses departure when either resource is short.

Map markers are player-defined annotations attached to system ids. The current demo uses six abstract geometric neon sigils in six colors; no sigil has a fixed meaning. Marker values are stored with save data.

## MissionDefinition

```text
MissionDefinition
  id
  display_name
  delivery_target_planet_id
  required_cargo: item/quantity references
  trip_count_or_completion_conditions: TBD
  reward/reputation: TBD
```

Mission target được đánh dấu trên map; player tự chọn hành tinh kế tiếp. Một delivery có thể cần nhiều chuyến.

## EventDefinition

```text
EventDefinition
  id
  prompt_source: assistant | crew (content framing)
  question
  choices: exactly 2
  conditions: TBD
  effects: TBD
```

Trigger theo travel segment. Frequency, event pool, persistence và outcomes chưa chốt.

## Combat / equipment content
Combat encounter, enemy, weapon, armor, special activation và cooldown cần schema chi tiết hơn khi rules được quyết định. Không tạo số liệu mặc định.
