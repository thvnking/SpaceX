from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.section import WD_ORIENT
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_CELL_VERTICAL_ALIGNMENT
from docx.oxml import OxmlElement
from docx.oxml.ns import qn

OUT = r"C:\Users\ADMIN\Documents\SpaceX\space-courier\docs\BAO_CAO_TIEN_DO_SPACE_COURIER.docx"
doc = Document()
sec = doc.sections[0]
sec.orientation = WD_ORIENT.LANDSCAPE
sec.page_width, sec.page_height = sec.page_height, sec.page_width
sec.top_margin = Inches(.55); sec.bottom_margin = Inches(.55)
sec.left_margin = Inches(.55); sec.right_margin = Inches(.55)

styles = doc.styles
styles['Normal'].font.name = 'Aptos'; styles['Normal'].font.size = Pt(9)
styles['Title'].font.name = 'Aptos Display'; styles['Title'].font.size = Pt(26); styles['Title'].font.bold = True; styles['Title'].font.color.rgb = RGBColor(0,0,0)
title_ppr = styles['Title']._element.get_or_add_pPr()
for child in list(title_ppr):
    if child.tag == qn('w:pBdr'):
        title_ppr.remove(child)
for s in ('Heading 1','Heading 2'):
    styles[s].font.name = 'Aptos Display'; styles[s].font.color.rgb = RGBColor(20,80,120)
    styles[s].paragraph_format.keep_with_next = True
styles['Heading 1'].font.size = Pt(17); styles['Heading 1'].font.bold = True
styles['Heading 2'].font.size = Pt(12); styles['Heading 2'].font.bold = True

def shade(cell, fill):
    tcPr = cell._tc.get_or_add_tcPr(); shd = OxmlElement('w:shd'); shd.set(qn('w:fill'), fill); tcPr.append(shd)
def set_cell(cell, text, bold=False, color=None, size=8):
    cell.text = ''
    p = cell.paragraphs[0]; p.paragraph_format.space_after = Pt(0); p.paragraph_format.space_before = Pt(0)
    r=p.add_run(text); r.bold=bold; r.font.name='Aptos'; r.font.size=Pt(size)
    if color: r.font.color.rgb=RGBColor(*color)
    cell.vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER
def table(headers, rows, widths=None):
    t=doc.add_table(rows=1, cols=len(headers)); t.alignment=WD_TABLE_ALIGNMENT.CENTER; t.style='Table Grid'
    for i,h in enumerate(headers): set_cell(t.rows[0].cells[i],h,True,(255,255,255),8); shade(t.rows[0].cells[i],'174A6E')
    for row in rows:
        cells=t.add_row().cells
        for i,val in enumerate(row):
            set_cell(cells[i],str(val),i==0,size=8)
            if len(t.rows)%2==0: shade(cells[i],'F1F6F9')
    for row_index, row in enumerate(t.rows):
        trPr = row._tr.get_or_add_trPr()
        trPr.append(OxmlElement('w:cantSplit'))
        if row_index == 0:
            header = OxmlElement('w:tblHeader'); header.set(qn('w:val'), 'true'); trPr.append(header)
    if widths:
        for row in t.rows:
            for i,w in enumerate(widths): row.cells[i].width=Inches(w)
    doc.add_paragraph().paragraph_format.space_after=Pt(1)
    return t

p=doc.add_paragraph(style='Title'); p.add_run('Báo cáo tiến trình phát triển Space Courier')
title_ppr = p._p.get_or_add_pPr()
for child in list(title_ppr):
    if child.tag == qn('w:pBdr'):
        title_ppr.remove(child)
p=doc.add_paragraph(); p.paragraph_format.space_after=Pt(8)
r=p.add_run('Bản tổng hợp theo project hiện có  |  20/11/2026'); r.font.size=Pt(10); r.font.color.rgb=RGBColor(90,105,116)
doc.add_paragraph('Space Courier là game phiêu lưu không gian thiên về quản lý tàu và vận chuyển hàng hóa. Bản đồ demo hiện mô phỏng một khu vực thiên hà gồm 10 hệ sao, 20 hành tinh và chuyến đi trực tiếp giữa mọi cặp hành tinh nếu đủ food/fuel. Tên riêng, vị trí và thông số bản đồ vẫn là dữ liệu demo; phần thu thập tài nguyên tại hành tinh khai thác chưa được triển khai.', style='Normal')
doc.add_heading('Cách đọc trạng thái', level=1)
table(['Ký hiệu','Ý nghĩa'],[
('✅ Hoàn thành','Đã có triển khai hoặc nội dung chạy được trong project.'),
('🟡 Một phần','Có nền tảng, giao diện placeholder, dữ liệu mẫu hoặc quyết định thiết kế; chưa hoàn tất.'),
('⬜ Chưa làm','Chưa có triển khai/nội dung chốt hoặc được xếp vào giai đoạn sau.')],[1.5,8.8])

