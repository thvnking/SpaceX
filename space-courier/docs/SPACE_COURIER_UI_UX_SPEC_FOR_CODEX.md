# SPACE COURIER — UI/UX DESIGN SPECIFICATION
## Tài liệu nền tảng cho Codex

**Phiên bản:** 0.1  
**Trạng thái:** Design baseline — một phần đã xác nhận, một phần là đề xuất cần kiểm chứng  
**Ngôn ngữ giao diện:** Tiếng Việt  
**Engine:** Godot  
**Tỉ lệ thiết kế mục tiêu:** 16:9  
**Độ phân giải tham chiếu:** 2560 × 1440  

**Phạm vi:** Đây là hướng dẫn UI có cả MVP và hình dung tương lai. Luật gameplay mới nhất nằm trong `SYSTEMS.md` và `GAME_DESIGN.md`. Màn hình crew, mua tàu và hub chưa được triển khai trong MVP; các phần này chỉ là hướng tham khảo cho tương lai.

---

## 0. Hướng dẫn quan trọng cho Codex

Tài liệu này là nguồn định hướng UI/UX hiện tại của Space Courier. Khi triển khai:

1. Không tự tạo thêm gameplay, luật equipment, chỉ số, tài nguyên, điều kiện mở khóa hoặc hành vi NPC chưa được xác nhận.
2. Phân biệt nội dung **ĐÃ XÁC NHẬN**, **ĐỀ XUẤT UI/UX** và **TODO / CHƯA XÁC ĐỊNH**.
3. Khi thiếu dữ liệu gameplay, tạo cấu trúc UI có thể nhận dữ liệu sau này; dùng placeholder được ghi rõ, không giả lập thành luật chính thức.
4. Không biến mọi màn hình thành cùng một dashboard. Dùng chung design system nhưng mỗi màn hình phải có cấu trúc và cá tính phù hợp chức năng.
5. Không hiển thị tàu 3D thường trực trong Ship Management. Chỉ hiển thị hình ảnh tàu ở những ngữ cảnh gameplay đã được xác nhận.
6. Ưu tiên gameplay, khả năng đọc nhanh và không che khuất vùng chơi.
7. Các tên tàu, số liệu, phần trăm, tên nhân vật và ví dụ trong mockup chỉ là dữ liệu minh họa, không phải dữ liệu game chính thức.

### Quy ước trạng thái trong tài liệu

- **[CONFIRMED]**: Người dùng đã xác nhận.
- **[DESIGN PROPOSAL]**: Đề xuất thiết kế UI/UX, có thể thay đổi.
- **[TODO]**: Chưa có quyết định; không tự suy diễn thành gameplay.
- **[IMPLEMENTATION NOTE]**: Gợi ý kỹ thuật triển khai, không phải yêu cầu gameplay.

---

# 1. Tổng quan trò chơi và trải nghiệm

## 1.1. Bản sắc trải nghiệm

**[CONFIRMED]**

Space Courier là trải nghiệm khám phá vũ trụ rộng lớn, nơi người chơi điều khiển một con tàu vũ trụ chuyên nghiệp. Thế giới mang tinh thần phiêu lưu, kỳ thú, giàu cảm xúc, có nhiều nền văn minh và chủng tộc.

Con tàu được cảm nhận như một **ngôi nhà di động giữa không gian**, không chỉ là phương tiện di chuyển.

- Công nghệ trong UI: hiện đại, sạch sẽ, tinh tế.
- Thế giới và nội dung: phiêu lưu, đa dạng, giàu cảm xúc.
- Tinh thần tham chiếu: sự gần gũi, tự do của *Cowboy Bebop*; hình ảnh công nghệ của *Blade Runner*, *Cyberpunk* và *Armored Core*.
- UI là lớp hỗ trợ gameplay, không phải tâm điểm thường trực.

## 1.2. Nguyên tắc trải nghiệm

**[CONFIRMED]**

1. UI không rối mắt và không chiếm quá nhiều không gian.
2. Chỉ hiển thị thông tin khi cần thiết hoặc liên quan đến ngữ cảnh hiện tại.
3. Thông tin phải đọc nhanh.
4. UI có cảm giác như các thành phần HUD/AR nổi trước màn hình, nhưng **không phải** hình chiếu lên môi trường 3D trong game.
5. UI không được quá tự động hóa, lạnh lùng hoặc vô cảm.
6. Giữ một theme UI thống nhất giữa các nền văn minh. Sự khác biệt văn minh được thể hiện qua background, NPC, tàu, equipment và cargo — không đổi toàn bộ ngôn ngữ UI.

