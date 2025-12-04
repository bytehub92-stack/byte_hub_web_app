# Chat Feature Tests

Comprehensive test suite for the chat/messaging feature covering all aspects from models to real-time message handling.

## Test Structure

```
test/features/chat/
├── README.md (this file)
├── helpers/
│   └── test_helpers.dart              # Test constants, builders, and factory
├── fakes/
│   └── fake_chat_remote_datasource.dart  # Fake implementation (no mocks)
├── data/
│   ├── models/
│   │   ├── message_model_test.dart
│   │   └── chat_preview_model_test.dart
│   └── datasources/
│       └── chat_remote_datasource_test.dart
├── presentation/
│   └── bloc/
│       └── chat_bloc_test.dart
└── integration/
    └── chat_integration_test.dart
```

## Prerequisites

Ensure these dependencies are in your `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.0
  dartz: ^0.10.1
```

## Running Tests

### Run all chat tests
```bash
flutter test test/features/chat/
```

### Run specific test files

```bash
# Model tests
flutter test test/features/chat/data/models/message_model_test.dart
flutter test test/features/chat/data/models/chat_preview_model_test.dart

# Data source tests
flutter test test/features/chat/data/datasources/chat_remote_datasource_test.dart

# BLoC tests
flutter test test/features/chat/presentation/bloc/chat_bloc_test.dart

# Integration tests
flutter test test/features/chat/integration/chat_integration_test.dart
```

### Run with coverage

```bash
flutter test --coverage test/features/chat/
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Test Coverage

### ✅ Message Model Tests (`message_model_test.dart`)
- JSON parsing (complete and partial data)
- Message with/without image URL
- Default values for missing fields
- Default timestamp handling
- Read/unread status
- Entity conversion
- `hasImage` getter
- Message ordering by timestamp
- `copyWith` functionality

### ✅ Chat Preview Model Tests (`chat_preview_model_test.dart`)
- JSON parsing for chat previews
- Missing field defaults
- Customer avatar handling
- Unread count parsing
- Online status handling
- `timeAgo` formatting:
  - "Just now" for < 1 minute
  - "Xm ago" for < 1 hour
  - "Xh ago" for < 24 hours
  - "Xd ago" for < 1 week
  - "DD/MM/YYYY" for older
- Preview sorting by time
- Unread count display

### ✅ Data Source Tests (`chat_remote_datasource_test.dart`)

**Core Operations:**
- Get chat previews for merchandiser
- Get messages between two users
- Send text message
- Send image message
- Mark messages as read
- Get unread count

**Business Logic:**
- Messages sorted by creation time
- Filter messages by conversation
- Image upload to storage
- Unique file paths for images
- Notification sending
- Message preview truncation (50 chars)

**Error Handling:**
- Merchandiser not found
- Database errors
- Upload failures
- Graceful error returns (unread count)

### ✅ BLoC Tests (`chat_bloc_test.dart`)

**Events Tested:**
- LoadChatPreviews
- LoadChatMessages (with auto mark-as-read)
- SendMessage
- SendImageMessage
- ChatRoomMessageReceived
- RefreshChatPreviews
- MarkMessagesAsRead

**State Transitions:**
- ChatInitial → ChatPreviewsLoading → ChatPreviewsLoaded
- ChatPreviewsLoaded → ChatMessagesLoading → ChatMessagesLoaded
- ChatMessagesLoaded → (send) → Updated ChatMessagesLoaded
- Error states with proper error messages
- State preservation on errors

**Business Logic in BLoC:**
- Uses merchandiser profile ID as sender
- Marks messages as read when opening chat
- Prevents duplicate messages in real-time
- Handles image sending with loading state
- Navigation between previews and messages
- Real-time message reception

### ✅ Integration Tests (`chat_integration_test.dart`)

**Complete Workflows:**
1. **Full Chat Session:**
   - Load previews
   - Open specific chat
   - Send text messages
   - Verify persistence

2. **Multiple Conversations:**
   - Switch between customers
   - Send to different customers
   - Maintain separate conversations

3. **Image Sending Workflow:**
   - Upload image
   - Verify upload state
   - Verify image URL in message

4. **Unread Messages:**
   - Track unread per customer
   - Mark as read on open
   - Maintain separate counts

5. **Real-time Updates:**
   - Receive new messages
   - Prevent duplicates
   - Auto mark as read

6. **Error Recovery:**
   - Failed message send → retry
   - Failed image upload → retry
   - State restoration

7. **Notifications:**
   - Send on text message
   - Send on image message
   - Include sender name

## Key Features Tested

### Message Types
- ✅ Text messages
- ✅ Image messages with file upload
- ✅ Messages with/without images

### Message Status
- ✅ Read/unread tracking
- ✅ Auto mark as read on chat open
- ✅ Per-customer unread counts

### Real-time Features
- ✅ Message reception simulation
- ✅ Duplicate prevention
- ✅ State updates on receive

### Notifications
- ✅ Sent on every message
- ✅ Include sender name
- ✅ Message preview (truncated at 50 chars)
- ✅ Special indicator for images

### Profile ID Handling
- ✅ Uses profile_id throughout (not user_id)
- ✅ Merchandiser sends with profile_id
- ✅ Customer identified by profile_id
- ✅ Notifications use profile_id

## Test Data Builders

The test helpers provide fluent builders:

```dart
// Create a message
final message = TestMessageBuilder()
    .withId('msg-1')
    .withSenderId(senderId)
    .withReceiverId(receiverId)
    .withMessage('Hello!')
    .withIsRead(true)
    .build();