doc.add_heading('1. Gameplay và vòng lặp chính', level=1)
table(['Hạng mục','Trạng thái','Đã có','Còn lại / bước tiếp theo'],[
('Chọn điểm đến trực tiếp','✅ Hoàn thành','Bản đồ 10 hệ/20 hành tinh; chọn sao để xem hành tinh và chọn điểm đến bất kỳ.','Thay tên/vị trí demo bằng nội dung duyệt; bổ sung cơ chế thu thập tại Extraction.'),
('Zoom và đánh dấu bản đồ','✅ Hoàn thành','Zoom/pan, sơ đồ hệ sao và sáu sigil neon lưu theo hệ.','Hoàn thiện visual UI và thay nội dung demo sau khi duyệt.'),
('Bay tự động','✅ Hoàn thành','Có 380 chuyến trực tiếp giữa các cặp hành tinh có hướng.','Cân chỉnh thời gian, khoảng cách và nhịp chơi.'),
('Resource drain và preflight','✅ Hoàn thành','Map hiển thị chi phí; không khởi hành khi thiếu food/fuel; event dự trù theo lựa chọn âm lớn nhất.','Chốt loại tài nguyên, mức khởi đầu, giới hạn, refill và tốc độ tiêu hao.'),
('Hồi tài nguyên tại planet','✅ Hoàn thành','Lượng refill cấu hình theo planet, có phân biệt hub/planet trống trong demo.','Chốt tài nguyên hồi, lượng, chi phí và điều kiện.'),
('Resource hết / chết','🟡 Một phần','Food bằng 0 xử lý death.','Chốt quy tắc khi fuel hoặc tài nguyên khác về 0, có dừng tàu hay grace period không.'),
('Travel events hai lựa chọn','✅ Hoàn thành','Có event theo route segment và lựa chọn kèm kết quả.','Bổ sung event pool, tần suất, hậu quả và cách xử lý event trong combat.'),
('Thời lượng chuyến','🟡 Một phần','Có ETA demo từ tọa độ; 8 giây trong cùng hệ, ngoài hệ dùng max(8, khoảng cách × 70).','Cân chỉnh công thức theo nhịp chơi; số liệu hiện tại chưa phải thông số cuối.')],[1.55,1.2,3.5,4.05])

doc.add_heading('2. Tàu, inventory và thiết bị', level=1)
table(['Hạng mục','Trạng thái','Đã có','Còn lại / bước tiếp theo'],[
('Định nghĩa ship/item','✅ Hoàn thành','Data definitions cho ship, item và item instance.','Tạo catalog nội dung chính thức và cân bằng chỉ số.'),
('Inventory grid dùng chung','✅ Hoàn thành','Grid view và mô hình placement cho cargo/equipment.','Hoàn thiện UX kéo thả, trạng thái chọn và thao tác trên UI.'),
('Xoay 90 độ và kiểm tra placement','✅ Hoàn thành','Rotation, placement rules và phản hồi vị trí không hợp lệ.','Chốt tọa độ shape, mirror, từ vựng rule và quy tắc validator.'),
('Cell tags / hiệu ứng vị trí','🟡 Một phần','Có cell tags và placement rules cấu hình.','Chốt heat/power/contact, thứ tự áp dụng effect và ví dụ cân bằng.'),
('Layout tàu mẫu','🟡 Một phần','Có một layout demo 5×4.','Chốt tàu bắt đầu, phòng lõi, ô sử dụng được và layout các tàu khác.'),
('Nâng cấp / tàu mới','⬜ Chưa làm','Thiết kế hướng tới layout vật lý khác nhau.','Tạo tàu, quy tắc mở khóa và tiến trình nâng cấp; không chỉ tăng số ô.')],[1.6,1.2,3.5,4.0])