---

# 2. Art Direction

## 2.1. Tên định hướng

**[DESIGN PROPOSAL] Clean Frontier HUD**

Modern Sci-fi tối giản, sạch, có tính kỹ thuật và cinematic vừa đủ; phù hợp với một người du hành tự do trong vũ trụ rộng lớn.

## 2.2. Phong cách hình ảnh

**[CONFIRMED]**

- Modern Sci-fi.
- Flat UI, tối giản.
- Hình học kỹ thuật, nhiều đường cắt/góc cắt.
- Panel có thể chồng lớp, tạo chiều sâu nhẹ.
- Bố cục dashboard bất đối xứng.
- Có đường kỹ thuật, grid và chi tiết cấu trúc nhưng phải có ý nghĩa.
- Glow được sử dụng tương đối rõ nhưng có kiểm soát.
- UI là giao diện game độc lập, không phải màn hình vật lý của tàu.
- Cảm giác cinematic và functional cân bằng khoảng 50/50.
- Icon gợi phong cách retro/neon pixel thưa, nhưng vẫn phải rõ nghĩa ở kích thước nhỏ.

**Tránh:**

- Cartoon.
- Giao diện giả lập realistic như một bảng điều khiển vật lý.
- Bo tròn quá nhiều.
- Trang trí không có ý nghĩa.
- Thông tin thường trực không cần thiết.
- Panel và đường viền dày đặc khiến màn hình nặng nề.

## 2.3. Màu sắc

**[CONFIRMED]**

UI chính dùng trắng/xám bạc để tương thích với nhiều background, hành tinh và nền văn minh.

| Vai trò | Màu gợi ý | Cách dùng |
|---|---|---|
| Primary white | `#F1F1ED` | Chữ, icon và đường viền chính |
| Pure white | `#FFFFFF` | Điểm sáng, trạng thái nổi bật |
| Silver | `#B8BEC2` | Thông tin phụ |
| Muted gray | `#747D83` | Nội dung phụ, trạng thái ít quan trọng |
| Dark glass | `#202428` | Nền panel kính tối khi cần tương phản |
| Warning red | `#E34B43` | Hư hại, nguy hiểm, thiếu tài nguyên |
| Objective yellow | `#E6BC58` | Mục tiêu, lựa chọn/đối tượng được đánh dấu |

Các mã màu là **[DESIGN PROPOSAL]**, cần kiểm tra trên gameplay background thật.

Quy tắc:
- Trắng/bạc là nhận diện mặc định.
- Đỏ chỉ dùng khi có cảnh báo thực tế; có thể kết hợp icon và nhấp nháy.
- Vàng dành cho mục tiêu hoặc đối tượng được đánh dấu.
- Không đổi màu UI theo từng hành tinh/nền văn minh.
- Không phụ thuộc duy nhất vào màu để truyền đạt trạng thái; dùng icon, hình dạng hoặc nhãn đi kèm.
- Khi background quá sáng, dùng nền glass tối, shadow hoặc tăng tương phản cục bộ thay vì đổi theme.

## 2.4. Typography

**[CONFIRMED]**
- Game hoàn toàn bằng tiếng Việt ở giai đoạn hiện tại.
- Typography tương lai, đặc trưng, tiêu đề có thể mạnh, đậm, vuông vức.
- Ít chữ, ngắn gọn.
- Font sci-fi phải dễ đọc, đặc biệt với dấu tiếng Việt.

**[DESIGN PROPOSAL]**

| Vai trò | Font gợi ý | Dùng cho |
|---|---|---|
| Heading | Exo 2 | Tiêu đề màn hình, tên tàu, nhãn lớn |
| Body | Be Vietnam Pro | Nội dung, mô tả, hội thoại |
| Data | IBM Plex Mono | Số liệu, tọa độ, thời gian, thông số |

Font cần được kiểm tra glyph tiếng Việt, độ đậm và rendering trong Godot trước khi chốt. Không dùng font sci-fi cách điệu cho đoạn văn dài.

Quy tắc:
- Viết hoa cho heading và nhãn ngắn.
- Không viết hoa toàn bộ đoạn văn.
- Số liệu dùng font có độ rộng ký tự ổn định.
- Phân cấp chữ rõ ràng, hạn chế quá nhiều cỡ chữ trong một panel.

---

# 3. UI Design System

## 3.1. Ba lựa chọn đã chốt

**[CONFIRMED]**

