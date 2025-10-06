# Firebase Security Rules

## Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Chats collection - only participants can access
    match /chats/{chatId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participants;
      
      // Messages subcollection
      match /messages/{messageId} {
        allow read, write: if request.auth != null && 
          request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
      }
    }
    
    // Groups collection - only members can access
    match /groups/{groupId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.members;
      
      // Group messages subcollection
      match /messages/{messageId} {
        allow read, write: if request.auth != null && 
          request.auth.uid in get(/databases/$(database)/documents/groups/$(groupId)).data.members;
      }
    }
    
    // Status/Stories collection - based on privacy settings
    match /status/{statusId} {
      allow read: if request.auth != null && 
        (resource.data.privacy == 'public' || 
         request.auth.uid == resource.data.userId ||
         request.auth.uid in resource.data.viewers);
      allow write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // Contacts collection - users can manage their own contacts
    match /contacts/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Call logs - only participants can access
    match /calls/{callId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participants;
    }
    
    // Notifications - users can only access their own
    match /notifications/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Settings - users can only manage their own settings
    match /settings/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Block list - users can only manage their own block list
    match /blocked/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Reports - allow authenticated users to create reports
    match /reports/{reportId} {
      allow create: if request.auth != null;
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.reporterId || 
         request.auth.token.admin == true);
    }
  }
}
```

## Firebase Storage Security Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile pictures - users can manage their own
    match /profile_pictures/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Chat media - only participants can access
    match /chat_media/{chatId}/{allPaths=**} {
      allow read, write: if request.auth != null && 
        request.auth.uid in firestore.get(/databases/(default)/documents/chats/$(chatId)).data.participants;
    }
    
    // Group media - only members can access
    match /group_media/{groupId}/{allPaths=**} {
      allow read, write: if request.auth != null && 
        request.auth.uid in firestore.get(/databases/(default)/documents/groups/$(groupId)).data.members;
    }
    
    // Status media - based on privacy settings
    match /status_media/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Temporary uploads - users can manage their own temp files
    match /temp/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Backup files - users can manage their own backups
    match /backups/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Realtime Database Rules (if used)

```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "presence": {
      "$uid": {
        ".read": "auth != null",
        ".write": "$uid === auth.uid"
      }
    },
    "typing": {
      "$chatId": {
        ".read": "auth != null",
        ".write": "auth != null"
      }
    }
  }
}
```

## Security Best Practices

### 1. Authentication Requirements

- All operations require authenticated users (`request.auth != null`)
- Use Firebase Authentication tokens for user identification
- Implement proper session management and token refresh

### 2. Data Validation

```javascript
// Example validation functions
function isValidUser(user) {
  return user.keys().hasAll(['name', 'email', 'createdAt']) &&
         user.name is string &&
         user.email is string &&
         user.createdAt is timestamp;
}

function isValidMessage(message) {
  return message.keys().hasAll(['senderId', 'content', 'timestamp']) &&
         message.senderId is string &&
         message.content is string &&
         message.timestamp is timestamp &&
         message.content.size() <= 10000; // 10KB limit
}
```

### 3. Rate Limiting

- Implement client-side and server-side rate limiting
- Use Firebase Functions for additional validation
- Monitor for suspicious activity patterns

### 4. Privacy Controls

- Implement granular privacy settings
- Allow users to control who can see their data
- Provide options for data deletion and export

### 5. Content Moderation

- Implement automated content filtering
- Allow users to report inappropriate content
- Maintain audit logs for moderation actions

### 6. Encryption

- Use end-to-end encryption for sensitive messages
- Encrypt file uploads before storing
- Implement key management and rotation

### 7. Monitoring and Logging

- Enable Firebase Security Monitoring
- Set up alerts for unusual access patterns
- Maintain comprehensive audit logs

### 8. Backup and Recovery

- Implement secure backup procedures
- Test data recovery processes regularly
- Ensure backups are encrypted and access-controlled

### 9. Compliance

- Follow GDPR, CCPA, and other privacy regulations
- Implement data retention policies
- Provide user consent management

### 10. Testing

- Regularly test security rules with Firebase emulator
- Perform security audits and penetration testing
- Keep dependencies and Firebase SDK updated
