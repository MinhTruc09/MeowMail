# PSEUDO CODE - MEWMAIL CORE ALGORITHMS

## 1. AUTHENTICATION ALGORITHM

```pseudocode
ALGORITHM AuthenticateUser
INPUT: email, password
OUTPUT: authenticationResult

BEGIN
    // Input validation
    IF email IS EMPTY OR password IS EMPTY THEN
        RETURN ValidationError("Email and password required")
    END IF
    
    IF NOT isValidEmailFormat(email) THEN
        RETURN ValidationError("Invalid email format")
    END IF
    
    // Create login request
    loginRequest = {
        email: email,
        password: hashPassword(password)
    }
    
    TRY
        // Send HTTP request
        response = HTTPClient.POST("/api/auth/login", loginRequest)
        
        SWITCH response.statusCode
            CASE 200:
                // Extract tokens and user data
                accessToken = response.data.accessToken
                refreshToken = response.data.refreshToken
                userEmail = response.data.email
                
                // Store in local storage
                SharedPreferences.save("access_token", accessToken)
                SharedPreferences.save("refresh_token", refreshToken)
                SharedPreferences.save("user_email", userEmail)
                
                RETURN Success("Authentication successful")
                
            CASE 401:
                RETURN AuthenticationError("Invalid credentials")
                
            CASE 403:
                RETURN AuthenticationError("Account access denied")
                
            CASE 500:
                RETURN ServerError("Internal server error")
                
            DEFAULT:
                RETURN NetworkError("Unexpected response: " + response.statusCode)
        END SWITCH
        
    CATCH NetworkException e
        RETURN NetworkError("Network connection failed: " + e.message)
        
    CATCH Exception e
        RETURN SystemError("Authentication failed: " + e.message)
    END TRY
END

ALGORITHM RefreshAuthToken
INPUT: refreshToken
OUTPUT: tokenRefreshResult

BEGIN
    IF refreshToken IS EMPTY THEN
        RETURN TokenError("Refresh token not available")
    END IF
    
    TRY
        refreshRequest = {
            refreshToken: refreshToken
        }
        
        response = HTTPClient.POST("/api/auth/Refresh-token", refreshRequest)
        
        IF response.statusCode == 200 THEN
            newAccessToken = response.data.accessToken
            SharedPreferences.save("access_token", newAccessToken)
            RETURN Success(newAccessToken)
        ELSE
            // Clear invalid tokens
            SharedPreferences.clear("access_token")
            SharedPreferences.clear("refresh_token")
            RETURN TokenError("Token refresh failed")
        END IF
        
    CATCH Exception e
        RETURN TokenError("Token refresh error: " + e.message)
    END TRY
END
```

## 2. EMAIL MANAGEMENT ALGORITHM

```pseudocode
ALGORITHM SendEmail
INPUT: receiverEmail, subject, content, attachmentPath
OUTPUT: emailSendResult

BEGIN
    // Input validation
    IF receiverEmail IS EMPTY OR subject IS EMPTY OR content IS EMPTY THEN
        RETURN ValidationError("Required fields missing")
    END IF
    
    IF NOT isValidEmailFormat(receiverEmail) THEN
        RETURN ValidationError("Invalid receiver email format")
    END IF
    
    // Get authentication token
    accessToken = getValidToken()
    IF accessToken IS NULL THEN
        RETURN AuthenticationError("Authentication required")
    END IF
    
    TRY
        // Prepare multipart request
        request = createMultipartRequest("POST", "/api/mail/send")
        request.addHeader("Authorization", "Bearer " + accessToken)
        request.addQueryParameter("receiverEmail", receiverEmail)
        request.addQueryParameter("subject", subject)
        request.addQueryParameter("content", content)
        
        // Add file attachment if provided
        IF attachmentPath IS NOT EMPTY THEN
            IF fileExists(attachmentPath) THEN
                request.addFile("file", attachmentPath)
            ELSE
                RETURN FileError("Attachment file not found")
            END IF
        ELSE
            request.addField("file", "")
        END IF
        
        // Send request
        response = HTTPClient.send(request)
        
        SWITCH response.statusCode
            CASE 200:
                RETURN Success("Email sent successfully")
                
            CASE 401, 403:
                // Attempt token refresh
                newToken = RefreshAuthToken(getRefreshToken())
                IF newToken.isSuccess THEN
                    // Retry with new token
                    RETURN SendEmail(receiverEmail, subject, content, attachmentPath)
                ELSE
                    RETURN AuthenticationError("Session expired")
                END IF
                
            CASE 400:
                RETURN ValidationError("Invalid email data")
                
            CASE 500:
                RETURN ServerError("Server error occurred")
                
            DEFAULT:
                RETURN NetworkError("Send failed: " + response.statusCode)
        END SWITCH
        
    CATCH NetworkException e
        RETURN NetworkError("Network error: " + e.message)
        
    CATCH Exception e
        RETURN SystemError("Send error: " + e.message)
    END TRY
END

ALGORITHM GetInboxEmails
INPUT: pageNumber, pageSize
OUTPUT: emailListResult

BEGIN
    // Input validation
    IF pageNumber < 1 OR pageSize < 1 THEN
        RETURN ValidationError("Invalid pagination parameters")
    END IF
    
    // Get authentication token
    accessToken = getValidToken()
    IF accessToken IS NULL THEN
        RETURN AuthenticationError("Authentication required")
    END IF
    
    TRY
        // Build request URL
        url = "/api/mail/inbox?page=" + pageNumber + "&limit=" + pageSize
        
        // Send GET request
        response = HTTPClient.GET(url, {
            "Authorization": "Bearer " + accessToken,
            "Content-Type": "application/json"
        })
        
        SWITCH response.statusCode
            CASE 200:
                IF response.data IS NOT NULL THEN
                    emailList = parseInboxThreadList(response.data)
                    RETURN Success(emailList)
                ELSE
                    RETURN Success(emptyList)
                END IF
                
            CASE 401, 403:
                // Attempt token refresh
                newToken = RefreshAuthToken(getRefreshToken())
                IF newToken.isSuccess THEN
                    // Retry with new token
                    RETURN GetInboxEmails(pageNumber, pageSize)
                ELSE
                    RETURN AuthenticationError("Session expired")
                END IF
                
            DEFAULT:
                RETURN NetworkError("Failed to load inbox: " + response.statusCode)
        END SWITCH
        
    CATCH NetworkException e
        RETURN NetworkError("Network error: " + e.message)
        
    CATCH Exception e
        RETURN SystemError("Inbox load error: " + e.message)
    END TRY
END
```

