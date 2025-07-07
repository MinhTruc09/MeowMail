# MEWMAIL PROJECT - COMPLETE DIAGRAMS COLLECTION

## 1. USE CASE DIAGRAM

```mermaid
graph TB
    subgraph "MewMail Email System"
        subgraph "Authentication Management"
            UC1[Login to System]
            UC2[Register Account]
            UC3[Logout from System]
            UC4[Change Password]
            UC5[Reset Password]
        end

        subgraph "Email Management"
            UC6[Send Email]
            UC7[Receive Email]
            UC8[Reply to Email]
            UC9[Forward Email]
            UC10[Delete Email]
            UC11[Mark as Spam]
            UC12[Mark as Read/Unread]
            UC13[Search Emails]
            UC14[View Email Thread]
        end

        subgraph "File Management"
            UC15[Upload Attachment]
            UC16[Download Attachment]
            UC17[View Attachment]
        end

        subgraph "User Management"
            UC18[Update Profile]
            UC19[View Profile]
            UC20[Search Users]
        end

        subgraph "AI Integration"
            UC21[Generate Email Content]
            UC22[AI Email Suggestions]
        end

        subgraph "Group Management"
            UC23[Create Email Group]
            UC24[Manage Group Members]
        end
    end

    User[User]
    Admin[System Administrator]
    AIService[AI Service]
    EmailServer[Email Server]

    User --> UC1
    User --> UC2
    User --> UC6
    User --> UC21
    AIService --> UC21
    EmailServer --> UC6

    style User fill:#e3f2fd
    style Admin fill:#f3e5f5
    style AIService fill:#e8f5e8
    style EmailServer fill:#fff3e0
```

## 5. CLASS DIAGRAM

```mermaid
classDiagram
    class AuthService {
        -String baseUrl
        -SharedPreferences prefs
        +Future~LoginResponse~ login(LoginRequest request)
        +Future~void~ register(RegisterRequest request)
        +Future~String~ refreshTokenIfNeeded(String token)
        +Future~void~ logout()
        +Future~bool~ isLoggedIn()
    }

    class MailService {
        -String baseUrl
        -HTTPClient httpClient
        +Future~List~InboxThread~~ getInbox(String token, int page, int limit)
        +Future~void~ sendMail(String token, String receiver, String subject, String content)
        +Future~List~MailItem~~ getThreadDetail(String token, int threadId)
        +Future~void~ replyMail(String token, int threadId, String content)
        +Future~void~ deleteThreads(String token, List~int~ threadIds)
    }

    class UserService {
        -String baseUrl
        -HTTPClient httpClient
        +Future~UserProfile~ getMyProfile(String token)
        +Future~void~ updateProfile(String token, String fullName, String phone)
        +Future~void~ changePassword(String token, String oldPassword, String newPassword)
    }

    class AiService {
        -String baseUrl
        -HTTPClient httpClient
        +Future~AiGenerateResponse~ generateMail(String token, String prompt)
    }

    class LoginRequest {
        +String email
        +String password
        +LoginRequest(String email, String password)
        +Map~String, dynamic~ toJson()
    }

    class InboxThread {
        +int threadId
        +String subject
        +String lastContent
        +String lastSenderEmail
        +DateTime lastCreatedAt
        +bool read
        +bool spam
        +InboxThread.fromJson(Map~String, dynamic~ json)
    }

    AuthService --> LoginRequest : uses
    MailService --> InboxThread : returns
    AuthService --> HTTPClient : makes requests
    MailService --> HTTPClient : makes requests
```

## 6. DATABASE ERD

```mermaid
erDiagram
    USER {
        int user_id PK
        string email UK
        string password_hash
        string full_name
        string phone
        string avatar_url
        datetime created_at
        datetime updated_at
        boolean is_active
    }

    EMAIL_THREAD {
        int thread_id PK
        string subject
        string title
        datetime created_at
        datetime updated_at
        boolean is_group
        int creator_id FK
    }

    EMAIL_MESSAGE {
        int message_id PK
        int thread_id FK
        int sender_id FK
        string content
        string attachment_url
        datetime created_at
        boolean is_read
        boolean is_deleted
        boolean is_spam
    }

    THREAD_PARTICIPANT {
        int participant_id PK
        int thread_id FK
        int user_id FK
        string participant_type
        datetime joined_at
        boolean is_active
    }

    USER ||--o{ EMAIL_THREAD : creates
    USER ||--o{ EMAIL_MESSAGE : sends
    EMAIL_THREAD ||--o{ EMAIL_MESSAGE : contains
    EMAIL_THREAD ||--o{ THREAD_PARTICIPANT : has
    USER ||--o{ THREAD_PARTICIPANT : participates
```

## 2. AUTHENTICATION FLOWCHART

