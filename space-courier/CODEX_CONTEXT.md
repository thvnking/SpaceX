# CODEX_CONTEXT

## Mục đích
Đây là tài liệu ràng buộc cho Codex khi làm việc trên project Godot Space Courier. Project đã có nền tảng runtime và dữ liệu demo; các giá trị demo không phải quyết định sản xuất cuối cùng.

## Source of truth
Đọc theo thứ tự: `README.md` → `docs/GAME_DESIGN.md` → `docs/SYSTEMS.md` → `docs/CONTENT_SCHEMA.md` → `docs/ROADMAP.md` → ví dụ data. Khi tài liệu khác nhau, ưu tiên quyết định người dùng nêu trực tiếp và đánh dấu xung đột để hỏi lại; không tự chọn một thông số chưa chốt.

## Nguyên tắc thiết kế đã chốt
- Thể loại/định vị: phiêu lưu vũ trụ, khám phá bí ẩn, build/nâng cấp; gameplay nền là vận chuyển và quản lý tàu. Management game có combat.
- Combat là phụ, không chiếm tỷ lệ cố định trong mọi chuyến. Trong combat route vẫn tiếp tục; kẻ địch hiện hữu thời gian hữu hạn rồi rút.
- Bản đồ khu vực thiên hà ban đầu có 10 hệ sao. Chọn một ngôi sao để xem các hành tinh; người chơi có thể bay thẳng đến bất kỳ hành tinh nào nếu đủ food/fuel, không bị giới hạn bởi topology tuyến.
- Cả 10 hệ demo là thuộc địa Sao Hỏa (thông tin bối cảnh, không phải phe người chơi). Hành tinh có ba loại: Civilization, Colony, Extraction. Bốn điểm Civilization nằm ở hệ 01, 04, 07, 09.
- Sáu sigil hình học neon trừu tượng cho phép người chơi tự gán ý nghĩa; sigil lưu theo hệ sao.
- Nhiệm vụ đánh dấu hành tinh giao hàng nhưng không ép route. Tàu tự bay; trong lúc bay có thể xem thông tin, nhiệm vụ và map; inventory bị khóa khi bay.
- Resource giảm liên tục. Ghé bất kỳ planet sẽ hồi resource. Nếu food về 0 ngoài chuyến, tàu dừng; sau đó chết. Chết thì trở lại save trước.
- Travel chia segment; segment kích hoạt event. Event là câu hỏi của AI assistant hoặc crew, có đúng hai lựa chọn. NPC/crew là hướng mở rộng về sau.
- Civilization planet mở hub; Colony planet phục vụ nhận/giao hàng; Extraction planet ghi tài nguyên cho nhiệm vụ/nâng cấp. Bản demo mới hiển thị resource notes, chưa có vòng lặp thu thập.
- Autosave mỗi 5 phút. Phải có save/load.
- Cargo và equipment dùng chung một grid theo layout tàu cố định. Layout phản ánh hình dáng tàu; có cockpit, engine, energy room cố định. Không stacking/overlap; xoay 90 độ; không mirror trừ khi được quyết định sau. Rearrange bất cứ lúc nào trừ khi đang bay.
- Invalid placement: không thả item và hiển thị lý do.
- Mô hình item data-driven: `ItemDefinition` + `ItemInstance`, `InventoryValidator`, mảng `PlacementRule` có thể mở rộng.
- Mọi item có tags, type, rarity, origin/culture, effects/state nếu có, placement rules. Có 4 rarity level; trực quan và liên quan giá. Chưa chốt tên level.
- Durability chỉ áp dụng cho một số equipment; có thể dùng cho equipment kích hoạt bằng nút. Durability 0: thiết bị disable đến khi repair. Cargo không damage mặc định; có thể mất trong mission đặc biệt.
- Weapon đặt ở bất kỳ vị trí hợp lệ; aim độc lập; vị trí weapon quyết định projectile origin. Armor phòng thủ tự động: defense pool trước hull HP; hull 0 = chết. Một số equipment đặc biệt cần nút.
- Ship progression là tàu lớn/tốt hơn với physical layout mới, không chỉ slot tăng. Inventory không dùng weight. Item thường hình chữ nhật; irregular cargo chỉ dành cho cargo đặc biệt. Có rotate 90°.
- Placement rule architecture extensible; flight architecture mục tiêu hỗ trợ D, MVP triển khai A+B theo thảo luận gốc; ý nghĩa nhãn A/B/D phải được làm rõ trước khi chốt thiết kế kỹ thuật cụ thể.

## Quyền tạo dữ liệu demo
- Người dùng đã cho phép tạo số liệu/content cơ bản để chạy demo; giữ các giá trị này trong `scripts/data/demo_content.gd` và xem chúng là tạm thời, không phải design lock cho bản game cuối.
- Khi thay demo bằng dữ liệu chính thức, cập nhật demo hoặc tạo Resource content riêng; không nâng số liệu demo thành quyết định thiết kế nếu người dùng chưa chốt.

## Không được tự ý thêm
Không tự tạo lore, nhân vật/NPC, quest hoặc content sản xuất chưa được duyệt. Số liệu và content tạm để chạy demo được phép trong `scripts/data/demo_content.gd` và `scripts/galaxy_map.gd`, nhưng không biến chúng thành design lock. Tên hệ sao, hành tinh, vị trí bản đồ, công thức ETA, drain/refill và resource notes hiện tại là demo. Không biến combat thành bắt buộc hay đặt topology tuyến làm giới hạn di chuyển. Không thêm weight, stacking, synergy hoặc adjacency bonus: các ý này đã bị loại/không chọn trong quyết định sau cùng.

## Triển khai Godot sau này
Tách dữ liệu content khỏi logic; ưu tiên resource/data definitions và validator độc lập với UI. Giữ placement rules mở rộng được. UI phải giải thích invalid placement. Save state cần đủ khôi phục trạng thái tương ứng với semantics được chốt. Không triển khai tính năng ngoài MVP nếu chưa có quyết định.

## Cần hỏi trước khi hoàn thiện thiết kế
Xem `OPEN DECISIONS / TODO` tại `docs/ROADMAP.md` và các mục tương ứng trong `docs/SYSTEMS.md`. Đề xuất có thể được nêu nhưng phải ghi là đề xuất, không phải quyết định.
