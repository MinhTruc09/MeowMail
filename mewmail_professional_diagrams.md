# MewMail Professional Diagrams - Black & White

## 1. Workflow Diagram - Quy trình làm việc

```mermaid
flowchart TD
    Start([Bắt đầu]) --> Login{Đã đăng nhập?}
    
    Login -->|Không| AuthForm[Form xác thực]
    Login -->|Có| Dashboard[Trang chủ]
    
    AuthForm --> ValidateAuth{Kiểm tra thông tin}
    ValidateAuth -->|Hợp lệ| Dashboard
    ValidateAuth -->|Không hợp lệ| AuthForm
    
    Dashboard --> SelectAction{Chọn hành động}
    
    SelectAction -->|Soạn email| ComposeEmail[Soạn email mới]
    SelectAction -->|Đọc email| ReadEmail[Đọc email]
    SelectAction -->|Tìm kiếm| SearchEmail[Tìm kiếm email]
    SelectAction -->|Cài đặt| Settings[Cài đặt tài khoản]
    
    ComposeEmail --> UseAI{Sử dụng AI?}
    UseAI -->|Có| AIGenerate[Tạo nội dung AI]
    UseAI -->|Không| ManualWrite[Viết thủ công]
    
    AIGenerate --> ReviewContent[Xem lại nội dung]
    ManualWrite --> ReviewContent
    
    ReviewContent --> AttachFiles{Đính kèm file?}
    AttachFiles -->|Có| SelectFiles[Chọn file]
    AttachFiles -->|Không| SendEmail[Gửi email]
    
    SelectFiles --> SendEmail
    SendEmail --> Success[Gửi thành công]
    Success --> Dashboard
    
    ReadEmail --> EmailAction{Hành động email}
    EmailAction -->|Trả lời| ComposeEmail
    EmailAction -->|Xóa| DeleteEmail[Xóa email]
    EmailAction -->|Spam| MarkSpam[Đánh dấu spam]
    EmailAction -->|Quay lại| Dashboard
    
    DeleteEmail --> Dashboard
    MarkSpam --> Dashboard
    
    SearchEmail --> ShowResults[Hiển thị kết quả]
    ShowResults --> Dashboard
    
    Settings --> UpdateProfile[Cập nhật hồ sơ]
    UpdateProfile --> Dashboard
    
    %% Styling - Black and White Professional
    classDef default fill:#ffffff,stroke:#000000,stroke-width:2px,color:#000000
    classDef startEnd fill:#000000,stroke:#000000,stroke-width:2px,color:#ffffff
    classDef decision fill:#ffffff,stroke:#000000,stroke-width:2px,color:#000000
    classDef process fill:#ffffff,stroke:#000000,stroke-width:1px,color:#000000
    
    class Start,Success startEnd
    class Login,ValidateAuth,SelectAction,UseAI,AttachFiles,EmailAction decision
    class AuthForm,Dashboard,ComposeEmail,ReadEmail,SearchEmail,Settings,AIGenerate,ManualWrite,ReviewContent,SelectFiles,SendEmail,DeleteEmail,MarkSpam,ShowResults,UpdateProfile process
```

## 2. Flowchart - Sơ đồ luồng xác thực

```mermaid
flowchart TD
    A([Khởi động ứng dụng]) --> B{Kiểm tra token}
    
    B -->|Token hợp lệ| C[Vào trang chủ]
    B -->|Token hết hạn| D[Làm mới token]
    B -->|Không có token| E[Màn hình đăng nhập]
    
    D --> F{Refresh thành công?}
    F -->|Có| C
    F -->|Không| E
    
    E --> G{Chọn hành động}
    G -->|Đăng nhập| H[Nhập email/password]
    G -->|Đăng ký| I[Nhập thông tin đăng ký]
    
    H --> J{Xác thực đăng nhập}
    J -->|Thành công| K[Tạo JWT token]
    J -->|Thất bại| L[Hiển thị lỗi]
    L --> H
    
    I --> M{Xác thực đăng ký}
    M -->|Thành công| N[Tạo tài khoản]
    M -->|Thất bại| O[Hiển thị lỗi]
    O --> I
    
    N --> P[Thông báo thành công]
    P --> E
    
    K --> Q[Lưu token]
    Q --> C
    
    C --> R[Tải dữ liệu người dùng]
    R --> S([Sẵn sàng sử dụng])
    
    %% Styling
    classDef default fill:#ffffff,stroke:#000000,stroke-width:2px,color:#000000
    classDef startEnd fill:#000000,stroke:#000000,stroke-width:3px,color:#ffffff
    classDef decision fill:#ffffff,stroke:#000000,stroke-width:2px,color:#000000
    classDef process fill:#ffffff,stroke:#000000,stroke-width:1px,color:#000000
    classDef error fill:#ffffff,stroke:#000000,stroke-width:2px,stroke-dasharray: 5 5,color:#000000
    
    class A,S startEnd
    class B,F,G,J,M decision
    class C,D,E,H,I,K,N,P,Q,R process
    class L,O error
```

## 3. Work Chart - Biểu đồ công việc hệ thống