## 3. AI INTEGRATION ALGORITHM

```pseudocode
ALGORITHM GenerateEmailWithAI
INPUT: userPrompt
OUTPUT: aiGenerationResult

BEGIN
    // Input validation
    IF userPrompt IS EMPTY THEN
        RETURN ValidationError("Prompt cannot be empty")
    END IF
    
    IF length(userPrompt) > 1000 THEN
        RETURN ValidationError("Prompt too long (max 1000 characters)")
    END IF
    
    // Get authentication token
    accessToken = getValidToken()
    IF accessToken IS NULL THEN
        RETURN AuthenticationError("Authentication required")
    END IF
    
    TRY
        // Prepare AI request
        url = "/api/ai/generate-ai?prompt=" + encodeURL(userPrompt)
        
        // Send POST request with timeout
        response = HTTPClient.POST(url, {
            "Authorization": "Bearer " + accessToken,
            "Accept": "*/*"
        }, timeout: 30000)
        
        SWITCH response.statusCode
            CASE 200:
                aiResponse = parseAiGenerateResponse(response.body)
                
                // Validate AI response structure
                IF aiResponse.receiverEmail IS NOT NULL AND
                   aiResponse.subject IS NOT NULL AND
                   aiResponse.content IS NOT NULL THEN
                    RETURN Success(aiResponse)
                ELSE
                    RETURN AIError("Invalid AI response format")
                END IF
                
            CASE 401, 403:
                // Attempt token refresh
                newToken = RefreshAuthToken(getRefreshToken())
                IF newToken.isSuccess THEN
                    // Retry with new token
                    RETURN GenerateEmailWithAI(userPrompt)
                ELSE
                    RETURN AuthenticationError("Session expired")
                END IF
                
            CASE 429:
                RETURN AIError("AI service rate limit exceeded")
                
            CASE 500:
                RETURN AIError("AI service temporarily unavailable")
                
            DEFAULT:
                RETURN AIError("AI generation failed: " + response.statusCode)
        END SWITCH
        
    CATCH TimeoutException e
        RETURN AIError("AI service timeout")
        
    CATCH NetworkException e
        RETURN NetworkError("Network error: " + e.message)
        
    CATCH Exception e
        RETURN AIError("AI generation error: " + e.message)
    END TRY
END
```

## 4. TOKEN MANAGEMENT ALGORITHM

```pseudocode
ALGORITHM getValidToken
OUTPUT: validToken OR NULL

BEGIN
    accessToken = SharedPreferences.get("access_token")
    
    IF accessToken IS EMPTY THEN
        RETURN NULL
    END IF
    
    // Check token expiry (JWT decode)
    IF isTokenExpired(accessToken) THEN
        refreshToken = SharedPreferences.get("refresh_token")
        
        IF refreshToken IS NOT EMPTY THEN
            refreshResult = RefreshAuthToken(refreshToken)
            IF refreshResult.isSuccess THEN
                RETURN refreshResult.data
            ELSE
                RETURN NULL
            END IF
        ELSE
            RETURN NULL
        END IF
    ELSE
        RETURN accessToken
    END IF
END

ALGORITHM isTokenExpired
INPUT: jwtToken
OUTPUT: boolean

BEGIN
    TRY
        // Decode JWT payload
        payload = decodeJWTPayload(jwtToken)
        expiryTime = payload.exp
        currentTime = getCurrentTimestamp()
        
        // Add 5 minute buffer before expiry
        bufferTime = 300 // 5 minutes in seconds
        
        RETURN (currentTime + bufferTime) >= expiryTime
        
    CATCH Exception e
        // If token cannot be decoded, consider it expired
        RETURN TRUE
    END TRY
END
```