- **Panel:** Glass — kính tối trong suốt.
- **Information density:** Context — thông tin hiển thị theo ngữ cảnh.
- **Glow:** Medium — glow vừa phải, nhìn thấy được ở viền, icon và trạng thái tương tác.

## 3.2. Panel system

**[CONFIRMED]**
- Hình học kỹ thuật, góc cắt.
- Border mảnh.
- Có thể có nhiều lớp viền.
- Flat card, tối giản.
- Panel nhỏ gọn, không che màn hình.
- Header không bắt buộc; chỉ dùng khi cần định hướng hoặc phân nhóm.
- Tooltip chỉ nên có text ngắn.

**[DESIGN PROPOSAL]** Bốn loại panel:

1. **Primary panel:** vùng nội dung chính, tương phản rõ hơn.
2. **Secondary panel:** dữ liệu phụ, thông số và trạng thái.
3. **Floating panel:** menu ngữ cảnh, hành động hoặc thông tin xuất hiện khi chọn.
4. **Alert panel:** cảnh báo có màu chức năng tương ứng.

Không bọc mọi dòng thông tin trong một card. Một số nhãn, số liệu hoặc icon có thể hiển thị trực tiếp trên nền.

## 3.3. Buttons và trạng thái

**[DESIGN PROPOSAL]**

- Hình dáng vuông/góc cắt, không dùng pill button.
- Normal: chữ và border trắng/bạc.
- Hover: tăng sáng nhẹ hoặc hiện đường viền.
- Selected: nền sáng hoặc dấu nhấn rõ.
- Disabled: giảm tương phản, không biến mất hoàn toàn nếu người chơi cần biết chức năng tồn tại.
- Warning/destructive: dùng đỏ có chủ đích.
- Click: phản hồi nhanh, chuyển động ngắn.

## 3.4. Icon

**[CONFIRMED]**
- Vector icon.
- Có thể dùng ngôn ngữ retro/neon pixel thưa.
- Icon phải có ý nghĩa thực tế.
- Phải nhận diện được ở kích thước nhỏ.

**[DESIGN PROPOSAL]**
- Icon chức năng: vector rõ ràng, hình học, nhất quán stroke.
- Icon nhận diện: retro-futuristic, pixel thưa, dùng có chọn lọc.
- Không dùng icon chỉ để trang trí.

## 3.5. Progress và trạng thái

**[CONFIRMED]**
- Có progress bar.
- Màu trạng thái cần phản ánh ý nghĩa chức năng.
- Cảnh báo nguy hiểm có thể nhấp nháy và dùng icon.

**[DESIGN PROPOSAL]**
- Progress bar mảnh, track tối và fill sáng.
- Luôn đi kèm nhãn hoặc giá trị số nếu giá trị quan trọng.
- Cảnh báo đỏ không được dùng cho trạng thái bình thường.
- Không nhấp nháy liên tục nếu không có tình huống nguy hiểm.

## 3.6. Motion

**[CONFIRMED]**
- Chuyển động mượt.
- Chuyển màn hình ưu tiên slide.
- Chọn hành tinh có tag map/hình khối trừu tượng.
- Cảnh báo có thể nhấp nháy và có icon.
- Âm thanh UI chưa nằm trong phạm vi thiết kế hiện tại.

**[DESIGN PROPOSAL]**
- Hover: 100–150 ms.
- Panel: 180–250 ms.
- Chuyển màn hình: 250–350 ms.
- Ưu tiên slide + fade.
- Không dùng chuyển động chỉ để trang trí.

---

# 4. Layout và điều hướng toàn game

## 4.1. Quy chuẩn màn hình

**[CONFIRMED]**
- Tỷ lệ 16:9.
- Độ phân giải thiết kế mục tiêu 2560×1440.
- Sidebar trái + Main Content là cấu trúc định hướng.
- Nhiều khoảng trống.
- Dashboard bất đối xứng.
- Ưu tiên đọc nhanh.
- Không muốn UI HUD tàu xuất hiện thường trực khi không cần.

## 4.2. Tái sử dụng framework

**[CONFIRMED]**
Các màn hình dùng chung framework nhưng không được quá giống nhau.

Các hướng màn hình đã xác định:

| Màn hình | Định hướng |
|---|---|
| Galaxy Map | Holographic star map |
| Ship Management | Dashboard quản lý |
| Cargo | Kho hàng vật lý |
| Trading | Chợ không gian |
| NPC/Crew | Nhân vật xuất hiện, hội thoại với hai lựa chọn |
| Main Menu | Hình ảnh tàu vũ trụ làm trọng tâm |
| Combat | Chưa chốt UI chi tiết |

