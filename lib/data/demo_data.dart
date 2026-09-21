import '../models/app_notification.dart';
import '../models/app_user.dart';
import '../models/emergency_contact.dart';
import '../models/emergency_event.dart';
import '../models/emergency_service.dart';
import '../models/safety_tip.dart';

/// All seed data used by the prototype.
///
/// Every phone number below is a clearly fictional demonstration number so
/// that nobody is called by accident during the presentation.
class DemoData {
  const DemoData._();

  // --------------------------------------------------------------- Account
  static const String demoEmail = 'anisa@example.com';
  static const String demoPassword = 'Secure123';

  static AppUser get demoUser => const AppUser(
    id: 'user-001',
    fullName: 'Anisa Abdi',
    email: demoEmail,
    phone: '+252 61 234 5678',
    bloodGroup: 'O+',
    address: 'Hodan District, Mogadishu',
  );

  // -------------------------------------------------------------- Contacts
  static List<EmergencyContact> get contacts => const <EmergencyContact>[
    EmergencyContact(
      id: 'contact-001',
      name: 'Halima Abdi',
      relationship: 'Mother',
      phone: '+252 61 000 0001',
      isPrimary: true,
    ),
    EmergencyContact(
      id: 'contact-002',
      name: 'Yusuf Abdi',
      relationship: 'Brother',
      phone: '+252 61 000 0002',
    ),
    EmergencyContact(
      id: 'contact-003',
      name: 'Sagal Mohamed',
      relationship: 'Friend',
      phone: '+252 61 000 0003',
    ),
  ];

  // ------------------------------------------------------- Public services
  static List<EmergencyService> get services => const <EmergencyService>[
    EmergencyService(
      id: 'service-police',
      name: 'Police Emergency Line',
      category: EmergencyServiceCategory.police,
      phoneNumber: '+252 61 999 0001',
      description: 'Crime, theft, harassment and immediate danger.',
    ),
    EmergencyService(
      id: 'service-police-station',
      name: 'Nearest Police Station',
      category: EmergencyServiceCategory.police,
      phoneNumber: '+252 61 999 0002',
      description: 'Non-urgent reports and follow-up on a case.',
      availability: '08:00 - 22:00',
    ),
    EmergencyService(
      id: 'service-ambulance',
      name: 'Ambulance Dispatch',
      category: EmergencyServiceCategory.ambulance,
      phoneNumber: '+252 61 999 0011',
      description: 'Medical emergencies, accidents and injuries.',
    ),
    EmergencyService(
      id: 'service-hospital',
      name: 'City Hospital Emergency',
      category: EmergencyServiceCategory.ambulance,
      phoneNumber: '+252 61 999 0012',
      description: 'Direct line to the hospital emergency department.',
    ),
    EmergencyService(
      id: 'service-fire',
      name: 'Fire & Rescue Service',
      category: EmergencyServiceCategory.fire,
      phoneNumber: '+252 61 999 0021',
      description: 'Fire, gas leaks, rescue and building collapse.',
    ),
    EmergencyService(
      id: 'service-hotline',
      name: 'National Emergency Hotline',
      category: EmergencyServiceCategory.hotline,
      phoneNumber: '+252 61 999 0031',
      description: 'One number that routes you to the right service.',
    ),
    EmergencyService(
      id: 'service-support',
      name: 'Safety Support Line',
      category: EmergencyServiceCategory.hotline,
      phoneNumber: '+252 61 999 0032',
      description: 'Confidential advice and counselling support.',
    ),
  ];

