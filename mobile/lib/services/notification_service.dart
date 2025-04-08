class AppNotification {
  final int id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String? actionRoute;
  final Map<String, dynamic>? actionParams;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.actionRoute,
    this.actionParams,
  });
}

enum NotificationType {
  water,
  weather,
  plant,
  soil,
  system,
}

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Mock notifications
  final List<AppNotification> _notifications = [
    AppNotification(
      id: 1,
      title: 'Low Water Level',
      message: 'Reservoir 1 is below 30% capacity. Consider refilling soon.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.water,
      actionRoute: '/reservoir_details',
      actionParams: {'id': 1},
    ),
    AppNotification(
      id: 2,
      title: 'Weather Alert',
      message: 'Heavy rain expected tomorrow. Consider adjusting irrigation schedules.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      type: NotificationType.weather,
      actionRoute: '/weather',
    ),
    AppNotification(
      id: 3,
      title: 'Irrigation Complete',
      message: 'Scheduled irrigation for Corn Field A has been completed.',
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      type: NotificationType.plant,
      actionRoute: '/plant_details',
      actionParams: {'id': 1},
    ),
    AppNotification(
      id: 4,
      title: 'Soil Moisture Alert',
      message: 'South Field soil moisture is below optimal levels. Consider irrigation.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.soil,
      actionRoute: '/soil_monitoring',
      actionParams: {'location': 'South Field'},
    ),
    AppNotification(
      id: 5,
      title: 'System Update',
      message: 'AquaSense has been updated to version 2.0. Check out the new features!',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.system,
    ),
  ];

  // Get all notifications
  Future<List<AppNotification>> getAllNotifications() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return _notifications;
  }

  // Get unread notifications
  Future<List<AppNotification>> getUnreadNotifications() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _notifications.where((notification) => !notification.isRead).toList();
  }

  // Mark notification as read
  Future<void> markAsRead(int id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _notifications.indexWhere((notification) => notification.id == id);
    if (index != -1) {
      final notification = _notifications[index];
      _notifications[index] = AppNotification(
        id: notification.id,
        title: notification.title,
        message: notification.message,
        timestamp: notification.timestamp,
        type: notification.type,
        isRead: true,
        actionRoute: notification.actionRoute,
        actionParams: notification.actionParams,
      );
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    for (int i = 0; i < _notifications.length; i++) {
      final notification = _notifications[i];
      _notifications[i] = AppNotification(
        id: notification.id,
        title: notification.title,
        message: notification.message,
        timestamp: notification.timestamp,
        type: notification.type,
        isRead: true,
        actionRoute: notification.actionRoute,
        actionParams: notification.actionParams,
      );
    }
  }

  // Add a new notification
  Future<AppNotification> addNotification(AppNotification notification) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    _notifications.add(notification);
    return notification;
  }

  // Delete a notification
  Future<bool> deleteNotification(int id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _notifications.indexWhere((notification) => notification.id == id);
    if (index != -1) {
      _notifications.removeAt(index);
      return true;
    }
    return false;
  }

  // Get notification count by type
  Future<Map<NotificationType, int>> getNotificationCountByType() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    final Map<NotificationType, int> counts = {};
    for (final type in NotificationType.values) {
      counts[type] = _notifications.where((n) => n.type == type).length;
    }
    return counts;
  }
}

