# Game Design

## 1. Tầm nhìn
Space Courier là game phiêu lưu vũ trụ 2D về một người vận chuyển độc lập. Người chơi khám phá, làm nhiệm vụ, sắp xếp hàng hóa và thiết bị trong tàu, quản lý tài nguyên và đôi khi chiến đấu. Story, nhiệm vụ chính/phụ, NPC chính/phụ là mục tiêu dài hạn nhưng sẽ bàn sau khi nền hệ thống hoàn chỉnh; không có lore hoặc nhân vật nào được chốt trong bộ tài liệu này.

Cảm giác điều khiển combat được mô tả là twin-stick top-down, di chuyển một hướng và ngắm/bắn độc lập; hướng cụ thể là nặng và có cảm giác vật lý. Flight thông thường là tàu tự bay, management là trọng tâm.

## 2. Core loop

```text
Map / Hệ sao
  → chọn một ngôi sao trong 10 hệ
  → xem các hành tinh và thông tin cơ bản
  → chọn điểm đến trực tiếp nếu đủ food/fuel
  → nhận/mang cargo, mua equipment, sắp xếp grid
  → tàu tự bay theo travel segments
  → resource drain + event decision; combat có thể xảy ra
  → đến planet
      civilization → hub
      empty → arrival / delivery confirmation
  → delivery hoặc giao dịch
  → chọn bất kỳ hành tinh nào làm điểm đến tiếp theo
```

Đơn hàng chỉ rõ planet giao; người chơi tự chọn điểm đến trên bản đồ và có thể bay thẳng tới bất kỳ hệ sao nào. Food và fuel sẵn có quyết định chuyến đi có thể khởi hành hay không. Một nhiệm vụ có thể cần nhiều chuyến. Thời lượng chuyến giao được nêu ban đầu khoảng 2–5 phút nhưng cần cân chỉnh theo segment và khoảng cách thực tế.

## 3. Map và travel
Map là một khu vực của thiên hà với 10 ngôi sao. Chọn một ngôi sao sẽ mở danh sách các hành tinh trong hệ đó; zoom sâu hiển thị sơ đồ quỹ đạo minh họa. Người chơi có thể chọn trực tiếp bất kỳ hành tinh nào trong 10 hệ, không có topology tuyến bắt buộc. Khoảng cách giữa các sao được dùng để ước tính thời gian và chi phí food/fuel; chuyến đi chỉ khởi hành khi đủ cả hai tài nguyên. Trong lúc bay, người chơi có thể xem thông tin, nhiệm vụ và map; inventory không thể sắp xếp lại khi đang bay. Resource tiêu hao liên tục; event được kích hoạt theo từng travel segment.

Cả 10 hệ hiện được ghi nhận là thuộc địa của Sao Hỏa; đây là thông tin bối cảnh, không phải lựa chọn phe của người chơi. Các phe khác có thể được đưa vào thế giới sau này. Mỗi hành tinh thuộc một trong ba loại:

- **Điểm nền văn minh:** nơi có các tương tác chuyên sâu như mua bán, nhận nhiệm vụ và NPC. Bốn điểm ban đầu được đặt ở các hệ 01, 04, 07 và 09. Nội dung hub hiện tại còn giới hạn theo MVP.
- **Hành tinh thuộc địa:** điểm nhận và giao hàng.
- **Hành tinh khai thác:** nơi có thể thu thập tài nguyên phục vụ nhiệm vụ và nâng cấp. Bản demo hiện ghi chú tài nguyên có tại điểm khai thác; vòng lặp thu thập chưa được triển khai.

Người chơi có thể đánh dấu các hệ bằng sáu sigil hình học trừu tượng, mỗi sigil có màu neon riêng. Sigil không có ý nghĩa cố định; người chơi tự gán ý nghĩa. Dấu đánh dấu được lưu cùng game. Tên hệ sao và tài nguyên trong bản demo là dữ liệu tạm để chạy chức năng, chưa phải lore cuối cùng.

## 4. Events
Event được trình bày như câu hỏi từ AI assistant hoặc crew và có hai lựa chọn. Nội dung, hậu quả, tần suất và cách chọn nguồn hỏi chưa được thiết kế. Crew/NPC system thuộc phase sau.

## 5. Delivery và economy
Người chơi đưa đúng cargo (theo hình dạng/tên) tới nơi nhận để hoàn tất delivery. Cargo có thể chiếm nhiều hình dạng và kích thước; item thông thường là hình chữ nhật, cargo irregular chỉ là hàng đặc biệt. Bán cargo có thể đem lại nhiều tiền hơn giao hàng nhưng làm giảm reputation; lạm dụng có thể khiến nơi cung cấp hàng ban người chơi. Giá trị cụ thể chưa chốt.

Chỉ có một currency. Reputation XP dùng để mở khóa NPC, quest và feature. Chưa chốt ngưỡng/nguồn tăng giảm.

### Hub
Hub civilization trong tầm nhìn tương lai có thể bao gồm buy/sell, delivery, repair, refuel, quests, NPC, events, upgrades, casino, exploration. MVP chỉ bao gồm delivery và buy/sell inventory; không tạo nội dung NPC/story.

## 6. Combat
Combat là module phụ và có thể xuất hiện do một số tình huống, NPC/quest tương lai hoặc hải tặc; chưa chốt quy tắc spawn. Khi combat bắt đầu, route tiếp tục; kẻ địch tồn tại trong một khoảng thời gian hữu hạn rồi rút. Ba hướng thắng/giải quyết đã chốt: tiêu diệt tất cả địch; sống sót hết thời gian tấn công; dùng equipment đặc biệt. Khi thắng, tiếp tục route.

Combat hướng twin-stick top-down. Vũ khí có thể đặt tại bất kỳ cell hợp lệ; aim độc lập, vị trí vũ khí xác định nguồn projectile. Không có quy tắc weapon phải chạm cạnh/đến gần power. Armor tự động hấp thụ damage theo defense pool trước khi hull mất HP. Hull HP bằng 0 dẫn đến chết.

## 7. Death và save
Resource cạn có thể làm tàu dừng; food = 0 thì chết. Death đưa người chơi về save trước. Autosave mỗi 5 phút và có save/load. Save-slot strategy, autosave rotation, checkpoint semantics và thời điểm chính xác death restore chưa chốt.

## 8. Tiến trình
Nâng cấp bằng cách có tàu lớn/tốt hơn với layout vật lý mới cho cách build khác, không chỉ cộng thêm slot. Reputation XP mở thêm NPC/quest/features trong tương lai. Cốt truyện và NPC chưa thuộc MVP.

## 9. MVP boundary
MVP chứng minh được map/travel từng planet, tiêu hao/hồi resource, segment events hai lựa chọn, delivery nhiều chuyến nếu cần, hub tối giản, inventory grid chung và placement, combat survival cơ bản, save/load/autosave/death restore. NPC/crew, story content, casino, exploration systems và các hub service ngoài delivery/buy-sell để sau.