  // ----------------------------------------------------------- Safety tips
  static List<SafetyTip> get safetyTips => const <SafetyTip>[
    // Personal
    SafetyTip(
      id: 'tip-p1',
      category: SafetyTipCategory.personal,
      title: 'Stay aware of your surroundings',
      body:
          'Keep one earphone out and your phone in your pocket when walking '
          'in a busy or unfamiliar area. Noticing a problem early gives you '
          'the time you need to move away from it.',
    ),
    SafetyTip(
      id: 'tip-p2',
      category: SafetyTipCategory.personal,
      title: 'Trust your instincts',
      body:
          'If a person or place feels wrong, leave. Walk into a shop, a '
          'restaurant or any building with people inside and call someone '
          'you trust before continuing your journey.',
    ),
    SafetyTip(
      id: 'tip-p3',
      category: SafetyTipCategory.personal,
      title: 'Keep your phone charged',
      body:
          'A phone below 20% is a safety risk. Carry a power bank and keep '
          'battery-saving mode on when you expect a long day out.',
    ),
    // Travel
    SafetyTip(
      id: 'tip-t1',
      category: SafetyTipCategory.travel,
      title: 'Share your trip before you leave',
      body:
          'Tell a trusted contact where you are going, which route you are '
          'taking and when you expect to arrive. Start location sharing in '
          'SecureGuard for the whole journey.',
    ),
    SafetyTip(
      id: 'tip-t2',
      category: SafetyTipCategory.travel,
      title: 'Verify the vehicle before you enter',
      body:
          'Check the plate number, the driver and the route on the map '
          'before getting in. Sit where you can reach the door and keep '
          'your bag with you.',
    ),
    SafetyTip(
      id: 'tip-t3',
      category: SafetyTipCategory.travel,
      title: 'Keep valuables out of sight',
      body:
          'Carry only what you need. Keep a small amount of cash separate '
          'from your wallet so you are never left with nothing.',
    ),
    // Night
    SafetyTip(
      id: 'tip-n1',
      category: SafetyTipCategory.night,
      title: 'Choose light over distance',
      body:
          'A longer route along a lit main road is safer than a short cut '
          'through a dark or empty street. Walk facing oncoming traffic so '
          'no vehicle can follow you unseen.',
    ),
    SafetyTip(
      id: 'tip-n2',
      category: SafetyTipCategory.night,
      title: 'Do not walk alone if you can avoid it',
      body:
          'Arrange to travel with a classmate or colleague. If you must '
          'walk alone, stay on the phone with a trusted contact until you '
          'reach your door.',
    ),
    SafetyTip(
      id: 'tip-n3',
      category: SafetyTipCategory.night,
      title: 'Keep the SOS button reachable',
      body:
          'Open SecureGuard before you start walking so the SOS button is '
          'one tap away, and practise the press-and-hold gesture so it '
          'feels automatic.',
    ),
    // Online
    SafetyTip(
      id: 'tip-o1',
      category: SafetyTipCategory.online,
      title: 'Do not post your live location',
      body:
          'Posting where you are in real time tells strangers where to find '
          'you. Share photos of a place after you have left it.',
    ),
    SafetyTip(
      id: 'tip-o2',
      category: SafetyTipCategory.online,
      title: 'Use a strong, unique password',
      body:
          'Use at least 12 characters with letters, numbers and symbols, '
          'and never reuse the password of your email account anywhere '
          'else. Turn on two-step verification where it is offered.',
    ),
    SafetyTip(
      id: 'tip-o3',
      category: SafetyTipCategory.online,
      title: 'Treat unexpected links with suspicion',
      body:
          'Messages that create urgency - a prize, a fine, a blocked '
          'account - are the most common way accounts are stolen. Open the '
          'service yourself instead of tapping the link.',
    ),
    // Preparedness
    SafetyTip(
      id: 'tip-e1',
      category: SafetyTipCategory.preparedness,
      title: 'Keep your emergency contacts current',
      body:
          'Review your trusted contacts every few months. A number that no '
          'longer works is the same as having no contact at all.',
    ),
    SafetyTip(
      id: 'tip-e2',
      category: SafetyTipCategory.preparedness,
      title: 'Learn basic first aid',
      body:
          'Knowing how to stop bleeding, treat a burn and place someone in '
          'the recovery position can save a life in the minutes before an '
          'ambulance arrives.',
    ),
    SafetyTip(
      id: 'tip-e3',
      category: SafetyTipCategory.preparedness,
      title: 'Agree on a code word',
      body:
          'Choose a harmless word with your family that means "come and get '
          'me now". It lets you ask for help even when someone is listening.',
    ),
  ];