### Side map MVP đã triển khai

Màn hình Galaxy Map dùng bố cục bản đồ khu vực ở bên trái và side panel ở bên phải. Bản đồ hỗ trợ chọn hệ bằng click, zoom bằng bánh xe, kéo để pan, nút Reset View và nút Current System. Side panel phải luôn cho biết hệ được chọn, có phải hệ hiện tại hay không, các planet trong hệ, loại planet, resource notes, route quote trực tiếp và nút khởi hành. Sáu sigil là marker do người chơi tự gán và được lưu theo system. Nút khởi hành chỉ hoạt động khi đang docked và đủ food/fuel theo quote; side map không tự tạo topology hay luật gameplay ngoài dữ liệu runtime.

Đặc trưng khu vực/nền văn minh nên đến từ background, NPC, equipment, cargo và tàu; không làm thay đổi theme UI chính.

---

# 5. Các quy tắc gameplay liên quan đến tàu và phi hành đoàn

## 5.1. Hiển thị tàu

**[CONFIRMED]**
- Không hiển thị tàu 3D thường trực trong màn hình quản lý tàu.
- Người dùng đã nêu tàu xuất hiện ở các ngữ cảnh:
  1. Combat: sprite 2D nhỏ của tàu.
  2. Sắp xếp: hình ảnh nhìn từ trên xuống.
  3. Mua tàu: hình ảnh trực quan để xem tàu.
- Người dùng nói có bốn dạng hiển thị nhưng mới mô tả ba dạng.

**[TODO]**
- Xác định dạng hiển thị thứ tư.
- Không tự thêm một dạng hiển thị tàu.

## 5.2. Chỉ số tàu

**[CONFIRMED]**
Thông số tàu được quyết định bởi:
- Chỉ số cố định của bản thân tàu.
- Ảnh hưởng từ equipment đang lắp.

**[DESIGN PROPOSAL]**
Khi hiển thị một chỉ số, có thể phân biệt:
- Giá trị nền từ thân tàu.
- Phần cộng/trừ từ equipment.
- Giá trị tổng cuối cùng.

Không tự đặt công thức cộng, hệ số, giới hạn hoặc chỉ số mới. Dữ liệu phải lấy từ gameplay model.

## 5.3. Equipment

**[CONFIRMED — gameplay baseline 2026-11-21]**
- Ở Civilization hub, người chơi có thể thêm, bớt và sắp xếp cargo/equipment.
- Ở Colony/Extraction, chỉ sắp xếp item đang mang; trong flight/combat không được thay đổi inventory.
- Người chơi bố trí equipment trên **Physical Grid**, không chỉ chọn slot cố định.
- Equipment Management phải được thiết kế xoay quanh tương tác grid vật lý.

**[CONFIRMED — gameplay baseline]**
- Footprint tàu, grid dùng chung, không chồng lấn, xoay 90 độ, không mirror/weight/adjacency được quy định trong `SYSTEMS.md`.
- Không có thao tác thêm/bớt/sắp xếp trong flight/combat.

**[DEFERRED]**
- Cách sửa chữa hoặc lưu trữ equipment hỏng; durability không thuộc loadout cơ bản.

Codex không được tự tạo những luật trên. Có thể chuẩn bị UI state/extension point nhưng phải đánh dấu TODO.

## 5.4. Phi hành đoàn

**[FUTURE VISUAL DIRECTION — crew deferred]**
- Phi hành đoàn là các nhân vật thuộc cốt truyện và event.
- Nhân vật tham gia chính thức sau khi người chơi hoàn thành nhiệm vụ và đáp ứng điều kiện cá nhân.
- Ý tưởng tương lai có một robot ban đầu; nhân vật chưa được thiết kế hoặc đưa vào MVP.
- Crew UI dùng chân dung nhỏ.
- Khi chọn nhân vật, UI mở hiển thị toàn thân để người chơi tương tác và trò chuyện.

**[DESIGN PROPOSAL]**
- Crew screen nên mang cảm giác tương tác nhân vật, không phải bảng quản lý nhân sự khô cứng.
- Chân dung nhỏ là điểm chọn nhân vật.
- Khu vực chính dành cho nhân vật toàn thân và không gian hội thoại.
- Hội thoại có hai lựa chọn theo định hướng hiện tại.