```mermaid
graph TD
    subgraph "Lớp người dùng"
        U1[Người dùng di động]
        U2[Người dùng web]
    end
    
    subgraph "Lớp giao diện"
        F1[Flutter Mobile App]
        F2[Web Application]
    end
    
    subgraph "Lớp API"
        API[API Gateway]
    end
    
    subgraph "Lớp dịch vụ"
        S1[Authentication Service]
        S2[Email Service]
        S3[AI Service]
        S4[File Service]
    end
    
    subgraph "Lớp dữ liệu"
        D1[(MySQL Database)]
        D2[(Redis Cache)]
    end
    
    subgraph "Dịch vụ ngoài"
        E1[OpenAI API]
        E2[Cloudinary CDN]
        E3[Firebase]
    end
    
    %% Connections
    U1 --> F1
    U2 --> F2
    
    F1 --> API
    F2 --> API
    
    API --> S1
    API --> S2
    API --> S3
    API --> S4
    
    S1 --> D1
    S1 --> D2
    S2 --> D1
    S2 --> D2
    
    S3 --> E1
    S4 --> E2
    S1 --> E3
    S2 --> E3
    
    %% Styling
    classDef default fill:#ffffff,stroke:#000000,stroke-width:2px,color:#000000
    classDef userLayer fill:#ffffff,stroke:#000000,stroke-width:2px,color:#000000
    classDef serviceLayer fill:#ffffff,stroke:#000000,stroke-width:1px,color:#000000
    classDef dataLayer fill:#ffffff,stroke:#000000,stroke-width:2px,stroke-dasharray: 3 3,color:#000000
    
    class U1,U2,F1,F2 userLayer
    class API,S1,S2,S3,S4 serviceLayer
    class D1,D2,E1,E2,E3 dataLayer
```

## 4. PlantUML - Sequence Diagram
```plantuml
@startuml
!theme plain
skinparam backgroundColor white
skinparam sequenceArrowColor black
skinparam sequenceLifeLineBackgroundColor white
skinparam sequenceLifeLineBorderColor black
skinparam sequenceParticipantBackgroundColor white
skinparam sequenceParticipantBorderColor black

title MewMail Email Sending Process

actor User
participant "Flutter App" as App
participant "API Gateway" as API
participant "Email Service" as Email
participant "AI Service" as AI
participant "Database" as DB
participant "Cloudinary" as CDN

User -> App: Open compose email screen
App -> User: Display email form

User -> App: Request AI content generation
App -> API: POST /api/ai/generate
API -> AI: Call OpenAI API
AI -> API: Return generated content
API -> App: AI content response
App -> User: Display AI content

User -> App: Select file attachment
App -> API: POST /api/file/upload
API -> CDN: Upload file to Cloudinary
CDN -> API: Return file URL
API -> App: File URL response

User -> App: Press send email
App -> API: POST /api/mail/send
API -> Email: Process email sending

Email -> DB: Create new thread
DB -> Email: Return thread_id

Email -> DB: Save message
DB -> Email: Confirm save

Email -> DB: Save participants
DB -> Email: Complete

Email -> API: Email sent successfully
API -> App: Success notification
App -> User: Display success message

@enduml
```

## 5. Pseudo Code - Mã giả

### Thuật toán đăng nhập

```
THUẬT TOÁN: ĐĂNG_NHẬP
ĐẦU VÀO: email, mật_khẩu
ĐẦU RA: token hoặc lỗi

BẮT ĐẦU
    // Kiểm tra định dạng email
    NẾU email không hợp lệ THÌ
        TRẢ VỀ "Email không đúng định dạng"

    // Tìm user trong database
    user = tìm_user_theo_email(email)
    NẾU user không tồn tại THÌ
        TRẢ VỀ "Tài khoản không tồn tại"

    // Kiểm tra mật khẩu
    NẾU mật_khẩu không khớp THÌ
        TRẢ VỀ "Mật khẩu sai"

    // Tạo token và lưu session
    token = tạo_jwt_token(user.id)
    lưu_session(user.id, token)

    TRẢ VỀ token
KẾT THÚC
```

### Thuật toán gửi email

```
THUẬT TOÁN: GỬI_EMAIL
ĐẦU VÀO: người_gửi, người_nhận, tiêu_đề, nội_dung, file_đính_kèm
ĐẦU RA: thread_id hoặc lỗi

BẮT ĐẦU
    // Xác thực quyền
    NẾU không có quyền THÌ
        TRẢ VỀ "Không có quyền truy cập"

    // Kiểm tra người nhận
    NẾU người_nhận không tồn tại THÌ
        TRẢ VỀ "Người nhận không hợp lệ"

    // Tạo thread và message
    thread_id = tạo_thread_mới(tiêu_đề)
    message_id = tạo_message(thread_id, nội_dung)

    // Thêm participants
    thêm_participants(thread_id, người_gửi, người_nhận)

    // Upload file đính kèm
    NẾU có file_đính_kèm THÌ
        DUYỆT từng file TRONG file_đính_kèm
            url = upload_file(file)
            lưu_attachment(message_id, url)

    // Gửi thông báo
    gửi_notification(người_nhận, "Email mới")

    TRẢ VỀ thread_id
KẾT THÚC
```

### Thuật toán AI tạo nội dung

```
THUẬT TOÁN: AI_TẠO_NỘI_DUNG
ĐẦU VÀO: user_id, yêu_cầu, ngữ_cảnh
ĐẦU RA: nội_dung_AI hoặc lỗi

BẮT ĐẦU
    // Xác thực user
    NẾU không có quyền THÌ
        TRẢ VỀ "Không có quyền truy cập"

    // Chuẩn bị prompt
    prompt = kết_hợp(ngữ_cảnh, yêu_cầu)

    // Gọi OpenAI API
    THỬ
        phản_hồi = gọi_openai_api(prompt)
    BẮT lỗi
        TRẢ VỀ "Lỗi kết nối AI"

    // Xử lý kết quả
    NẾU phản_hồi rỗng THÌ
        TRẢ VỀ "AI không tạo được nội dung"

    // Lưu lịch sử
    lưu_conversation(user_id, yêu_cầu, phản_hồi)

    TRẢ VỀ phản_hồi
KẾT THÚC
```
```
