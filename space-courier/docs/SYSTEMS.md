# Systems Specification

## Travel & map
- Bản đồ demo hiển thị một khu vực thiên hà gồm 10 hệ sao, mỗi hệ có hai hành tinh. Chọn ngôi sao để xem hành tinh và thông tin cơ bản; zoom sâu cho thấy sơ đồ quỹ đạo minh họa.
- Người chơi có thể chọn thẳng bất kỳ hành tinh nào trong 10 hệ. Không có tuyến láng giềng bắt buộc hay route topology giới hạn đích đến.
- Trước khởi hành, runtime tính ETA và food/fuel cần thiết. Chuyến bị chặn nếu thiếu một trong hai loại tài nguyên. Giá trị hiện tại là demo: thời gian bằng `max(8, khoảng cách tọa độ × 70)` giây; hành tinh cùng hệ dùng 8 giây; drain là 0.1 food/s và 0.2 fuel/s.
- Travel definitions mẫu được sinh cho mọi cặp hành tinh có hướng (20 × 19 = 380 chuyến). Các giá trị khoảng cách, drain, refill và tên hành tinh chưa phải số liệu cân bằng cuối.
- Nếu một route có event, bảng chi phí dự trù hậu quả âm lớn nhất trong các lựa chọn. Chuyến có thể khởi hành khi vừa đủ tài nguyên; nếu food chạm 0 đúng lúc đến nơi, tàu vẫn cập bến.
- Chuyến bay có thể chia travel segments. Resource drain liên tục; event trigger theo segment. Có thể xem map và thông tin khi bay; rearrangement inventory bị khóa.
- Ghé hành tinh áp dụng lượng refill của `PlanetDefinition`. Lượng refill hiện tại đều là dữ liệu demo.
- Sáu sigil hình học neon trừu tượng dùng để đánh dấu hệ sao. Người chơi tự gán ý nghĩa; marker lưu theo system id trong save.

### Hệ sao và loại hành tinh
- Cả 10 hệ demo đều mang thông tin `owner_name = Mars`; đây là quan hệ bối cảnh, không phải phe người chơi.
- Hành tinh có một `world_type`: Civilization, Colony hoặc Extraction. Bốn điểm nền văn minh đặt ở hệ 01, 04, 07 và 09.
- Civilization là điểm tương tác chuyên sâu; Colony là điểm nhận/giao hàng; Extraction ghi các tài nguyên có thể dùng cho nhiệm vụ/nâng cấp.
- Bản demo hiện chỉ hiển thị các ghi chú tài nguyên ở Extraction. Cơ chế thu thập và lưu kho tài nguyên đó chưa được triển khai.
- Tên 10 hệ và hành tinh hiện là nội dung demo tạm. Vị trí hiển thị cũng là tọa độ khu vực demo, không phải bản đồ thiên hà canon.

## Resource & survival
- Resource giảm liên tục trong flight.
- Food = 0 gây tàu dừng và death. Death returns to previous save.
- Ví dụ Circular Recycling System chuyển mỗi 5 food mất/tiêu thụ thành +2 fuel.
- Chưa chốt các resource chính thức, cap, drain rate, thứ tự ngừng tàu, hồi phục, xử lý âm/đồng thời và hiệu ứng equipment lên chúng.

## Events
- Trigger theo travel segment.
- Màn hình decision có hai lựa chọn, câu hỏi do AI assistant hoặc crew đưa ra.
- Outcomes phải được content-driven; event frequency, outcomes, conditions, repeatability và vai trò AI thực tế chưa chốt. NPC/crew về sau.

## Delivery, economy, reputation
- Mission có delivery target; một mission có thể yêu cầu nhiều chuyến.
- Giao hàng bằng cách chọn/đưa đúng cargo theo hình dạng và tên vào nơi nhận.
- Selling cargo trả tiền cao hơn delivery nhưng giảm reputation; bán quá nhiều có thể bị ban ở nơi cung cấp.
- Một currency duy nhất. Reputation XP mở NPC, quests, features.
- Hub MVP: delivery và buy/sell inventory. Tương lai: repair/refuel/quests/NPC/events/upgrades/casino/exploration.
- Không có economy amounts hoặc thresholds được chốt.

## Combat
- Combat module phụ; không áp quota/ratio encounters.
- Route tiếp tục trong combat; enemy tồn tại thời gian hữu hạn rồi rút.
- Resolution: eliminate all enemies; survive until attack timer ends; activate special equipment.
- Win returns to route.
- Weapon placement tại cell hợp lệ bất kỳ; aim độc lập, projectile xuất phát từ vị trí weapon. Equipment đặc biệt có thể cần nút.
- Armor defense pool trước hull HP; hull 0 = death.
- Chưa chốt input map, weapon cadence/projectiles, enemy behavior, spawn rules, timer, shield variants, cooldowns, repair/damage details.

## Inventory grid & validation
- Cargo/equipment chung grid tàu.
- Grid/layout cố định theo ship và phải tương ứng trực quan với ship.
- Cockpit, engine, energy room là core fixed components, không phải item tự do.
- Không overlap/stack. Rotate 90°. No mirroring decision not established as final; default only 90° rotation was specified.
- Placement/rearrangement anytime trừ lúc flight.
- Invalid drop: reject + show reason.
- Item thường rectangular; irregular shapes chỉ cho special cargo. No weight.
- No synergy. Placement chỉ có thể tối ưu buff; adjacency bonus không được xác nhận trong quyết định cuối.
- Placement constraints mở rộng được; engine validation độc lập với UI. D architecture, MVP A+B được giữ như ghi nhận, nhưng nhãn A/B/D chưa có định nghĩa đủ trong dữ liệu hiện có.

### Data model
- `ItemDefinition`: id, display name, type, shape cells, tags, rarity, origin/culture, effects, placement rules, price metadata, durability policy.
- `ItemInstance`: definition reference + per-instance state như durability/current condition nếu áp dụng.
- `InventoryValidator`: kiểm tra nằm trong usable cells, không trùng/overlap, rotation và toàn bộ placement rules; trả valid/invalid + reason.
- `PlacementRule`: data rule có type/parameters, tổ chức thành array; thêm rule không đòi đổi cấu trúc item.
- Effects/state/rule vocabulary cần được định nghĩa cụ thể trước implementation.

## Durability, damage, armor
- Chỉ một số equipment có durability; equipment kích hoạt bằng nút là một nhóm có durability theo quyết định đã ghi. Khi durability 0, disabled đến repair.
- Cargo không damage mặc định; equipment không damage mặc định. Mission đặc biệt có thể gây cargo loss.
- Shield/armor: nhiều loại đã được nêu ở mức khái niệm: physical armor có pool lớn hơn và vỡ khi cạn; energy/magnetic armor có pool nhỏ hơn, không vỡ và hồi mỗi chuyến. Chưa chốt variant chính thức hoặc “trip” nghĩa là gì.

## Ship progression
Ship mới/tốt hơn có layout mới, physical structure khác. Core room cố định. Exact ship layouts, stats, unlocks chưa chốt.

## Save/load
Autosave mỗi 5 phút; manual save/load cần có; death restore previous save. Chưa chốt save slots, autosave retention, trigger ordering, save dữ liệu runtime trong event/combat/flight, migration/versioning, và xử lý khi chết trùng autosave.
