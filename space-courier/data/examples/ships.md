# Ship Examples & Layout Rules

Đây là nguyên tắc layout đã chốt, không phải danh sách tàu hay layout hoàn chỉnh.

## Layout rules
- Mỗi ship có layout grid cố định riêng; khoang inventory và hình tàu trong gameplay nên cùng thể hiện một con tàu.
- Tàu có hình dạng không đều; không nhất thiết là rectangle đầy đủ. Layout có vùng cố định và core components.
- Luôn có cockpit, engine và energy room / power core. Chúng là thành phần tàu cố định, không phải item người chơi tự di chuyển.
- Cargo và equipment chiếm chung usable grid.
- Không đặt item chồng nhau. Rotation 90° được hỗ trợ. Mirroring chưa được chốt trong dữ liệu hiện có.
- Invalid placement bị từ chối và nêu lý do.
- Có thể rearrange ở mọi lúc trừ khi đang bay.
- Ship progression là đổi sang tàu lớn/tốt hơn với physical layout khác, mở ra cách build mới; không chỉ tăng slot.

## ShipDefinition template

```yaml
id: TBD
name: TBD
layout_cells: TBD
core_components:
  cockpit: fixed
  engine: fixed
  energy_room: fixed
usable_cells: TBD
visual_reference: TBD
```

Không điền dimensions, cell count, stats, price, unlock hay hình dáng khi chưa có quyết định.

## Example roster
Chưa có ship cụ thể nào được chốt trong design chat. Tạo roster và exact layouts thuộc Open Decisions.
