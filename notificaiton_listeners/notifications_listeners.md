
# NotificationActionListener in Flutter

This project demonstrates a custom notification listener implementation in Flutter, specifically for handling Firebase notifications. The listener is designed to:
- Filter notifications based on specified types.
- Execute actions (callbacks) when matching notifications are received.

The code provides a structured way to handle notifications and trigger UI updates in response to them.

---

## Overview

The `NotificationActionListener` class acts as a listener for Firebase notifications, allowing you to:
- Specify notification types to listen for.
- Define custom actions to execute when notifications of those types are received.

This setup is ideal for managing complex notification flows in a Flutter app, especially when multiple notification types need different handling.

---

## Class: `NotificationActionListener`

### Code

```dart
class NotificationActionListener {
  final void Function(Map<String, dynamic> data) onMessage;
  final List<NotificationType> types;
  
  bool conditionCheck(NotificationType type) {
    return types.any((e) => e.index == type.index);
  }

  NotificationActionListener({
    required this.types,
    required this.onMessage,
  });
}
```

### Properties
- **`onMessage`**: A callback function that receives the notification payload (`Map<String, dynamic> data`) when a matching notification is received.
- **`types`**: A list of `NotificationType` values. Only notifications with types in this list will trigger the `onMessage` callback.

### Method
- **`conditionCheck(NotificationType type)`**: Checks if the notification type matches any of the specified types in `types`. Returns `true` if there’s a match.

---

## Firebase Notification Handling

A static list `listeners` is used to store instances of `NotificationActionListener`, allowing the app to manage multiple listeners with different notification criteria.

```dart
static List<NotificationActionListener> listeners = [];
```

### Notification Handling Loop

This loop iterates over each listener and calls the `onMessage` callback if the notification type matches.

```dart
for (var action in listeners) {
  final type = (int.tryParse(message.data["type"].toString()) ?? 0)
      .toNotificationType;
  if (action.conditionCheck(type)) {
    action.onMessage(message.data);
  }
}
```

#### Explanation
1. **`message.data["type"]`**: Retrieves the `type` field from the notification payload and converts it to an integer.
2. **`.toNotificationType`**: Converts the integer to a `NotificationType` enum.
3. **`action.conditionCheck(type)`**: Checks if the notification type matches the listener's `types` list.
4. **`action.onMessage(message.data)`**: Executes the callback if there's a type match.

---

## Usage in UI

In a Flutter widget, you can create an instance of `NotificationActionListener` to respond to specific notification types. Here’s an example setup in the `initState` method:

```dart
late NotificationActionListener notificationActionListener;

@override
void initState() {
  super.initState();
  notificationActionListener = NotificationActionListener(
    onMessage: (data) {
      final id = int.tryParse(data["itemId"].toString()) ?? 0;
      if (id == context.readData<OrderDetailsData>().orderId && mounted) {
        context.readData<OrderDetailsData>().getOrderDetails();
      }
    },
    types: [
      NotificationType.orderAcceptedByProvider,
      NotificationType.orderRejectedByProvider,
      NotificationType.providerOnTheWay,
      NotificationType.theServiceIsBeingImplementedByProvider,
      NotificationType.theServiceIsFinishedByProvider,
      NotificationType.orderCanceledByAdmin,
      NotificationType.orderRejectedByAdmin,
    ],
  );

  FirebaseMessagingHelper.listeners.add(notificationActionListener);
}
```

### Explanation
- **`notificationActionListener`**: Configured with specific `NotificationType` values for order updates.
- **`onMessage`**: The callback function verifies if the `itemId` in the notification matches the current `orderId` in the UI context and, if so, refreshes the order details.
- **`FirebaseMessagingHelper.listeners.add(notificationActionListener)`**: Registers the listener for handling relevant notifications.

---

## Summary

The `NotificationActionListener` setup provides a flexible, organized, and scalable way to handle Firebase notifications in Flutter. It allows you to:
1. Define custom handlers for specific notification types.
2. Filter and manage notifications in a modular way.
3. Trigger UI updates based on backend events.

This approach makes notification handling straightforward and maintainable, ideal for apps requiring dynamic UI updates in response to notifications.

---