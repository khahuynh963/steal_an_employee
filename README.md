# 💼 STEAL AN EMPLOYEE! (ĂN CẮP MỘT NHÂN VIÊN) - ULTIMATE AUTO HUB V1.0

Script tự động chơi toàn diện cho tựa game **[💸UPD] Ăn cắp một nhân viên / Steal an Employee! (Build a Crew)** trên Roblox. Được tối ưu hóa đặc biệt cho **Delta Executor (Android & PC)**, Codex, Wave, Fluxus với độ mượt 60 FPS, không lag, không văng game.

---

## 🚀 Cách Sử Dụng (Loader Command)

Sao chép lệnh bên dưới và dán vào Executor của bạn (Delta / Codex / Wave / Fluxus):

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/khahuynh963/steal_an_employee/main/loader.lua"))()
```

---

## 🎮 Cơ Chế Trò Chơi (Theo Mô Tả Chính Thức)

> 🏃 **Lén vào các công ty và đánh cắp nhân viên của họ**  
> 😱 **Thoát khỏi con trùm trước khi hắn bắt bạn!**  
> 🎉 **Tiết lộ nhân viên mới của bạn - săn lùng cấp bậc huyền thoại!**  
> 🪑 **Cho nhân viên ngồi tại bàn làm việc để kiếm tiền $/s**  
> 📈 **Nâng cấp bàn làm việc và mở rộng văn phòng của bạn để tăng thu nhập**  
> ⚡ **Mua tốc độ và xe để chạy nhanh hơn**  
> 🌙 **Nhân viên hiếm mới xuất hiện mỗi tối**  
> ⛏️ **Tấn công người chơi khác để đánh cắp nhân viên của họ**  
> 💰 **Thu thập thu nhập ngoại tuyến từ kho/két sắt của bạn**  
> ✨ **Tìm kiếm những nhân viên bí mật, thần thoại và thiêng liêng!**  

---

## 🌟 Tính Năng Tự Động Toàn Diện V1.0

### 🏃 **1. Auto Đánh Cắp Nhân Viên (Auto Steal Employees)**
* **⚡ Auto Steal Max Value ($/s):** Tự động quét toàn bộ bản đồ/các công ty, định vị nhân viên có thu nhập $/s cao nhất hoặc phẩm cấp xịn nhất (Secret, Divine, Mythic, Legendary) và bay tới trộm tức thì (0s hold).
* **🎯 Lọc Độ Hiếm (Rarity Filter):** Tùy chọn chỉ trộm các nhân viên đạt phẩm cấp mong muốn (*All, Rare+, Epic+, Legendary+, Mythic+, Divine/Secret*).
* **🌙 Night Employee Sniper:** Tự động phát hiện chu kỳ ban đêm (Night time) và ưu tiên săn ngay các nhân viên hiếm xuất hiện mỗi tối.
* **🛡️ Bay Lướt An Toàn (Safe Sky Glide):** Bay lướt trên không cách mặt đất 14 studs, né toàn bộ chướng ngại vật và tránh xa tầm mắt của Boss.
* **🪑 Tự Động Mang Về Văn Phòng:** Sau khi đánh cắp thành công, tự động đưa nhân viên về văn phòng của bạn ngay lập tức.

### 🪑 **2. Tự Động Quản Lý Văn Phòng & Bàn Làm Việc (Office & Desks)**
* **🪑 Auto Place Desk:** Tự động phát hiện các bàn làm việc (`Desk` / `Workstation` / `Chair`) còn trống trong văn phòng và đặt nhân viên vào bàn để bắt đầu sinh tiền $/s.
* **📈 Auto Upgrade Desks & Office:** Tự động kích hoạt các nút nâng cấp bàn làm việc để nhân hệ số tiền và mở rộng các tầng văn phòng mới.
* **💰 Auto Collect Vault (Két Sắt Ngoại Tuyến):** Tự động mở két sắt văn phòng để gom sạch tiền tích lũy offline.
* **💵 Auto Collect Cash Drops:** Tự động hút toàn bộ tiền xu, tiền mặt rơi trên sàn văn phòng.

### 😱 **3. Khắc Tinh Con Trùm (Anti-Boss 100% Không Bị Bắt)**
* **🛡️ Anti-Boss Touch:** Cơ chế bảo vệ thông minh, vô hiệu hóa khả năng chạm bắt của Boss.
* **⚠️ Boss Radar & Distance Warning:** Quét vị trí của Boss (Manager, CEO, Guard, Trùm) và cảnh báo khoảng cách nguy hiểm theo thời gian thực.
* **🚀 Tự Động Thoát Hiểm:** Khi Boss tiến vào phạm vi 20m, hệ thống tự động búng người lên cao 15 studs để Boss hoàn toàn bất lực.

### ⛏️ **4. PvP Cướp Nhân Viên (Auto Bonk)**
* **🏏 Auto Bonk Players:** Tự động cầm vũ khí (Gậy, Bat, Club) và tấn công những người chơi khác ở gần đang mang vác nhân viên để cướp nhân viên của họ.

### 👁️ **5. 3D Employee ESP & Cột Sáng Neon**
* **📦 3D Employee ESP:** Hiển thị khung viền, tên nhân viên, chức vụ, phẩm cấp và thu nhập $/s xuyên qua tường.
* **🗼 Cột Sáng Lên Trời (Sky Beacons):** Chiếu cột sáng neon thẳng đứng lên trời cho các nhân viên Secret, Divine, Mythic để dễ dàng quan sát từ xa.
* **⚡ Chế Độ Siêu Mượt 60 FPS (FPS Boost):** Tắt bóng đổ và giảm tải đồ họa, chơi mượt mà trên mọi dòng máy yếu hoặc điện thoại treo nhiều acc.

### 🏃💨 **6. Tốc Độ & Tiện Ích**
* **⚡ Speed Slider (WalkSpeed):** Tùy chỉnh tốc độ di chuyển cực nhanh (60, 100, 150, 200, 250 studs/s).
* **🌀 CFrame Glide:** Lướt siêu tốc CFrame không bị game cản trở.
* **🦘 Infinite Jump:** Nhảy vô hạn trên không trung.
* **👻 Noclip:** Đi xuyên mọi bờ tường công ty.
* **🚪 Pha CFrame Xuyên Cửa (25m):** Lướt xuyên qua các cổng an toàn, chướng ngại vật và cửa checkpoint.
* **🛡️ Anti-AFK 24/7:** Chống disconnect khi treo máy xuyên đêm.
* **📱 Giao diện Cyberpunk Draggable:** Nút thu nhỏ/mở rộng hình chiếc cặp 💼 kéo thả mượt mà trên Mobile Touch và PC Mouse.

### 🏋️ **7. Tự Động Luyện Tập & Cuộc Đua Flappy (+5% Tốc Độ Mỗi Ống)**
* **🎮 Auto Chơi Flappy:** Tự động phát hiện khi giao diện *"Cuộc đua FLAPPY"* xuất hiện lúc bạn luyện tập, tự động nhấp để chơi ("Tap to play").
* **⚡ Flappy God Mode:** Quét vị trí chú chim và các khe hở của ống phía trước, tự động tính toán thời điểm nhấp nhảy chính xác tuyệt đối để bay xuyên qua tâm ống, không bao giờ đâm trúng ống.
* **📈 Tăng Tốc Siêu Tốc (+5%/Ống):** Tích lũy chuỗi né ống bất tận giúp nhận thưởng bonus % tốc độ liên tục không giới hạn.
* **🏃 Auto Treadmill / Training:** Tự động tìm và bước vào các máy chạy bộ/khu vực luyện tập trong game để cày chỉ số tốc độ 24/7.

---

## 📋 Yêu Cầu Cài Đặt
* **Roblox Executor:** Delta Executor (Khuyên dùng cho Mobile & PC), Wave, Codex, Fluxus.
* **Tựa game:** [Steal an Employee! / Ăn cắp một nhân viên trên Roblox](https://www.roblox.com)

---

## ⚠️ Lưu Ý
* Script được xây dựng với mục đích học tập và giải trí.
* Hãy sử dụng cẩn thận và có trách nhiệm.