```mermaid
flowchart TD
    Start([Start Application]) --> CheckToken{Check Local Token}
    
    CheckToken -->|Token Exists| ValidateToken{Validate Token}
    CheckToken -->|No Token| LoginScreen[Display Login Screen]
    
    ValidateToken -->|Valid| HomeScreen[Navigate to Home Screen]
    ValidateToken -->|Invalid/Expired| RefreshToken{Attempt Token Refresh}
    
    RefreshToken -->|Success| SaveNewToken[Save New Access Token]
    RefreshToken -->|Failed| LoginScreen
    
    SaveNewToken --> HomeScreen
    
    LoginScreen --> UserInput[User Enters Credentials]
    UserInput --> ValidateInput{Validate Input Format}
    
    ValidateInput -->|Invalid| DisplayError[Display Validation Error]
    ValidateInput -->|Valid| SendLoginRequest[Send Login Request to Server]
    
    DisplayError --> UserInput
    
    SendLoginRequest --> ServerResponse{Server Response}
    
    ServerResponse -->|200 OK| ProcessSuccess[Process Successful Login]
    ServerResponse -->|401 Unauthorized| DisplayAuthError[Display Authentication Error]
    ServerResponse -->|Network Error| DisplayNetworkError[Display Network Error]
    
    ProcessSuccess --> SaveTokens[Save Access and Refresh Tokens]
    SaveTokens --> SaveUserData[Save User Profile Data]
    SaveUserData --> HomeScreen
    
    DisplayAuthError --> LoginScreen
    DisplayNetworkError --> LoginScreen
    
    style Start fill:#e8f5e8
    style HomeScreen fill:#c8e6c9
    style LoginScreen fill:#fff3e0
    style DisplayAuthError fill:#ffcdd2
    style DisplayNetworkError fill:#ffcdd2
```

## 3. SYSTEM WORKFLOW CHART

```mermaid
flowchart LR
    subgraph "User Interface Layer"
        UI1[Login Screen]
        UI2[Home Screen]
        UI3[Compose Screen]
        UI4[Inbox Screen]
        UI5[Thread Detail Screen]
        UI6[Settings Screen]
    end
    
    subgraph "Business Logic Layer"
        BL1[Authentication Service]
        BL2[Mail Service]
        BL3[User Service]
        BL4[File Service]
        BL5[AI Service]
        BL6[Validation Service]
    end
    
    subgraph "Network Layer"
        NL1[HTTP Client]
        NL2[Token Manager]
        NL3[Request Interceptor]
        NL4[Response Handler]
        NL5[Error Handler]
    end
    
    subgraph "Data Layer"
        DL1[SharedPreferences]
        DL2[Local Cache]
        DL3[Session Manager]
        DL4[Data Models]
    end
    
    subgraph "External Services"
        ES1[Spring Boot API]
        ES2[MySQL Database]
        ES3[OpenAI API]
        ES4[Cloudinary CDN]
        ES5[Firebase Services]
    end
    
    UI1 --> BL1
    UI2 --> BL2
    UI3 --> BL2
    UI3 --> BL5
    
    BL1 --> NL1
    BL2 --> NL1
    BL5 --> NL1
    
    NL1 --> ES1
    NL1 --> ES3
    ES1 --> ES2
    
    style UI1 fill:#e3f2fd
    style UI2 fill:#e3f2fd
    style BL1 fill:#f3e5f5
    style BL2 fill:#f3e5f5
    style NL1 fill:#e8f5e8
    style DL1 fill:#fff3e0
    style ES1 fill:#fce4ec
```

## 4. EMAIL SENDING SEQUENCE DIAGRAM

```mermaid
sequenceDiagram
    participant User as User
    participant UI as Flutter UI
    participant AuthService as Auth Service
    participant MailService as Mail Service
    participant HTTPClient as HTTP Client
    participant SpringAPI as Spring Boot API
    participant Database as MySQL Database
    
    User->>UI: Click Compose Email
    UI->>UI: Display Compose Form
    
    User->>UI: Enter recipient, subject, content
    User->>UI: Click Send Email
    
    UI->>AuthService: Get current token
    AuthService->>AuthService: Validate token expiry
    
    alt Token expired
        AuthService->>HTTPClient: POST /api/auth/Refresh-token
        HTTPClient->>SpringAPI: Refresh token request
        SpringAPI->>Database: Validate refresh token
        Database-->>SpringAPI: Token validation result
        SpringAPI-->>HTTPClient: New access token
        HTTPClient-->>AuthService: Updated token
    end
    
    AuthService-->>UI: Valid token
    UI->>MailService: Send email request
    MailService->>HTTPClient: POST /api/mail/send
    
    HTTPClient->>SpringAPI: Multipart request with email data
    SpringAPI->>SpringAPI: Validate JWT token
    SpringAPI->>SpringAPI: Process email content
    
    SpringAPI->>Database: Insert email record
    Database-->>SpringAPI: Email saved
    
    SpringAPI-->>HTTPClient: Success response
    HTTPClient-->>MailService: Email sent confirmation
    MailService-->>UI: Success callback
    UI->>User: Display "Email sent successfully"
```
