# Space Courier

Bộ đặc tả thiết kế và nền tảng triển khai game indie Space Courier bằng Godot. Tài liệu này là source of truth cho các quyết định đã chốt; các thông số chưa chốt được liệt kê riêng trong `docs/ROADMAP.md` và `docs/SYSTEMS.md`.

## Tóm tắt

Space Courier là game phiêu lưu không gian thiên về quản lý, khám phá và build tàu, có combat như một phần phụ. Người chơi vận chuyển hàng giữa các hành tinh, tự chọn điểm đến trực tiếp trong khu vực thiên hà, sắp xếp cargo và equipment vào layout tàu, quản lý tài nguyên, xử lý sự kiện và sống sót. Bản đồ demo hiện có 10 hệ sao và 20 hành tinh; cả 10 hệ được ghi nhận là thuộc địa Sao Hỏa.

## Cấu trúc

- `CODEX_CONTEXT.md` — hướng dẫn cho Codex, ràng buộc và source of truth.
- `docs/GAME_DESIGN.md` — fantasy, loop, bản đồ 10 hệ sao, loại hành tinh, delivery, hub, combat.
- `docs/SYSTEMS.md` — hệ thống gameplay, travel trực tiếp và quy tắc đã chốt.
- `docs/CONTENT_SCHEMA.md` — mô hình dữ liệu định hướng data-driven, gồm hệ sao và loại hành tinh.
- `docs/ROADMAP.md` — phạm vi MVP, thứ tự triển khai, quyết định còn mở.
- `data/examples/items.md` — item mẫu đã được xác nhận.
- `data/examples/ships.md` — nguyên tắc layout và mẫu mô tả tàu.
- `data/README.md` — vị trí và cách nạp runtime content dạng Godot Resource.
- `docs/IMPLEMENTATION.md` — phần nền tảng đã code và dữ liệu còn thiếu để có MVP chơi trọn vẹn.

## MVP

Ưu tiên bản chơi được với map/travel theo từng planet, resource drain và hồi phục khi ghé planet, event hai lựa chọn, delivery, inventory grid chung, placement validation, combat survival cơ bản, save/load/autosave và death quay về save trước. NPC/crew và nội dung cốt truyện được để sau. Hub MVP chỉ có delivery và buy/sell inventory.

## Cách dùng

Đưa cả thư mục này vào project `SpaceX`. Trước khi triển khai, Codex đọc `CODEX_CONTEXT.md`, rồi các tài liệu trong `docs/`. Không suy diễn các mục `OPEN DECISIONS / TODO` thành quyết định thiết kế.

## Trạng thái triển khai

Đã có giao diện placeholder và bộ dữ liệu demo tạm để chạy luồng MVP. Các giá trị demo không phải quyết định cuối; xem `docs/IMPLEMENTATION.md` và `data/README.md`.