  // --------------------------------------------------------------- History
  /// History records are generated relative to "now" so the demo never shows
  /// dates that look stale during the presentation.
  static List<EmergencyEvent> history({DateTime? now}) {
    final DateTime reference = now ?? DateTime.now();
    return <EmergencyEvent>[
      EmergencyEvent(
        id: 'event-001',
        type: EmergencyEventType.sosAlert,
        startedAt: reference.subtract(const Duration(days: 1, hours: 3)),
        endedAt: reference.subtract(
          const Duration(days: 1, hours: 2, minutes: 46),
        ),
        locationLabel: 'Maka Al Mukarama Road, Mogadishu',
        latitude: 2.043700,
        longitude: 45.322100,
        status: EmergencyEventStatus.resolved,
        notifiedContactNames: <String>['Halima Abdi', 'Yusuf Abdi'],
        locationShared: true,
        note: 'Felt followed while walking home. Family arrived and helped.',
      ),
      EmergencyEvent(
        id: 'event-002',
        type: EmergencyEventType.locationShare,
        startedAt: reference.subtract(const Duration(days: 3, hours: 6)),
        endedAt: reference.subtract(const Duration(days: 3, hours: 5)),
        locationLabel: 'University Campus, Mogadishu',
        latitude: 2.046100,
        longitude: 45.318200,
        status: EmergencyEventStatus.resolved,
        notifiedContactNames: <String>['Sagal Mohamed'],
        locationShared: true,
        note: 'Shared live location while travelling home after evening class.',
      ),
      EmergencyEvent(
        id: 'event-003',
        type: EmergencyEventType.sosAlert,
        startedAt: reference.subtract(const Duration(days: 6, hours: 9)),
        endedAt: reference.subtract(
          const Duration(days: 6, hours: 8, minutes: 58),
        ),
        locationLabel: 'Bakara Market, Mogadishu',
        latitude: 2.039800,
        longitude: 45.310400,
        status: EmergencyEventStatus.cancelled,
        notifiedContactNames: <String>[],
        locationShared: false,
        note:
            'Alert cancelled during the countdown - button pressed by mistake.',
      ),
      EmergencyEvent(
        id: 'event-004',
        type: EmergencyEventType.serviceCall,
        startedAt: reference.subtract(const Duration(days: 11, hours: 2)),
        endedAt: reference.subtract(
          const Duration(days: 11, hours: 1, minutes: 52),
        ),
        locationLabel: 'Hodan District, Mogadishu',
        latitude: 2.041900,
        longitude: 45.316700,
        status: EmergencyEventStatus.resolved,
        notifiedContactNames: <String>['Halima Abdi'],
        locationShared: true,
        note: 'Called the ambulance dispatch line for a neighbour.',
      ),
      EmergencyEvent(
        id: 'event-005',
        type: EmergencyEventType.safetyCheck,
        startedAt: reference.subtract(const Duration(days: 14, hours: 5)),
        endedAt: reference.subtract(const Duration(days: 14, hours: 5)),
        locationLabel: 'Home, Hodan District',
        latitude: 2.042500,
        longitude: 45.315300,
        status: EmergencyEventStatus.resolved,
        notifiedContactNames: <String>['Halima Abdi', 'Sagal Mohamed'],
        note: 'Confirmed safe arrival at home.',
      ),
    ];
  }

  // --------------------------------------------------------- Notifications
  static List<AppNotification> notifications({DateTime? now}) {
    final DateTime reference = now ?? DateTime.now();
    return <AppNotification>[
      AppNotification(
        id: 'notif-001',
        type: NotificationType.reminder,
        title: 'Weekly safety reminder',
        message:
            'Review your trusted contacts and make sure every number is still '
            'correct.',
        createdAt: reference.subtract(const Duration(hours: 5)),
      ),
      AppNotification(
        id: 'notif-002',
        type: NotificationType.sos,
        title: 'SOS alert resolved',
        message:
            'Your emergency from yesterday was marked as resolved. 2 contacts '
            'were notified.',
        createdAt: reference.subtract(const Duration(days: 1, hours: 2)),
      ),
      AppNotification(
        id: 'notif-003',
        type: NotificationType.location,
        title: 'Location sharing stopped',
        message: 'You stopped sharing your live location with Sagal Mohamed.',
        createdAt: reference.subtract(const Duration(days: 3, hours: 5)),
        isRead: true,
      ),
      AppNotification(
        id: 'notif-004',
        type: NotificationType.contact,
        title: 'Trusted contact added',
        message: 'Sagal Mohamed was added to your trusted contacts.',
        createdAt: reference.subtract(const Duration(days: 8)),
        isRead: true,
      ),
      AppNotification(
        id: 'notif-005',
        type: NotificationType.system,
        title: 'Welcome to SecureGuard',
        message:
            'Your account is ready. Add your trusted contacts to activate full '
            'emergency protection.',
        createdAt: reference.subtract(const Duration(days: 12)),
        isRead: true,
      ),
    ];
  }
}