**[TODO]**
- Tên, ngoại hình, tính cách, kỹ năng và chỉ số của robot.
- Số lượng thành viên tối đa.
- Quan hệ, affinity, morale hoặc các chỉ số xã hội khác — chưa được xác nhận, không tự thêm.
- Quy tắc vị trí và vai trò của từng thành viên.

---

# 6. Equipment Management — Đặc tả thiết kế UI

## 6.1. Mục tiêu màn hình

**[CONFIRMED + DESIGN PROPOSAL]**

Màn hình Equipment Management cho phép người chơi (theo quyền của nơi hiện tại):
- Quan sát bố trí equipment trên Physical Grid của tàu.
- Chọn equipment đang lắp.
- Xem thông tin equipment được chọn.
- Bố trí equipment theo cơ chế grid vật lý.
- Xem tác động của equipment lên thông số tàu, dựa trên dữ liệu gameplay.
- Civilization hub: mua/bán equipment cơ bản, thêm/bớt và sắp xếp. Hành tinh khác: chỉ sắp xếp item có sẵn. Flight/combat: chỉ xem.

Màn hình phải làm nổi bật **sơ đồ bố trí thiết bị**, không dùng mô hình tàu 3D làm trung tâm.

## 6.2. Bố cục đề xuất

**[DESIGN PROPOSAL]** Bố cục 3 vùng bất đối xứng:

```text
┌──────────────────────────────────────────────────────────────────────────┐
│  ĐIỀU HƯỚNG / TÊN TÀU / TRẠNG THÁI ĐỊA ĐIỂM                              │
├───────────────┬───────────────────────────────────┬──────────────────────┤
│               │                                   │                      │
│  EQUIPMENT    │        PHYSICAL GRID              │   EQUIPMENT DETAILS  │
│  INVENTORY    │        TOP-DOWN LAYOUT             │                      │
│               │                                   │   Tên thiết bị       │
│  Danh sách    │   [các ô / footprint thiết bị]    │   Hình minh họa      │
│  thiết bị     │                                   │   Mô tả ngắn         │
│               │   vùng bố trí trực quan           │   Thông số           │
│  Bộ lọc       │                                   │   Tác động lên tàu   │
│  (nếu cần)    │                                   │                      │
│               │                                   │   Thao tác khả dụng  │
├───────────────┴───────────────────────────────────┴──────────────────────┤
│  TÓM TẮT THAY ĐỔI / HÀNH ĐỘNG XÁC NHẬN / QUAY LẠI                       │
└──────────────────────────────────────────────────────────────────────────┘
```

Không bắt buộc giữ đủ cả ba vùng ở mọi trạng thái. Khi người chơi chưa chọn equipment, vùng chi tiết có thể thu gọn hoặc chỉ hiển thị hướng dẫn ngắn.

### Vùng A — Equipment Inventory

**[DESIGN PROPOSAL]**
- Hiển thị danh sách equipment người chơi có thể sử dụng.
- Mỗi item nên có icon/thumbnail, tên ngắn và thông tin phân biệt cần thiết.
- Chọn item để xem chi tiết.
- Có thể kéo item từ inventory sang Physical Grid nếu gameplay hỗ trợ drag-and-drop.
- Không tự tạo category/filter nếu dữ liệu game chưa có.

### Vùng B — Physical Grid

**[CONFIRMED]** Đây là vùng tương tác trung tâm.

**[DESIGN PROPOSAL]**
- Dùng hình nhìn từ trên xuống, dạng sơ đồ kỹ thuật.
- Grid là bề mặt bố trí vật lý, không phải danh sách slot cố định.
- Equipment được biểu diễn bằng footprint/hình dạng tương ứng với dữ liệu thật.
- Trạng thái hover/selected cần phân biệt rõ.
- Khi kéo item, có thể hiển thị preview vị trí dự kiến.
- Nếu gameplay có luật hợp lệ/không hợp lệ, thể hiện bằng viền/trạng thái trực quan; không tự nghĩ ra luật hợp lệ.
- Có thể dùng đường viền sáng và glow vừa phải cho item đang chọn.
- Không dùng màu sắc để truyền đạt quá nhiều trạng thái.

### Vùng C — Equipment Details

**[DESIGN PROPOSAL]**
Khi chọn một equipment, hiển thị:
- Tên thiết bị.
- Hình minh họa hoặc icon.
- Mô tả ngắn.
- Các thông số thực tế do gameplay cung cấp.
- Ảnh hưởng lên thông số tàu nếu có dữ liệu.
- Các thao tác khả dụng do gameplay cho phép.

