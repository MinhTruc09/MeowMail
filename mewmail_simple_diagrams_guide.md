# Hướng dẫn sử dụng sơ đồ MewMail - Draw.io Style

## 📋 Danh sách sơ đồ đã tạo

### 1. 👥 Use Case Diagram (Sơ đồ ca sử dụng)
- **Mục đích:** Mô tả các chức năng chính của hệ thống
- **Actors:** Người dùng (👤) và Quản trị viên (👤)
- **Use Cases:** 16 chức năng từ đăng ký đến quản lý email
- **Màu sắc:** 
  - 🔵 Xanh dương: Actors
  - 🟠 Cam: Hệ thống
  - 🟣 Tím: Use cases

### 2. 🔐 Authentication Flowchart (Sơ đồ luồng xác thực)
- **Mục đích:** Mô tả quy trình đăng nhập và đăng ký
- **Bắt đầu:** Kiểm tra trạng thái đăng nhập
- **Luồng chính:** Login → Validate → Generate Token → Dashboard
- **Luồng phụ:** Register → Validate → Create Account → Login
- **Màu sắc:**
  - 🟢 Xanh lá: Bắt đầu/Kết thúc
  - 🔵 Xanh dương: Quy trình
  - 🟠 Cam: Quyết định
  - 🔴 Đỏ: Lỗi

### 3. ✉️ Email Management Workflow (Luồng quản lý email)
- **Mục đích:** Mô tả quy trình sử dụng ứng dụng email
- **Chức năng chính:**
  - 📝 Soạn email (có AI hỗ trợ)
  - 👁️ Đọc email
  - 🔍 Tìm kiếm
  - ⚙️ Cài đặt
- **Tích hợp AI:** Lựa chọn sử dụng AI hoặc viết thủ công

### 4. 🏗️ System Architecture (Kiến trúc hệ thống)
- **Lớp người dùng:** Mobile + Web users
- **Lớp giao diện:** Flutter App + Web App
- **API Gateway:** Rate limiting, Authentication, Load balancing
- **Backend Services:** Auth, Email, AI, File services
- **Database:** MySQL + Redis cache
- **External Services:** OpenAI, Cloudinary, Firebase

### 5. 🗄️ Database ERD (Sơ đồ thực thể quan hệ)
- **7 bảng chính:**
  - 👤 USERS: Thông tin người dùng
  - 🧵 EMAIL_THREADS: Chuỗi email
  - 📄 EMAIL_MESSAGES: Tin nhắn email
  - 👥 THREAD_PARTICIPANTS: Người tham gia
  - 📎 FILE_ATTACHMENTS: Tệp đính kèm
  - 🎫 USER_SESSIONS: Phiên đăng nhập
  - 🤖 AI_CONVERSATIONS: Lịch sử AI

### 6. 🔄 Sequence Diagram (Sơ đồ tuần tự)
- **Quy trình:** Gửi email với AI và file đính kèm
- **Participants:** User → Flutter → API → Services → Database
- **Bước chính:**
  1. Mở màn hình soạn email
  2. Yêu cầu AI tạo nội dung
  3. Tải lên file đính kèm
  4. Gửi email và lưu database

### 7. 📝 Pseudo Code (Mã giả)
- **3 thuật toán chính:**
  - 🔐 Đăng nhập người dùng
  - ✉️ Gửi email
  - 🤖 Tạo email bằng AI
- **Định dạng:** Tiếng Việt, dễ hiểu, có emoji

## 🎨 Đặc điểm thiết kế Draw.io Style

### Màu sắc nhất quán:
- **🔵 Xanh dương (#1976D2):** User, Frontend
- **🟣 Tím (#7B1FA2):** System, Main processes
- **🟠 Cam (#F57C00):** Decisions, API Gateway
- **🟢 Xanh lá (#4CAF50):** Success, Backend
- **🔴 Đỏ (#D32F2F):** Error, Database
- **🟡 Vàng (#689F38):** External services

### Biểu tượng emoji:
- 👤 Người dùng
- 📱 Ứng dụng di động
- 🔐 Bảo mật
- ✉️ Email
- 🤖 AI
- 📁 File
- 🗄️ Database
- ☁️ Cloud services

### Phong cách đơn giản:
- Hình chữ nhật bo góc
- Đường nối rõ ràng
- Text song ngữ (Việt/Anh)
- Nhóm logic theo màu
- Kích thước phù hợp

## 📄 Xuất file PDF

### Cách xuất từ Mermaid:
1. **Online Mermaid Editor:**
   - Truy cập: https://mermaid.live/
   - Copy code từ file .md
   - Paste vào editor
   - Click "Export" → "PDF"

2. **VS Code Extension:**
   - Cài đặt "Mermaid Preview"
   - Mở file .md
   - Right-click → "Export to PDF"

3. **Command Line:**
   ```bash
   npm install -g @mermaid-js/mermaid-cli
   mmdc -i diagram.mmd -o diagram.pdf
   ```

### Cách xuất từ Draw.io:
1. **Import vào Draw.io:**
   - Mở https://app.diagrams.net/
   - File → Import → Paste Mermaid code
   - Chỉnh sửa layout nếu cần
   - File → Export as → PDF

2. **Tùy chỉnh PDF:**
   - Chọn kích thước: A4, Letter
   - Orientation: Portrait/Landscape
   - Quality: High resolution
   - Include: All pages

## 🔧 Tùy chỉnh và sử dụng

### Chỉnh sửa màu sắc:
```css
classDef newStyle fill:#YOUR_COLOR,stroke:#BORDER_COLOR,stroke-width:2px
class NodeName newStyle
```

### Thêm emoji mới:
- 📊 Dashboard
- 🔔 Notifications  
- 🎯 Analytics
- 🛡️ Security
- ⚡ Performance

### Mở rộng sơ đồ:
- Thêm use cases mới
- Cập nhật database schema
- Bổ sung external services
- Chi tiết hóa workflows

## 📚 Tài liệu tham khảo

- **Mermaid Documentation:** https://mermaid-js.github.io/mermaid/
- **Draw.io User Guide:** https://www.diagrams.net/doc/
- **Material Design Icons:** https://fonts.google.com/icons
- **Color Palette Tools:** https://coolors.co/
- **PDF Export Tools:** https://www.pdf24.org/

---
**Lưu ý:** Tất cả sơ đồ được thiết kế theo phong cách đơn giản, dễ hiểu và phù hợp cho báo cáo học thuật tiếng Việt.
