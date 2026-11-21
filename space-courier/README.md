# Space Courier

Tài liệu thiết kế và project Godot cho game phiêu lưu không gian thiên về vận chuyển, quản lý tài nguyên, build tàu và combat nhẹ. Baseline gameplay chính thức được ghi trong `docs/GAME_DESIGN.md` và `docs/SYSTEMS.md`.

## Đọc theo thứ tự

1. `CODEX_CONTEXT.md` — quy tắc cộng tác và thứ tự nguồn sự thật.
2. `docs/GAME_DESIGN.md` — trải nghiệm, core loop và ranh giới MVP.
3. `docs/SYSTEMS.md` — giá trị và luật gameplay đã chốt.
4. `docs/CONTENT_SCHEMA.md` — dữ liệu gameplay.
5. `docs/IMPLEMENTATION.md` — code hiện có và khoảng cách với baseline.
6. `docs/ROADMAP.md` — thứ tự công việc và phần được hoãn.
7. `docs/SPACE_COURIER_UI_UX_SPEC_FOR_CODEX.md` — hướng giao diện; các màn hình về sau phải tôn trọng luật hệ thống.
8. `docs/BAO_CAO_TIEN_DO_SPACE_COURIER.docx` — báo cáo trạng thái đọc nhanh.
9. `data/examples/` — ví dụ tàu và equipment.

## MVP

Một tàu; side map 10 hệ với zoom/pan/chọn hệ, planet panel và route quote trực tiếp; bay theo ETA 30 giây nội hệ hoặc 2–10 phút giữa hệ; food/fuel giảm liên tục; event hai lựa chọn khoảng mỗi phút ngoài combat; giao hàng một chuyến; equipment/grid và market equipment cơ bản tại Civilization hub; combat nhẹ; manual saves và một checkpoint autosave trước mỗi lần bay. Crew, khai thác, nhiệm vụ nhiều chuyến, tàu bổ sung, story, ship upgrades và hệ thống unlock để sau.

## Trạng thái

Code hiện tại đã triển khai baseline MVP chính thức; `docs/IMPLEMENTATION.md` chỉ rõ phần đã hoàn thành và phần deferred. Không coi dữ liệu tên hệ/hành tinh demo là lore canon khi khác với `docs/SYSTEMS.md`.