Không tạo rarity, level, durability, power draw, heat, adjacency bonus hoặc thuộc tính khác nếu game chưa xác nhận có chúng.

### Vùng D — Change Summary

**[DESIGN PROPOSAL]**
Nếu game có trạng thái chỉnh sửa tạm trước khi xác nhận:
- Hiển thị tóm tắt thay đổi.
- Cho phép xác nhận hoặc hủy thay đổi.
- Chỉ triển khai nếu gameplay thực sự có bước commit/rollback.

**[TODO]** Chưa xác nhận việc bố trí được áp dụng tức thì hay cần nút xác nhận.

## 6.3. Luồng tương tác đề xuất

Luồng dưới đây là cách thể hiện UI, không áp đặt luật gameplay:

1. Người chơi mở Equipment Management.
2. UI xác định ngữ cảnh hiện tại có cho phép thay equipment hay không.
3. Nếu được phép, người chơi chọn equipment trong inventory.
4. UI hiển thị chi tiết equipment.
5. Nếu hệ thống hỗ trợ, người chơi kéo equipment vào vị trí trên Physical Grid.
6. UI phản hồi trạng thái vị trí theo luật placement do gameplay cung cấp.
7. Khi thay đổi hợp lệ, cập nhật preview bố trí và thông số tàu theo dữ liệu gameplay.
8. Nếu có cơ chế xác nhận, người chơi xác nhận hoặc hủy.
9. Nếu không được phép thay equipment tại thời điểm hiện tại, UI chuyển sang chế độ xem và giải thích ngắn gọn.

## 6.4. Các trạng thái màn hình cần thiết

**[DESIGN PROPOSAL]**
- Default: chưa chọn equipment.
- Item selected: một equipment được chọn.
- Dragging: đang kéo equipment.
- Placement preview: đang xem trước vị trí.
- Placement accepted: vị trí được gameplay xác nhận hợp lệ.
- Placement rejected: vị trí bị gameplay xác nhận không hợp lệ.
- Read-only / unavailable: không thể thay equipment trong ngữ cảnh hiện tại.
- Empty inventory: không có item phù hợp để hiển thị.
- Loading / data unavailable: dữ liệu chưa sẵn sàng.

Chỉ hiển thị các trạng thái phù hợp với hệ thống gameplay thực tế. Không tự tạo nguyên nhân placement rejected.

## 6.5. Điều khiển

**[CONFIRMED]** Keyboard và mouse.

**[DESIGN PROPOSAL]**
- Click: chọn equipment hoặc ô/vùng bố trí.
- Drag: di chuyển equipment nếu hệ thống hỗ trợ.
- Esc: thoát chế độ chọn/kéo hoặc quay lại theo navigation convention của game.
- Tooltip: chỉ xuất hiện khi hover và chỉ chứa thông tin ngắn.
- Không yêu cầu gamepad ở giai đoạn hiện tại.

**[TODO]**
- Phím xoay equipment.
- Snap behavior.
- Zoom/pan grid.
- Multi-select.
- Undo/redo.
- Drag từ inventory hay thao tác chọn rồi click vị trí.

Không triển khai các hành vi TODO như luật chính thức khi chưa được xác nhận.

## 6.6. Quy tắc hiển thị thông số

**[CONFIRMED]** Chỉ số tàu đến từ thân tàu và equipment. Hull cố định, không tăng bằng equipment; armor có thể tăng bằng equipment. Xem `SYSTEMS.md` để biết các giá trị đã chốt.

**[DESIGN PROPOSAL]** Nếu gameplay cung cấp dữ liệu:
- Hiển thị giá trị hiện tại.
- Hiển thị phần đóng góp từ thân tàu.
- Hiển thị phần đóng góp từ equipment.
- Làm nổi bật thay đổi dự kiến khi preview.

Không tự đặt công thức hoặc giá trị mẫu vào production UI. Dữ liệu mock phải được gắn nhãn rõ ràng.

---

# 7. Ship Management — Phạm vi và cấu trúc

## 7.1. Nguyên tắc

**[CONFIRMED]**
- Không hiển thị tàu 3D thường trực.
- Thông số đến từ thân tàu cố định + equipment; hull không tăng, armor có thể tăng bằng equipment.
- Civilization hub cho mua/bán equipment cơ bản, thêm/bớt/sắp xếp; hành tinh khác chỉ sắp xếp item sẵn có; flight/combat khóa inventory.
- Equipment dùng Physical Grid.

## 7.2. Điều hướng đề xuất

