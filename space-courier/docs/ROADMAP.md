# Roadmap & Open Decisions

## Phạm vi và giai đoạn

### Phase 0 — Design lock trước khi chốt production content
- Giải quyết các open decisions ưu tiên cao dưới đây.
- Chốt nghĩa A/B/D cho flight architecture và phạm vi MVP.
- Chọn Godot version, resolution/input/platform và data serialization; chưa có quyết định trong design chat.

### Phase 1 — MVP foundations
- Map khu vực thiên hà với 10 hệ sao; chọn một sao để xem hành tinh, rồi bay thẳng tới bất kỳ hành tinh nào nếu đủ food/fuel.
- Phân loại hành tinh thành Civilization, Colony và Extraction; đặt bốn điểm nền văn minh ở các hệ 01, 04, 07 và 09.
- Zoom vào hệ sao và gắn sáu sigil trừu tượng do người chơi tự gán nghĩa.
- Auto-flight, ETA/resource preflight và arrival.
- Resource drain/refill/death, segment event hai lựa chọn.
- Ship layout fixed + shared cargo/equipment grid + rotation + validation feedback.
- Delivery và hub tối giản; một currency, buy/sell inventory.
- Combat survival tối thiểu theo ba win conditions; route tiếp tục.
- Save/load, autosave 5 phút, death restore.

### Phase 2 — Progression
- Reputation XP unlock model; economy balancing.
- Repair/refuel, shop content, thêm ship layouts/upgrades.
- Mở rộng placement/equipment effects và encounter content.

### Phase 3 — Narrative & world
- NPC/crew, quests/story, events có nhân vật, exploration, các hub services còn lại.
- Nội dung/cốt truyện chưa được tạo trong tài liệu này.

## OPEN DECISIONS / TODO

### Gameplay core
- Resource types chính thức ngoài food/fuel; starting values, caps, drain rates, refill amounts.
- Khi “resource hết”, tàu dừng ngay với resource nào; xác nhận food=0 là điều kiện death; grace period hay không.
- Ghé planet hồi loại resource nào, lượng nào, có điều kiện/chi phí không.
- Số liệu cuối cho tọa độ/scale bản đồ, thời gian bay, drain và ETA. Bản demo hiện dùng công thức khoảng cách tạm; không có topology tuyến bắt buộc.
- Cách thu thập, số lượng, lưu trữ và tiêu thụ tài nguyên tại Extraction worlds.
- Tên canon cho các hệ sao/hành tinh và danh sách tài nguyên khai thác; tên hiện tại chỉ là demo.
- Thời lượng chuyến 2–5 phút là mục tiêu ban đầu hay chỉ mô tả tham khảo.
- Event frequency/selection, có thể nhiều event mỗi segment không, hậu quả và cách xử lý khi đang combat.

### Combat
- Combat spawn/trigger rules, tần suất, encounter composition và enemy behavior.
- Survival timer, weapon stats/input, projectile behavior, damage model và combat end ordering.
- Các loại armor/shield chính xác: physical vs magnetic/energy; pool, hồi, “mỗi chuyến” nghĩa gì.
- Special equipment activation, cooldown, charges/durability, và tiêu chí giải pháp special equipment được tính là thắng.

### Economy/progression/delivery
- Currency name, buy/sell prices, delivery rewards, ban thresholds/identity duration.
- Reputation XP earn/loss, thresholds và unlock set.
- Quantity/multi-trip mission semantics: cargo giữ lại giữa chuyến, partial delivery, deadline/failure.
- Shop stock, repair/refuel cost và hub interaction flow.

### Inventory/items/ships
- Bốn rarity labels và cách rarity ảnh hưởng giá cụ thể.
- Shape coordinate convention, mirroring (chưa chốt), cell tags và rule vocabulary.
- InventoryValidator behavior cho invalid rotation/edge/contact/heat rules.
- Item prices, durability maximum/repair semantics, state/effect ordering.
- Exact starting ship and ship layouts, core room dimensions, usable cells, upgrade availability.
- “Architecture D, MVP A+B” cần định nghĩa theo lựa chọn flight ở hội thoại trước; không suy diễn nhãn.

### Save/implementation
- Save slots, manual save UX, autosave retention/rotation, atomicity và death restore selection.
- Autosave trong flight/combat/event: có lưu runtime state hay chỉ safe checkpoint.
- Godot version, target platform, viewport/resolution, input mapping, asset pipeline/ComfyUI conventions.
- Resource format (Godot Resource vs JSON etc), localization and text pipeline.

## Change control
Khi quyết định được đưa ra, cập nhật tài liệu liên quan và xóa mục đó khỏi Open Decisions. Không biến phương án đề xuất thành quyết định nếu người dùng chưa xác nhận.
