import 'package:flutter/material.dart';

class Translations {
  final Locale locale;

  Translations(this.locale);

  static Translations of(BuildContext context) {
    return Localizations.of<Translations>(context, Translations)!;
  }

  static const _localizedValues = {
    'en': {
      'welcome': 'Welcome',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'forgotPassword': 'Forgot Password?',
      'home': 'Home',
      'profile': 'Profile',
      'settings': 'Settings',
      'logout': 'Logout',
      'hotelReceptions': 'Hotel Receptions',
      'room': 'Room',
      'hotelServices': 'Hotel Services',
      'noActiveHotelConnections': 'No active hotel connections',
      'findHotelAndCheckIn': 'Find a hotel and check in to chat with reception',
      'chatWithReception': 'Chat with Reception',
      'checkInToSeeServices': 'Check in to a hotel to see available services',
      'roomService': 'Room Service',
      'housekeeping': 'Housekeeping',
      'information': 'Information',
      'spaWellness': 'Spa & Wellness',
      'restaurant': 'Restaurant',
      'transport': 'Transport',
      'concierge': 'Concierge',
      'laundry': 'Laundry',
      'gym': 'Gym',
      'swimmingPool': 'Swimming Pool',
      'businessCenter': 'Business Center',
      'conferenceRooms': 'Conference Rooms',
      'airportShuttle': 'Airport Shuttle',
      'myRequest': 'My Request',
      'findHotels': 'Find Hotels',
      'logoutConfirm': 'Are you sure you want to logout?',
      'cancel': 'Cancel',
      'serviceRequest': 'Service Request',
      'requestService': 'Request Service',
      'selectService': 'Select Service',
      'noServicesAvailable': 'No services available for this hotel',
      'yourName': 'Your Name',
      'enterYourName': 'Enter your name',
      'requestDetails': 'Request Details',
      'enterRequestDetails': 'Enter any specific details about your request',
      'submitRequest': 'Submit Request',
      'searchHotelHint': 'Search hotel by name or leave empty to see all',
      'searchHotelsButton': 'Search Hotels',
      'searchHotelsOrPress': 'Search for hotels or press Search to see all',
      'noHotelsFound': 'No hotels found',
      'checkInButton': 'Check In',
      'statusPending': 'Pending',
      'statusInProgress': 'In Progress',
      'statusCompleted': 'Completed',
      'statusCancelled': 'Cancelled',
      'errorLoadingRequests': 'Error loading requests',
      'noServiceRequestsFound': 'No service requests found',
      'yourRequestsAppearHere': 'Your requests will appear here',
      'requestedLabel': 'Requested',
      'completedLabel': 'Completed',
      'notesLabel': 'Notes:',
      'requestCancelled': 'Request cancelled',
      'cancelRequestButton': 'Cancel Request',
      'errorTitle': 'Error',
      'okButton': 'OK',
      'checkInRequestSent': 'Check-In Request Sent',
      'checkInRequestSentDesc':
          'Your check-in request has been sent to the hotel reception. Please wait for approval. You will be notified when your request is processed.',
      'checkInTitle': 'Check In',
      'provideBookingDetails':
          'Please provide your booking details to check in',
      'enterBookingInfo': 'Enter Your Booking Information',
      'errorSendingImage': 'Error sending image',
      'selectImageSource': 'Select Image Source',
      'galleryLabel': 'Gallery',
      'cameraLabel': 'Camera',
      'hotelReceptionLabel': 'Hotel Reception',
      'guestLabel': 'Guest',
      'bookingId': 'Booking ID',
      'roomNumber': 'Room Number',
      'fullNameAsOnBooking': 'Full Name (as on booking)',
      'submitCheckInRequest': 'Submit Check-In Request',
      'verifyingBooking': 'Verifying booking...',
      'submittingRequest': 'Submitting request...',
      'errorLoadingChats': 'Error loading chats',
      'noChatsYet': 'No chats yet',
      'startChatting': 'Start chatting with the reception!',
    },
    'ro': {
      'welcome': 'Bine ați venit',
      'login': 'Autentificare',
      'register': 'Înregistrare',
      'email': 'Email',
      'password': 'Parolă',
      'forgotPassword': 'Ai uitat parola?',
      'home': 'Acasă',
      'profile': 'Profil',
      'settings': 'Setări',
      'logout': 'Deconectare',
      'hotelReceptions': 'Recepții Hotel',
      'room': 'Camera',
      'hotelServices': 'Servicii Hotel',
      'noActiveHotelConnections': 'Nicio conexiune activă la hotel',
      'findHotelAndCheckIn':
          'Găsiți un hotel și faceți check-in pentru a discuta cu recepția',
      'chatWithReception': 'Chat cu Recepția',
      'checkInToSeeServices':
          'Faceți check-in la un hotel pentru a vedea serviciile disponibile',
      'roomService': 'Room Service',
      'housekeeping': 'Curățenie',
      'information': 'Informații',
      'spaWellness': 'Spa & Wellness',
      'restaurant': 'Restaurant',
      'transport': 'Transport',
      'concierge': 'Concierge',
      'laundry': 'Spălătorie',
      'gym': 'Sală de fitness',
      'swimmingPool': 'Piscină',
      'businessCenter': 'Centru de afaceri',
      'conferenceRooms': 'Săli de conferință',
      'airportShuttle': 'Transfer aeroport',
      'myRequest': 'Cererea mea',
      'findHotels': 'Caută hoteluri',
      'logoutConfirm': 'Sigur doriți să vă deconectați?',
      'cancel': 'Anulează',
      'serviceRequest': 'Cerere serviciu',
      'requestService': 'Solicită serviciu',
      'selectService': 'Selectează serviciul',
      'noServicesAvailable':
          'Nu există servicii disponibile pentru acest hotel',
      'yourName': 'Numele tău',
      'enterYourName': 'Introduceți numele',
      'requestDetails': 'Detalii cerere',
      'enterRequestDetails': 'Introduceți detalii specifice despre cerere',
      'submitRequest': 'Trimite cererea',
      'searchHotelHint':
          'Caută hotel după nume sau lasă gol pentru a vedea toate',
      'searchHotelsButton': 'Caută hoteluri',
      'searchHotelsOrPress':
          'Caută hoteluri sau apasă Caută pentru a vedea toate',
      'noHotelsFound': 'Nu s-au găsit hoteluri',
      'checkInButton': 'Check-in',
      'statusPending': 'În așteptare',
      'statusInProgress': 'În curs',
      'statusCompleted': 'Finalizat',
      'statusCancelled': 'Anulat',
      'errorLoadingRequests': 'Eroare la încărcarea cererilor',
      'noServiceRequestsFound': 'Nu există cereri de servicii',
      'yourRequestsAppearHere': 'Cererile tale vor apărea aici',
      'requestedLabel': 'Solicitat',
      'completedLabel': 'Finalizat',
      'notesLabel': 'Notițe:',
      'requestCancelled': 'Cerere anulată',
      'cancelRequestButton': 'Anulează cererea',
      'errorTitle': 'Eroare',
      'okButton': 'OK',
      'checkInRequestSent': 'Cerere de check-in trimisă',
      'checkInRequestSentDesc':
          'Cererea dvs. de check-in a fost trimisă la recepția hotelului. Vă rugăm să așteptați aprobarea. Veți fi notificat când cererea va fi procesată.',
      'checkInTitle': 'Check-in',
      'provideBookingDetails':
          'Vă rugăm să furnizați detaliile rezervării pentru check-in',
      'enterBookingInfo': 'Introduceți informațiile despre rezervare',
      'errorSendingImage': 'Eroare la trimiterea imaginii',
      'selectImageSource': 'Selectați sursa imaginii',
      'galleryLabel': 'Galerie',
      'cameraLabel': 'Cameră',
      'hotelReceptionLabel': 'Recepția Hotelului',
      'guestLabel': 'Oaspete',
      'bookingId': 'ID rezervare',
      'roomNumber': 'Număr cameră',
      'fullNameAsOnBooking': 'Nume complet (ca în rezervare)',
      'submitCheckInRequest': 'Trimite cererea de check-in',
      'verifyingBooking': 'Se verifică rezervarea...',
      'submittingRequest': 'Se trimite cererea...',
      'errorLoadingChats': 'Eroare la încărcarea conversațiilor',
      'noChatsYet': 'Nicio conversație încă',
      'startChatting': 'Începeți să conversați cu recepția!',
    },
    'ru': {
      'welcome': 'Добро пожаловать',
      'login': 'Вход',
      'register': 'Регистрация',
      'email': 'Электронная почта',
      'password': 'Пароль',
      'forgotPassword': 'Забыли пароль?',
      'home': 'Главная',
      'profile': 'Профиль',
      'settings': 'Настройки',
      'logout': 'Выход',
      'hotelReceptions': 'Ресепшн отеля',
      'room': 'Комната',
      'hotelServices': 'Сервисы отеля',
      'noActiveHotelConnections': 'Нет активных подключений к отелю',
      'findHotelAndCheckIn':
          'Найдите отель и зарегистрируйтесь, чтобы общаться с ресепшн',
      'chatWithReception': 'Чат с Рецепцией',
      'checkInToSeeServices':
          'Зарегистрируйтесь в отеле, чтобы увидеть доступные сервисы',
      'roomService': 'Обслуживание номеров',
      'housekeeping': 'Уборка',
      'information': 'Информация',
      'spaWellness': 'Спа и велнес',
      'restaurant': 'Ресторан',
      'transport': 'Транспорт',
      'concierge': 'Консьерж',
      'laundry': 'Прачечная',
      'gym': 'Тренажерный зал',
      'swimmingPool': 'Бассейн',
      'businessCenter': 'Бизнес-центр',
      'conferenceRooms': 'Конференц-залы',
      'airportShuttle': 'Трансфер до аэропорта',
      'myRequest': 'Мой запрос',
      'findHotels': 'Найти отели',
      'logoutConfirm': 'Вы уверены, что хотите выйти?',
      'cancel': 'Отмена',
      'serviceRequest': 'Запрос услуги',
      'requestService': 'Запросить услугу',
      'selectService': 'Выбрать услугу',
      'noServicesAvailable': 'Нет доступных услуг для этого отеля',
      'yourName': 'Ваше имя',
      'enterYourName': 'Введите ваше имя',
      'requestDetails': 'Детали запроса',
      'enterRequestDetails': 'Введите детали вашего запроса',
      'submitRequest': 'Отправить запрос',
      'searchHotelHint': 'Поиск отеля по названию или оставьте пустым для всех',
      'searchHotelsButton': 'Найти отели',
      'searchHotelsOrPress':
          'Найдите отели или нажмите Поиск, чтобы увидеть все',
      'noHotelsFound': 'Отели не найдены',
      'checkInButton': 'Заселиться',
      'statusPending': 'В ожидании',
      'statusInProgress': 'В процессе',
      'statusCompleted': 'Завершено',
      'statusCancelled': 'Отменено',
      'errorLoadingRequests': 'Ошибка загрузки запросов',
      'noServiceRequestsFound': 'Нет запросов на обслуживание',
      'yourRequestsAppearHere': 'Ваши запросы появятся здесь',
      'requestedLabel': 'Запрошено',
      'completedLabel': 'Завершено',
      'notesLabel': 'Заметки:',
      'requestCancelled': 'Запрос отменен',
      'cancelRequestButton': 'Отменить запрос',
      'errorTitle': 'Ошибка',
      'okButton': 'ОК',
      'checkInRequestSent': 'Запрос на заселение отправлен',
      'checkInRequestSentDesc':
          'Ваш запрос на заселение отправлен на ресепшн отеля. Пожалуйста, дождитесь одобрения. Вы получите уведомление, когда ваш запрос будет обработан.',
      'checkInTitle': 'Заселение',
      'provideBookingDetails':
          'Пожалуйста, укажите данные бронирования для заселения',
      'enterBookingInfo': 'Введите информацию о бронировании',
      'errorSendingImage': 'Ошибка отправки изображения',
      'selectImageSource': 'Выберите источник изображения',
      'galleryLabel': 'Галерея',
      'cameraLabel': 'Камера',
      'hotelReceptionLabel': 'Рецепция Отеля',
      'guestLabel': 'Гость',
      'bookingId': 'ID бронирования',
      'roomNumber': 'Номер комнаты',
      'fullNameAsOnBooking': 'Полное имя (как в бронировании)',
      'submitCheckInRequest': 'Отправить запрос на заселение',
      'verifyingBooking': 'Проверка бронирования...',
      'submittingRequest': 'Отправка запроса...',
      'errorLoadingChats': 'Ошибка загрузки чатов',
      'noChatsYet': 'Нет чатов',
      'startChatting': 'Начните общение с рецепцией!',
    },
  };