**[DESIGN PROPOSAL]**
Các mục có thể gồm:
- Tổng quan.
- Equipment.
- Sắp xếp / Physical Grid.
- Phi hành đoàn.
- Bảo trì.

Danh sách này là cấu trúc điều hướng đề xuất, cần đối chiếu với các hệ thống thật trong project trước khi cố định.

## 7.3. Tổng quan tàu

Nên tập trung vào:
- Tên và loại tàu.
- Các chỉ số thực sự tồn tại.
- Trạng thái tàu và tài nguyên cần theo dõi.
- Tóm tắt equipment.
- Lối vào Crew Management.

Không dùng một render tàu 3D lớn để lấp khoảng trống. Có thể dùng sơ đồ kỹ thuật, icon, typography hoặc hình ảnh dữ liệu phù hợp nếu cần.

---

# 8. Crew Management — Hướng UI

**[FUTURE VISUAL DIRECTION — crew deferred]**
- Crew là nhân vật cốt truyện/event.
- Gia nhập chính thức sau khi hoàn thành nhiệm vụ và đáp ứng điều kiện cá nhân.
- Ý tưởng tương lai có một robot khởi đầu; chưa thiết kế/triển khai.
- Danh sách dùng chân dung nhỏ.
- Chọn nhân vật mở hiển thị toàn thân để tương tác/trò chuyện.

**[DESIGN PROPOSAL]**
- Một dải chân dung nhỏ để chọn thành viên.
- Khu vực chính dành cho nhân vật toàn thân.
- Hội thoại và hai lựa chọn được trình bày rõ ràng, ít chữ.
- Không biến màn hình thành bảng chỉ số nhân sự.
- Giữ không gian cho biểu cảm, animation và bối cảnh nhân vật.

**[TODO]**
- Robot khởi đầu chưa có tên, ngoại hình và tính cách chính thức trong tài liệu này.
- Chưa xác định các chỉ số xã hội/kỹ năng crew.
- Chưa xác định giới hạn số lượng crew.

---

# 9. Hướng dẫn triển khai trong Godot

Đây là kiến trúc gợi ý, cần điều chỉnh theo cấu trúc project hiện có. Không tạo lại toàn bộ project hoặc đổi kiến trúc gameplay nếu chưa kiểm tra codebase.

## 9.1. Cấu trúc scene gợi ý

```text
UI/
├── Core/
│   ├── UIManager
│   ├── Theme
│   ├── Typography
│   └── DesignTokens
│
├── Components/
│   ├── Panels/
│   ├── Buttons/
│   ├── Icons/
│   ├── Tooltips/
│   ├── ProgressBars/
│   └── Alerts/
│
├── Screens/
│   ├── ShipManagement/
│   │   ├── ShipOverview
│   │   ├── EquipmentManagement
│   │   ├── PhysicalGrid
│   │   └── CrewManagement
│   ├── GalaxyMap/
│   ├── Cargo/
│   ├── Trading/
│   └── MainMenu/
│
└── Transitions/
```

## 9.2. Nguyên tắc kỹ thuật

**[IMPLEMENTATION NOTE]**
- Dùng Godot Theme và theme overrides để quản lý style dùng chung.
- Tách reusable component thành scene riêng khi phù hợp.
- Dùng Container, anchors và size flags để hỗ trợ nhiều kích thước màn hình.
- Không gom toàn bộ UI vào một scene khổng lồ.
- Tách UI presentation khỏi gameplay state.
- UI đọc dữ liệu từ hệ thống gameplay; không tự làm nguồn dữ liệu gameplay.
- Dùng signal để truyền sự kiện giữa UI và gameplay layer.
- Tránh hard-code chỉ số tàu/equipment trong scene.
- Dùng placeholder data riêng cho mockup và không nhầm với dữ liệu thật.
- Kiểm tra tiếng Việt và font fallback.
- Kiểm tra độ tương phản UI trên nhiều background.

## 9.3. Physical Grid — ranh giới trách nhiệm

**[IMPLEMENTATION NOTE]**
- UI chịu trách nhiệm hiển thị grid, selection, drag preview và phản hồi kết quả.
- Gameplay/model layer phải là nơi xác định placement hợp lệ hay không.
- UI không tự quyết định kích thước footprint, collision, rotation, adjacency, power hoặc các luật vật lý khác.
- Nên thiết kế giao diện nhận một kết quả placement từ gameplay layer để thể hiện trạng thái, thay vì tự tính luật trong UI.
- Nếu gameplay chưa có API placement, tạo interface/stub được đánh dấu TODO, không giả lập luật hoàn chỉnh.

