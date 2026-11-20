# Item Examples

Các ví dụ dưới đây phản ánh item đã nêu trong design chat. Giá trị/rule không được cung cấp thì để TBD; không suy diễn thêm.

## Automated Strategic Equipment Control Axis (ASECA)

- Type: Equipment
- Shape: dấu cộng (`+`), cell coordinates cần chốt.
- Placement: không có ràng buộc đặc biệt.
- Behavior: bên ngoài tàu xuất hiện hai vệ tinh xoay quanh liên tục, hoạt động như khiên (so sánh hình ảnh: funnel trong Gundam).
- Ammo: none.
- Durability: none.
- Rarity, origin/culture, price, exact defense behavior: TBD.

## Circular Recycling System

- Type: Equipment
- Shape: 2×1 rectangle.
- Placement: tránh vùng/nhiệt cao.
- Effect: mỗi khi mất/tiêu thụ 5 điểm food, nhận +2 điểm fuel.
- Rarity, origin, price, durability, rounding/trigger semantics: TBD.

## Astrasdis Family Decorative Interior

- Type/tag classification: metadata chưa phân giải hoàn toàn. Đã nêu tags `Cargo`, `Treasure`, `Eg13-5` (origin), cùng “avoid high heat” và “avoid low heat”.
- Shape: 3 cell theo đường chéo.
- Placement: tránh nhiệt cao và tránh nhiệt thấp.
- Special behavior: none.
- Tên hiển thị chính thức, rarity, price, mission role và tag-vs-rule normalization: TBD.

## Authoring notes
Mọi item cần type, tags, rarity (một trong bốn mức), origin/culture, effects/state nếu có, và placement rules. `Cargo` và `Equipment` dùng chung grid. Cargo cơ bản không có gameplay effect; cargo không có weight. Item rectangular là dạng thường; irregular cargo dành cho hàng đặc biệt.