  String get welcome => _localizedValues[locale.languageCode]!['welcome']!;
  String get login => _localizedValues[locale.languageCode]!['login']!;
  String get register => _localizedValues[locale.languageCode]!['register']!;
  String get email => _localizedValues[locale.languageCode]!['email']!;
  String get password => _localizedValues[locale.languageCode]!['password']!;
  String get forgotPassword =>
      _localizedValues[locale.languageCode]!['forgotPassword']!;
  String get home => _localizedValues[locale.languageCode]!['home']!;
  String get profile => _localizedValues[locale.languageCode]!['profile']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
  String get hotelReceptions =>
      _localizedValues[locale.languageCode]!['hotelReceptions']!;
  String get room => _localizedValues[locale.languageCode]!['room']!;
  String get hotelServices =>
      _localizedValues[locale.languageCode]!['hotelServices']!;
  String get noActiveHotelConnections =>
      _localizedValues[locale.languageCode]!['noActiveHotelConnections']!;
  String get findHotelAndCheckIn =>
      _localizedValues[locale.languageCode]!['findHotelAndCheckIn']!;
  String get chatWithReception =>
      _localizedValues[locale.languageCode]!['chatWithReception']!;
  String get checkInToSeeServices =>
      _localizedValues[locale.languageCode]!['checkInToSeeServices']!;
  String get roomService =>
      _localizedValues[locale.languageCode]!['roomService']!;
  String get housekeeping =>
      _localizedValues[locale.languageCode]!['housekeeping']!;
  String get information =>
      _localizedValues[locale.languageCode]!['information']!;
  String get spaWellness =>
      _localizedValues[locale.languageCode]!['spaWellness']!;
  String get restaurant =>
      _localizedValues[locale.languageCode]!['restaurant']!;
  String get transport => _localizedValues[locale.languageCode]!['transport']!;
  String get concierge => _localizedValues[locale.languageCode]!['concierge']!;
  String get laundry => _localizedValues[locale.languageCode]!['laundry']!;
  String get gym => _localizedValues[locale.languageCode]!['gym']!;
  String get swimmingPool =>
      _localizedValues[locale.languageCode]!['swimmingPool']!;
  String get businessCenter =>
      _localizedValues[locale.languageCode]!['businessCenter']!;
  String get conferenceRooms =>
      _localizedValues[locale.languageCode]!['conferenceRooms']!;
  String get airportShuttle =>
      _localizedValues[locale.languageCode]!['airportShuttle']!;
  String get myRequest => _localizedValues[locale.languageCode]!['myRequest']!;
  String get findHotels =>
      _localizedValues[locale.languageCode]!['findHotels']!;
  String get logoutConfirm =>
      _localizedValues[locale.languageCode]!['logoutConfirm']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get serviceRequest =>
      _localizedValues[locale.languageCode]!['serviceRequest']!;
  String get requestService =>
      _localizedValues[locale.languageCode]!['requestService']!;
  String get selectService =>
      _localizedValues[locale.languageCode]!['selectService']!;
  String get noServicesAvailable =>
      _localizedValues[locale.languageCode]!['noServicesAvailable']!;
  String get yourName => _localizedValues[locale.languageCode]!['yourName']!;
  String get enterYourName =>
      _localizedValues[locale.languageCode]!['enterYourName']!;
  String get requestDetails =>
      _localizedValues[locale.languageCode]!['requestDetails']!;
  String get enterRequestDetails =>
      _localizedValues[locale.languageCode]!['enterRequestDetails']!;
  String get submitRequest =>
      _localizedValues[locale.languageCode]!['submitRequest']!;
  String get searchHotelHint =>
      _localizedValues[locale.languageCode]!['searchHotelHint']!;
  String get searchHotelsButton =>
      _localizedValues[locale.languageCode]!['searchHotelsButton']!;
  String get searchHotelsOrPress =>
      _localizedValues[locale.languageCode]!['searchHotelsOrPress']!;
  String get noHotelsFound =>
      _localizedValues[locale.languageCode]!['noHotelsFound']!;
  String get checkInButton =>
      _localizedValues[locale.languageCode]!['checkInButton']!;
  String get statusPending =>
      _localizedValues[locale.languageCode]!['statusPending']!;
  String get statusInProgress =>
      _localizedValues[locale.languageCode]!['statusInProgress']!;
  String get statusCompleted =>
      _localizedValues[locale.languageCode]!['statusCompleted']!;
  String get statusCancelled =>
      _localizedValues[locale.languageCode]!['statusCancelled']!;
  String get errorLoadingRequests =>
      _localizedValues[locale.languageCode]!['errorLoadingRequests']!;
  String get noServiceRequestsFound =>
      _localizedValues[locale.languageCode]!['noServiceRequestsFound']!;
  String get yourRequestsAppearHere =>
      _localizedValues[locale.languageCode]!['yourRequestsAppearHere']!;
  String get requestedLabel =>
      _localizedValues[locale.languageCode]!['requestedLabel']!;
  String get completedLabel =>
      _localizedValues[locale.languageCode]!['completedLabel']!;
  String get notesLabel =>
      _localizedValues[locale.languageCode]!['notesLabel']!;
  String get requestCancelled =>
      _localizedValues[locale.languageCode]!['requestCancelled']!;
  String get cancelRequestButton =>
      _localizedValues[locale.languageCode]!['cancelRequestButton']!;
  String get errorTitle =>
      _localizedValues[locale.languageCode]!['errorTitle']!;
  String get okButton => _localizedValues[locale.languageCode]!['okButton']!;
  String get checkInRequestSent =>
      _localizedValues[locale.languageCode]!['checkInRequestSent']!;
  String get checkInRequestSentDesc =>
      _localizedValues[locale.languageCode]!['checkInRequestSentDesc']!;
  String get checkInTitle =>
      _localizedValues[locale.languageCode]!['checkInTitle']!;
  String get provideBookingDetails =>
      _localizedValues[locale.languageCode]!['provideBookingDetails']!;
  String get enterBookingInfo =>
      _localizedValues[locale.languageCode]!['enterBookingInfo']!;
  String get errorSendingImage =>
      _localizedValues[locale.languageCode]!['errorSendingImage']!;
  String get selectImageSource =>
      _localizedValues[locale.languageCode]!['selectImageSource']!;
  String get galleryLabel =>
      _localizedValues[locale.languageCode]!['galleryLabel']!;
  String get cameraLabel =>
      _localizedValues[locale.languageCode]!['cameraLabel']!;
  String get hotelReceptionLabel =>
      _localizedValues[locale.languageCode]!['hotelReceptionLabel']!;
  String get guestLabel =>
      _localizedValues[locale.languageCode]!['guestLabel']!;
  String get bookingId => _localizedValues[locale.languageCode]!['bookingId']!;
  String get roomNumber =>
      _localizedValues[locale.languageCode]!['roomNumber']!;
  String get fullNameAsOnBooking =>
      _localizedValues[locale.languageCode]!['fullNameAsOnBooking']!;
  String get submitCheckInRequest =>
      _localizedValues[locale.languageCode]!['submitCheckInRequest']!;
  String get verifyingBooking =>
      _localizedValues[locale.languageCode]!['verifyingBooking']!;
  String get submittingRequest =>
      _localizedValues[locale.languageCode]!['submittingRequest']!;
  String? get errorLoadingChats =>
      _localizedValues[locale.languageCode]!['errorLoadingChats'];
  String? get noChatsYet =>
      _localizedValues[locale.languageCode]!['noChatsYet'];
  String? get startChatting =>
      _localizedValues[locale.languageCode]!['startChatting'];
}