doc.add_heading('3. Nhiệm vụ, giao hàng và kinh tế', level=1)
table(['Hạng mục','Trạng thái','Đã có','Còn lại / bước tiếp theo'],[
('Catalog mission và delivery','✅ Hoàn thành','Có mission definition và luồng giao parcel demo.','Tạo nhiệm vụ đa dạng, xác nhận planet nhận và điều kiện hoàn thành.'),
('Giao hàng nhiều chuyến','🟡 Một phần','Thiết kế cho phép nhiệm vụ cần nhiều chuyến.','Chốt giữ cargo giữa chuyến, giao một phần, deadline và thất bại.'),
('Mua/bán tại hub','✅ Hoàn thành','Market demo dùng một currency.','Chốt tên tiền, giá mua/bán, stock và quy tắc cập nhật hàng.'),
('Reputation XP','🟡 Một phần','Có giá trị demo cho reward/penalty.','Chốt nguồn tăng giảm, ngưỡng, unlock set và điều kiện bị ban.'),
('Hub MVP','🟡 Một phần','Có các layout/service delivery và market.','Hoàn thiện flow tương tác; repair/refuel/quest/NPC để phase sau.')],[1.6,1.2,3.5,4.0])

doc.add_heading('4. Combat', level=1)
table(['Hạng mục','Trạng thái','Đã có','Còn lại / bước tiếp theo'],[
('Điều kiện giải quyết combat','✅ Hoàn thành','Encounter model hỗ trợ diệt địch, sống sót hết giờ, hoặc thiết bị đặc biệt.','Xác định thứ tự kết thúc encounter và các trường hợp đồng thời.'),
('Combat tiếp tục cùng tuyến bay','✅ Hoàn thành','Encounter có thời lượng, route vẫn tiếp diễn theo thiết kế.','Kiểm tra tương tác với event, resource và death.'),
('Điều khiển twin-stick','🟡 Một phần','Định hướng thiết kế: top-down, di chuyển và aim độc lập.','Hoàn thiện input, cảm giác chuyển động, aim, projectile và UX.'),
('Enemy, spawn và cân bằng damage','⬜ Chưa làm','Có combat definition và encounter demo đơn giản.','Chốt quy tắc trigger, composition, AI, HP/damage, armor/shield và weapon stats.')],[1.65,1.2,3.45,4.0])

doc.add_heading('5. Giao diện và trải nghiệm', level=1)
table(['Hạng mục','Trạng thái','Đã có','Còn lại / bước tiếp theo'],[
('Bộ màn hình MVP','✅ Hoàn thành','Có layout cho ship management, map, orders, events và hub.','Rà soát luồng điều hướng và trạng thái giữa các màn hình.'),
('Art/UI hoàn chỉnh','🟡 Một phần','Có giao diện placeholder để chạy thử.','Thiết kế visual system, icon, typography, feedback, responsive layout.'),
('Thông tin người chơi cần đọc','🟡 Một phần','Runtime giữ trạng thái travel, event, inventory và encounter.','Làm rõ HUD: tài nguyên, ETA, mục tiêu giao hàng, cảnh báo và trạng thái tàu.'),
('Cài đặt/input/accessibility','⬜ Chưa làm','Chưa có quyết định nền tảng và input mapping.','Chốt nền tảng, resolution, điều khiển, âm lượng và tùy chọn hỗ trợ.')],[1.65,1.2,3.45,4.0])

doc.add_heading('6. Cốt truyện và nội dung thế giới', level=1)
table(['Hạng mục','Trạng thái','Ghi nhận hiện tại','Bước tiếp theo'],[
('Tiền đề thế giới','🟡 Một phần','Fantasy đã xác định: người vận chuyển độc lập khám phá không gian.','Chốt bối cảnh, xung đột trung tâm và tông kể chuyện.'),
('Cốt truyện chính','⬜ Chưa làm','Tài liệu hiện tại chưa có lore/cốt truyện được chốt.','Viết premise, tuyến truyện, các mốc chính và kết thúc dự kiến.'),
('NPC và crew','⬜ Chưa làm','Được định hướng là nội dung phase 3.','Thiết kế nhân vật, vai trò trên tàu, quan hệ và hội thoại.'),
('Quest/story events','⬜ Chưa làm','Event MVP hiện là lựa chọn gameplay không gắn nhân vật cụ thể.','Phát triển quest, lựa chọn có hệ quả và sự kiện theo nhân vật.'),
('Khám phá và lore hành tinh','⬜ Chưa làm','Các planet hiện chủ yếu là dữ liệu demo phục vụ route.','Tạo danh tính hành tinh, điểm khám phá, lore và phần thưởng.')],[1.65,1.2,3.45,4.0])