// Create a chat preview
final preview = TestChatPreviewBuilder()
    .withCustomerProfileId('customer-1')
    .withCustomerName('John')
    .withUnreadCount(5)
    .withIsOnline(true)
    .build();

// Use factory for quick creation
final conversation = ChatTestDataFactory.createConversation();
final previews = ChatTestDataFactory.createChatPreviewList();
```

## Fake Data Source

The `FakeChatRemoteDataSource` provides complete in-memory implementation:

```dart
final fakeDataSource = FakeChatRemoteDataSource();

// Setup test data
fakeDataSource.setupMessages([message1, message2]);
fakeDataSource.setupPreviews([preview1, preview2]);
fakeDataSource.setupMerchandiserProfile(merchId, profileId);

// Verify operations
expect(fakeDataSource.hasUploadedImage('test.jpg'), true);
expect(fakeDataSource.wasNotificationSent(receiverId, senderId), true);
```

## Common Test Patterns

### Testing Message Send
```dart
test('should send message successfully', () async {
  // Setup
  fakeDataSource.setupMessages([]);
  
  // Act
  final result = await dataSource.sendMessage(
    senderId: merchantProfileId,
    receiverId: customerProfileId,
    message: 'Hello!',
  );
  
  // Assert
  expect(result.message, 'Hello!');
  expect(result.isRead, false);
});
```

### Testing BLoC State Transitions
```dart
blocTest<ChatBloc, ChatState>(
  'emits [Loading, Loaded] when successful',
  build: () {
    fakeDataSource.setupPreviews(previews);
    return bloc;
  },
  act: (bloc) => bloc.add(LoadChatPreviews(/*...*/)),
  expect: () => [
    ChatPreviewsLoading(),
    isA<ChatPreviewsLoaded>(),
  ],
);
```

### Testing Real-time Messages
```dart
test('should add received message', () async {
  // Setup active chat
  bloc.add(LoadChatMessages(/*...*/));
  await Future.delayed(Duration(milliseconds: 100));
  
  // Simulate message reception
  final newMessage = /*...*/;
  bloc.add(ChatRoomMessageReceived(message: newMessage));
  await Future.delayed(Duration(milliseconds: 100));
  
  // Verify
  final state = bloc.state as ChatMessagesLoaded;
  expect(state.messages.contains(newMessage), true);
});
```

## Troubleshooting

### Tests failing with profile ID issues
Ensure you're using profile_id consistently:
```dart
// ✅ Correct
senderId: merchandiserProfileId  // This is profile_id

// ❌ Wrong
senderId: merchandiserId  // This is merchandiser table ID
```

### Image upload tests failing
Make sure to provide actual Uint8List data:
```dart
final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
```

### BLoC tests timing out
Add delays between events:
```dart
await Future.delayed(Duration(milliseconds: 100));
```

### Real-time tests not working
Check that you're in the correct state before simulating reception:
```dart
expect(bloc.state, isA<ChatMessagesLoaded>());
```

## CI/CD Integration

Example GitHub Actions workflow:

```yaml
- name: Run Chat Tests
  run: flutter test test/features/chat/ --coverage
  
- name: Check Coverage
  run: |
    lcov --summary coverage/lcov.info
    
- name: Upload Coverage
  uses: codecov/codecov-action@v3
  with:
    files: ./coverage/lcov.info
```

## Best Practices

1. **Always reset fake data source** in tearDown
2. **Use builders** for consistent test data
3. **Test state transitions** not just end states
4. **Add delays** between async operations
5. **Verify side effects** (notifications, uploads)
6. **Test error recovery** not just happy paths
7. **Keep tests independent** - no shared state

## Edge Cases Covered

- ✅ Empty chat previews
- ✅ Empty conversation
- ✅ Messages without images
- ✅ Images without text
- ✅ Very long messages (truncation)
- ✅ Duplicate message reception
- ✅ Multiple simultaneous conversations
- ✅ Network errors
- ✅ Upload failures
- ✅ Missing customer names
- ✅ Null timestamps (defaults to now)

## Next Steps

After all tests pass:
1. ✅ Set up coverage requirements (>90%)
2. ✅ Add to pre-commit hooks
3. ✅ Integrate with CI/CD
4. ✅ Monitor test execution time
5. ✅ Add performance tests if needed

## Questions?

If tests fail or you discover edge cases:
1. Check fake data source setup
2. Verify profile ID usage (not user ID)
3. Ensure proper async handling
4. Add test case for new scenario
5. Update this README with findings