---

# 10. Những điều chưa được xác nhận — không tự suy diễn

Các quyết định UI/asset còn để giai đoạn phù hợp:

1. Dạng hiển thị tàu thứ tư.
2. Art cuối cùng cho footprint tàu và equipment đã chốt ở `SYSTEMS.md`.
3. Hiển thị dữ liệu hiệu ứng khi runtime equipment hoàn thành.
7. Cách commit/rollback thay đổi equipment.
8. Chi tiết thao tác zoom, pan, snap và undo/redo.
9. Thiết kế gameplay/nhân vật crew khi vào giai đoạn sau.
10. Điều hướng Ship Management đầy đủ sau MVP.
11. Chi tiết HUD combat sau khi vòng lặp combat hoạt động.

Không biến các mục này thành feature đã chốt.

---

# 11. Checklist nghiệm thu UI Equipment Management

## Art Direction
- [ ] Trắng/bạc là màu chính.
- [ ] Panel glass tối trong suốt.
- [ ] Glow mức vừa.
- [ ] Border mảnh, góc cắt kỹ thuật.
- [ ] Bố cục bất đối xứng, có khoảng trống.
- [ ] Không có panel hoặc chữ trang trí vô nghĩa.

## Information design
- [ ] Chỉ hiển thị thông tin liên quan đến ngữ cảnh.
- [ ] Thông số lấy từ gameplay model.
- [ ] Không hard-code số liệu minh họa vào production.
- [ ] Giá trị thân tàu và ảnh hưởng equipment được phân biệt nếu dữ liệu hỗ trợ.

## Physical Grid
- [ ] Grid nhìn từ trên xuống.
- [ ] Equipment có thể được chọn.
- [ ] Selection và hover dễ phân biệt.
- [ ] Preview placement không giả lập luật chưa xác nhận.
- [ ] Gameplay layer quyết định placement hợp lệ.
- [ ] UI phản ánh đúng trạng thái cho phép/không cho phép thay equipment.

## Gameplay constraints
- [ ] Không hiển thị tàu 3D thường trực.
- [ ] Civilization hub cho mua/bán equipment cơ bản, thêm/bớt/sắp xếp; hành tinh khác chỉ sắp xếp; flight/combat khóa inventory.
- [ ] Không tự tạo slot cố định thay cho Physical Grid.
- [ ] Không tự tạo luật equipment chưa được xác nhận.

## Godot
- [ ] Reusable components được tách hợp lý.
- [ ] UI không sở hữu gameplay logic.
- [ ] Layout thích ứng với viewport.
- [ ] Font hỗ trợ tiếng Việt đầy đủ.
- [ ] Chạy thử trên background sáng và tối.

---

# 12. Chỉ dẫn cho bước triển khai đầu tiên

Codex nên thực hiện theo thứ tự:

1. Kiểm tra cấu trúc project Godot hiện có và xác định các scene/UI/gameplay data liên quan đến tàu, equipment và inventory.
2. Báo cáo những hệ thống và dữ liệu đã tồn tại; không sửa gameplay ngoài phạm vi.
3. Xác định dữ liệu thật có thể cung cấp cho Equipment Management.
4. Xây dựng design tokens/theme và reusable panel/button/text styles theo tài liệu này.
5. Dựng layout Equipment Management với Physical Grid ở trung tâm, inventory ở một bên và details ở bên còn lại.
6. Kết nối selection và placement preview với gameplay API nếu API đã tồn tại.
7. Nếu API hoặc luật gameplay chưa tồn tại, tạo UI scaffold rõ ràng và liệt kê câu hỏi cần người dùng quyết định.
8. Kiểm tra ở 2560×1440 và một số viewport 16:9 khác.

**Ưu tiên:** dựng đúng cấu trúc, hierarchy và interaction trước; polish glow, animation và chi tiết trang trí sau.

---

## Kết luận

Space Courier cần một UI hiện đại, sạch, trắng/bạc, mang cảm giác HUD/AR độc lập với môi trường game. UI phải tiết chế và theo ngữ cảnh, trong khi thế giới, con tàu, equipment và nhân vật tạo nên sự phong phú và cảm xúc.

Đối với Equipment Management, **Physical Grid là nguyên tắc tương tác cốt lõi đã được xác nhận**. Codex cần xây dựng giao diện xoay quanh sơ đồ bố trí thiết bị nhìn từ trên xuống, nhưng không được tự tạo luật placement hoặc thông số gameplay chưa được quyết định.