doc.add_heading('7. Lưu game và nền tảng kỹ thuật', level=1)
table(['Hạng mục','Trạng thái','Đã có','Còn lại / bước tiếp theo'],[
('Save/load thủ công','✅ Hoàn thành','Game session hỗ trợ lưu và tải.','Hoàn thiện UX chọn slot và xử lý lỗi dữ liệu.'),
('Autosave 5 phút','✅ Hoàn thành','Đã có chu kỳ autosave 5 phút.','Chốt retention/rotation và thông báo autosave.'),
('Khôi phục khi chết','✅ Hoàn thành','Có khôi phục về save trước.','Chốt chính xác checkpoint, trường hợp chết trong event/combat.'),
('Lưu state đang bay','🟡 Một phần','Có lưu travel/event state.','Xác định rõ state nào lưu giữa chuyến và safe checkpoint.'),
('Godot/platform/data format','🟡 Một phần','Đã có Godot project và dữ liệu runtime kiểu Resource.','Chốt Godot version, platform, viewport, localization và pipeline asset.')],[1.65,1.2,3.45,4.0])

doc.add_heading('8. Tóm tắt dữ liệu demo hiện tại', level=1)
table(['Mảng','Giá trị demo','Lưu ý'],[
('Tàu khởi đầu','5×4 ô; cockpit, engine, energy room; 1 ô heat cao.','Chỉ là cấu hình chạy thử.'),
('Khởi đầu','Launch Port; 40 food, 40 fuel, 20 hull HP, 30 credits.','Thông số chưa cân bằng.'),
('Hệ sao/hành tinh','10 hệ, 20 hành tinh; bốn điểm nền văn minh ở hệ 01, 04, 07, 09; tất cả thuộc địa Sao Hỏa.','Tên hệ, vị trí và phân loại là demo tạm.'),
('Travel trực tiếp','380 chuyến có hướng; ETA dùng khoảng cách trên bản đồ; 8 giây trong cùng hệ.','Không có topology tuyến giới hạn đích; công thức ETA cần cân chỉnh.'),
('Drain/refill','0.1 food/s, 0.2 fuel/s; refill cấu hình theo từng hành tinh.','Giá trị demo, cần playtest và điều chỉnh.'),
('Map markers','Sáu sigil hình học trừu tượng với màu cyan, hồng, vàng, tím, xanh lá và cam.','Người chơi tự gán ý nghĩa; sigil lưu theo hệ.'),
('Cargo/mission','Survey Parcel; mua 18, bán 15; mission reward 12 credits + 1 reputation XP.','Giá và phần thưởng tạm.'),
('Event/combat','Một event hai lựa chọn; một encounter 4 giây trên route demo.','Chưa đại diện cho nội dung cuối.'),
('Equipment','Recycling Unit chiếm 2 ô ngang; giá mua 24, bán 12 credits.','Item ví dụ để thử grid/market.')],[1.45,5.3,4.0])

doc.add_heading('Các hệ sao trong bản đồ demo', level=2)
map_note = doc.add_paragraph('Toàn bộ hệ được ghi nhận là thuộc địa Sao Hỏa. Tên riêng và resource notes dưới đây là dữ liệu demo, chưa phải nội dung canon; bốn điểm nền văn minh nằm ở hệ 01, 04, 07 và 09.', style='Normal')
map_note.paragraph_format.keep_with_next = True
table(['Hệ','Hành tinh và loại','Resource notes'],[
('01 Orison','Launch Port (nền văn minh); Pallas Reach (thuộc địa)','—'),
('02 Veyra','Waystation (thuộc địa); Cobalt Shelf (khai thác)','Cobalt, Nickel'),
('03 Serein','Lumen (thuộc địa); Orrery-3 (khai thác)','Silicates'),
('04 Caldera','Harbor Station (nền văn minh); Redoubt (thuộc địa)','—'),
('05 Morrow','Morrow Haven (thuộc địa); The Shards (khai thác)','Iron, Rare earths'),
('06 Ilyon','Sable (thuộc địa); Vesper Quarry (khai thác)','Titanium'),
('07 Aster','Aster Commons (nền văn minh); Verdant Moon (khai thác)','Bio-gel'),
('08 Nacre','Nacre One (thuộc địa); Deepwell (khai thác)','Helium-3'),
('09 Cinder','Cinderfall (nền văn minh); Ashline (thuộc địa)','—'),
('10 Pelagos','Pelagos Station (thuộc địa); Blue Vault (khai thác)','Water ice')],[1.3,6.2,3.2])

doc.add_heading('9. Sitemap và luồng điều hướng', level=1)
tree = [
'MÀN HÌNH CHÍNH',
'├─ Tiếp tục / Chơi mới / Tải game',
'├─ Cài đặt',
'└─ VÀO GAME',
'   ├─ BẢN ĐỒ KHU VỰC THIÊN HÀ',
'   │  ├─ Chọn 1 trong 10 ngôi sao để xem hệ hành tinh',
'   │  ├─ Đánh dấu sao bằng sigil do người chơi tự gán nghĩa',
'   │  ├─ Xem loại hành tinh và tài nguyên ghi chú',
'   │  └─ Chọn bay thẳng tới bất kỳ hành tinh nào nếu đủ food/fuel',
'   │  └─ HÀNH TRÌNH BAY',
'   │     ├─ HUD: food, fuel, hull, ETA, mục tiêu',
'   │     ├─ Event theo segment → chọn A hoặc B',
'   │     ├─ Combat → diệt địch / sống sót / thiết bị đặc biệt',
'   │     └─ Đến planet',
'   │        ├─ Điểm nền văn minh → HUB',
'   │        │  ├─ Giao hàng',
'   │        │  ├─ Mua hàng',
'   │        │  └─ Bán hàng',
'   │        ├─ Thuộc địa → nhận/giao hàng',
'   │        └─ Hành tinh khai thác → resource notes (thu thập chưa triển khai)',
'   ├─ QUẢN LÝ TÀU',
'   │  ├─ Xem layout và trạng thái tàu',
'   │  └─ Sắp xếp cargo/equipment (khi không bay)',
'   ├─ ĐƠN HÀNG & NHIỆM VỤ → mục tiêu, tiến độ, phần thưởng',
'   ├─ LƯU/TẢI → lưu thủ công, autosave, tải save',
'   └─ THẤT BẠI → chết → khôi phục save trước',
'',
'NHÁNH GIAI ĐOẠN SAU MVP',
'└─ Hub mở rộng: repair, refuel, quests, NPC/crew, upgrades, casino, exploration'
]
p=doc.add_paragraph(); p.paragraph_format.left_indent=Inches(.25); p.paragraph_format.space_after=Pt(6)
r=p.add_run('\n'.join(tree)); r.font.name='Consolas'; r.font.size=Pt(8.5); r.font.color.rgb=RGBColor(33,63,80)

doc.add_heading('10. Thứ tự ưu tiên đề xuất để khép MVP', level=1)
table(['Ưu tiên','Việc cần chốt/làm','Kết quả cần đạt'],[
('P0','Chốt thông số gameplay và quyết định nền tảng còn mở.','Một bộ thông số nhất quán thay cho giá trị demo.'),
('P1','Hoàn thiện gameplay vòng lặp map → bay → event/combat → đến planet → giao dịch/giao hàng.','Có thể chơi trọn một vòng lặp mà không vướng luồng thiếu.'),
('P1','Hoàn thiện UX inventory và ship management.','Người chơi hiểu placement hợp lệ, cargo, thiết bị và trạng thái tàu.'),
('P1','Hoàn thiện save/checkpoint/death restore.','Khôi phục đúng trạng thái theo quy tắc đã chốt.'),
('P2','Cân bằng economy, resource, travel và combat qua playtest.','Một demo MVP có nhịp chơi và độ khó hợp lý.'),
('P3','Sau MVP: NPC/crew, quest/story, exploration, hub services bổ sung.','Mở rộng nội dung theo phase 2–3.')],[1.05,5.25,4.4])

doc.add_paragraph('Nguồn đối chiếu: tài liệu thiết kế, roadmap, implementation status và cấu trúc mã nguồn hiện có trong project Space Courier.', style='Caption')
doc.save(OUT)
print(OUT)
