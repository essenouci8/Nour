import 'app_state.dart';

/// ترجمة النصوص: [عربي، إنجليزي، فرنسي].
/// النصوص الدينية (القرآن والأذكار) تبقى عربية دائمًا.
String t(String key) {
  final v = _s[key];
  if (v == null) return key;
  switch (AppState.instance.lang) {
    case 'en':
      return v[1];
    case 'fr':
      return v[2];
    default:
      return v[0];
  }
}

const _s = <String, List<String>>{
  // التنقل
  'nav_home': ['الرئيسية', 'Home', 'Accueil'],
  'nav_prayers': ['المواقيت', 'Prayers', 'Prières'],
  'nav_quran': ['المصحف', 'Quran', 'Coran'],
  'nav_adhkar': ['الأذكار', 'Adhkar', 'Adhkar'],
  'nav_qibla': ['القبلة', 'Qibla', 'Qibla'],

  // عام
  'back': ['رجوع', 'Back', 'Retour'],
  'retry': ['إعادة المحاولة', 'Retry', 'Réessayer'],
  'loading': ['جارٍ التحميل…', 'Loading…', 'Chargement…'],
  'no_connection': ['تعذّر الاتصال بالإنترنت', 'No internet connection', 'Pas de connexion internet'],
  'no_results': ['لا توجد نتائج', 'No results', 'Aucun résultat'],
  'search': ['بحث', 'Search', 'Rechercher'],
  'copy': ['نسخ', 'Copy', 'Copier'],
  'reset': ['تصفير', 'Reset', 'Réinitialiser'],
  'done': ['تم', 'Done', 'Terminé'],
  'of': ['من', 'of', 'sur'],
  'off': ['إيقاف', 'Off', 'Désactivé'],
  'none': ['بدون', 'None', 'Aucun'],
  'minute': ['دقائق', 'min', 'min'],
  'day': ['اليوم', 'Day', 'Jour'],
  'km': ['كم', 'km', 'km'],
  'pause': ['إيقاف مؤقت', 'Pause', 'Pause'],
  'play': ['تشغيل', 'Play', 'Lecture'],

  // الترحيب والموقع
  'welcome_sub': ['مواقيت الصلاة والقرآن والأذكار،\nبحسب مكانك الآن.', 'Prayer times, Quran and adhkar,\nright where you are.', 'Heures de prière, Coran et adhkar,\nlà où vous êtes.'],
  'privacy_note': ['نحسب المواقيت والقبلة على جهازك، ولا نحتفظ بسجل لموقعك.', 'Prayer times and Qibla are calculated on your device. We keep no location history.', 'Les heures et la Qibla sont calculées sur votre appareil. Aucun historique de position n’est conservé.'],
  'allow_location': ['السماح بالوصول للموقع', 'Allow location access', 'Autoriser la localisation'],
  'choose_city': ['اختيار المدينة يدويًا', 'Choose a city manually', 'Choisir une ville'],
  'search_city': ['ابحث عن مدينة', 'Search for a city', 'Rechercher une ville'],
  'loc_denied': ['تعذّر تحديد الموقع. اسمح بالوصول أو اختر مدينتك يدويًا.', 'Could not get your location. Allow access or choose a city.', 'Position indisponible. Autorisez l’accès ou choisissez une ville.'],
  'my_location': ['موقعي الحالي', 'My location', 'Ma position'],

  // الرئيسية
  'next_prayer': ['الصلاة القادمة', 'Next prayer', 'Prochaine prière'],
  'after': ['بعد', 'in', 'dans'],
  'last_read': ['آخر موضع', 'Last read', 'Dernière lecture'],
  'surah': ['سورة', 'Surah', 'Sourate'],
  'ayah': ['الآية', 'Ayah', 'Verset'],
  'ayahs': ['آية', 'ayahs', 'versets'],
  'juz': ['الجزء', 'Juz', 'Juz'],
  'home_adhkar_sub': ['المسبحة وأذكار اليوم', 'Tasbih and daily adhkar', 'Tasbih et adhkar du jour'],
  'from_north': ['من الشمال', 'from north', 'depuis le nord'],
  'ramadan': ['رمضان', 'Ramadan', 'Ramadan'],
  'ramadan_day': ['اليوم {n} من رمضان', 'Day {n} of Ramadan', 'Jour {n} du Ramadan'],
  'ramadan_in': ['بعد {n} يومًا', 'in {n} days', 'dans {n} jours'],
  'calendar': ['التقويم الهجري', 'Hijri calendar', 'Calendrier hégirien'],
  'calendar_sub': ['الأشهر والمناسبات', 'Months and occasions', 'Mois et occasions'],
  'zakat': ['حاسبة الزكاة', 'Zakat calculator', 'Calculateur de zakat'],
  'zakat_sub': ['زكاة المال وزكاة الفطر', 'Wealth and Fitr zakat', 'Zakat des biens et Fitr'],
  'settings': ['الإعدادات', 'Settings', 'Paramètres'],

  // المواقيت
  'prev_day': ['اليوم السابق', 'Previous day', 'Jour précédent'],
  'next_day': ['اليوم التالي', 'Next day', 'Jour suivant'],
  'done_count': ['أتممت {n} من ٥ صلوات اليوم', 'You prayed {n} of 5 today', 'Vous avez prié {n} sur 5 aujourd’hui'],
  'mark_prayed': ['تحديد صلاة', 'Mark as prayed', 'Marquer comme priée'],

  // المصحف
  'continue_reading': ['متابعة القراءة', 'Continue reading', 'Reprendre la lecture'],
  'khatma_plan': ['خطة الختمة', 'Khatma plan', 'Plan de khatma'],
  'khatma_plan_sub': ['ختمة في {n} يومًا', 'Finish in {n} days', 'Terminer en {n} jours'],
  'bookmarks': ['العلامات المرجعية', 'Bookmarks', 'Signets'],
  'meccan': ['مكية', 'Meccan', 'Mecquoise'],
  'medinan': ['مدنية', 'Medinan', 'Médinoise'],
  'search_quran': ['ابحث في القرآن (كلمة أو أكثر)', 'Search the Quran (Arabic)', 'Rechercher dans le Coran (arabe)'],
  'font_size': ['حجم الخط', 'Font size', 'Taille du texte'],
  'tap_ayah': ['المس آية للتفسير والتشغيل', 'Tap an ayah for tafsir and audio', 'Touchez un verset pour le tafsir et l’audio'],
  'tafsir': ['التفسير الميسر', 'Tafsir (Al-Muyassar)', 'Tafsir (Al-Muyassar)'],
  'play_from_here': ['تشغيل من هنا', 'Play from here', 'Lire d’ici'],
  'add_bookmark': ['حفظ علامة', 'Bookmark', 'Ajouter un signet'],
  'remove_bookmark': ['حذف العلامة', 'Remove bookmark', 'Retirer le signet'],
  'khatma_day': ['اليوم {d} من {n}', 'Day {d} of {n}', 'Jour {d} sur {n}'],
  'pages': ['الصفحات', 'Pages', 'Pages'],

  // الأذكار
  'tasbih': ['المسبحة', 'Tasbih', 'Tasbih'],
  'adhkar_daily': ['الأذكار', 'Adhkar', 'Adhkar'],
  'duas': ['أدعية', 'Duas', 'Invocations'],
  'adhkar_count': ['أذكار', 'adhkar', 'adhkar'],
  'g_morning': ['أذكار الصباح', 'Morning adhkar', 'Adhkar du matin'],
  'g_evening': ['أذكار المساء', 'Evening adhkar', 'Adhkar du soir'],
  'g_sleep': ['أذكار النوم', 'Before sleep', 'Avant de dormir'],
  'g_wake': ['أذكار الاستيقاظ', 'On waking up', 'Au réveil'],
  'g_afterprayer': ['أذكار بعد الصلاة', 'After prayer', 'Après la prière'],
  'total_today': ['المجموع اليوم', 'Total today', 'Total aujourd’hui'],
  'tasbih_done': ['اكتمل · المس للانتقال', 'Complete · tap to continue', 'Terminé · touchez pour continuer'],
  'remaining': ['المتبقي', 'Remaining', 'Restant'],

  // القبلة
  'facing_qibla': ['أنت متجه نحو القبلة', 'You are facing the Qibla', 'Vous faites face à la Qibla'],
  'turn_to_qibla': ['أدر الهاتف حتى تتجه نحو الكعبة', 'Turn until the Kaaba marker is at the top', 'Tournez jusqu’à ce que la Kaaba soit en haut'],
  'compass_unavailable': ['البوصلة غير متاحة في هذا الجهاز', 'Compass not available on this device', 'Boussole indisponible sur cet appareil'],
  'compass_hint': ['اتجاه القبلة محسوب من موقعك. أبعد الهاتف عن المعادن والمغناطيس عند المعايرة.', 'Qibla direction is calculated from your location. Keep the phone away from metal and magnets.', 'La direction est calculée depuis votre position. Éloignez le téléphone des métaux et aimants.'],
  'direction': ['الاتجاه', 'Direction', 'Direction'],
  'distance_kaaba': ['المسافة إلى الكعبة', 'Distance to the Kaaba', 'Distance jusqu’à la Kaaba'],

  // رمضان
  'ramadan_kareem': ['رمضان كريم', 'Ramadan Kareem', 'Ramadan Moubarak'],
  'imsak_in': ['الإمساك بعد', 'Imsak in', 'Imsak dans'],
  'iftar_in': ['الإفطار بعد', 'Iftar in', 'Iftar dans'],
  'taqabbal': ['تقبّل الله صيامكم', 'May Allah accept your fast', 'Qu’Allah accepte votre jeûne'],
  'imsak': ['الإمساك', 'Imsak', 'Imsak'],
  'iftar': ['الإفطار', 'Iftar', 'Iftar'],
  'last_ten': ['دخلت العشر الأواخر من رمضان.', 'The last ten nights of Ramadan have begun.', 'Les dix dernières nuits du Ramadan ont commencé.'],
  'ramadan_not_yet': ['سيظهر العدّ التنازلي للإفطار والإمساك تلقائيًا عند دخول الشهر.', 'The Iftar and Imsak countdown appears automatically when the month begins.', 'Le compte à rebours apparaît automatiquement au début du mois.'],
  'fasting_days': ['أيام الصيام', 'Fasting days', 'Jours de jeûne'],
  'daily_wird': ['ورد اليوم', 'Today’s reading', 'Lecture du jour'],
  'zakat_fitr': ['زكاة الفطر', 'Zakat al-Fitr', 'Zakat al-Fitr'],
  'zakat_fitr_sub': ['احسبها قبل العيد', 'Calculate before Eid', 'À calculer avant l’Aïd'],

  // التقويم
  'prev_month': ['الشهر السابق', 'Previous month', 'Mois précédent'],
  'next_month': ['الشهر التالي', 'Next month', 'Mois suivant'],
  'occasions': ['المناسبات', 'Occasions', 'Occasions'],
  'hijri_note': ['التقويم محسوب حسابيًا وقد يختلف يومًا عن الرؤية الشرعية. يمكنك تعديله من الإعدادات.', 'The calendar is calculated and may differ by a day from moon sighting. Adjust it in Settings.', 'Calendrier calculé, pouvant différer d’un jour de l’observation. Ajustable dans les paramètres.'],
  'occ_newyear': ['رأس السنة الهجرية', 'Islamic New Year', 'Nouvel an hégirien'],
  'occ_ashura': ['يوم عاشوراء', 'Day of Ashura', 'Jour d’Achoura'],
  'occ_ramadan': ['بداية رمضان', 'Start of Ramadan', 'Début du Ramadan'],
  'occ_qadr': ['ليلة 27 من رمضان', '27th night of Ramadan', '27e nuit du Ramadan'],
  'occ_fitr': ['عيد الفطر', 'Eid al-Fitr', 'Aïd al-Fitr'],
  'occ_arafah': ['يوم عرفة', 'Day of Arafah', 'Jour d’Arafat'],
  'occ_adha': ['عيد الأضحى', 'Eid al-Adha', 'Aïd al-Adha'],
  'occ_today': ['يوافق اليوم بحسب التقويم', 'Falls today on the calendar', 'Tombe aujourd’hui selon le calendrier'],

  // الزكاة
  'zakat_mal': ['زكاة المال', 'Zakat on wealth', 'Zakat des biens'],
  'gold_price': ['سعر غرام الذهب (بعملتك)', 'Gold price per gram (your currency)', 'Prix du gramme d’or (votre devise)'],
  'cash_savings': ['النقد والمدخرات', 'Cash and savings', 'Espèces et épargne'],
  'gold_grams': ['الذهب الذي تملكه (غرام)', 'Gold you own (grams)', 'Or possédé (grammes)'],
  'trade_goods': ['عروض التجارة', 'Trade goods', 'Marchandises'],
  'debts_due': ['الديون المستحقة عليك', 'Debts you owe', 'Dettes dues'],
  'nisab': ['النصاب (85 غ ذهب)', 'Nisab (85 g gold)', 'Nisab (85 g d’or)'],
  'net_wealth': ['صافي المال', 'Net wealth', 'Patrimoine net'],
  'zakat_due': ['الزكاة المستحقة (2.5%)', 'Zakat due (2.5%)', 'Zakat due (2,5 %)'],
  'no_zakat': ['لا زكاة (دون النصاب)', 'No zakat (below nisab)', 'Pas de zakat (sous le nisab)'],
  'zakat_note': ['تجب الزكاة بعد مرور حول كامل على بلوغ النصاب. الحاسبة للمساعدة فقط.', 'Zakat is due after a full lunar year above nisab. This calculator is a helper only.', 'La zakat est due après une année lunaire complète au-dessus du nisab. Outil indicatif.'],
  'people_count': ['عدد الأشخاص', 'Number of people', 'Nombre de personnes'],
  'fitr_per_person': ['مقدار الفرد (بعملتك)', 'Amount per person (your currency)', 'Montant par personne (votre devise)'],
  'fitr_total': ['إجمالي زكاة الفطر', 'Total Zakat al-Fitr', 'Total Zakat al-Fitr'],
  'zakat_ask': ['مقدار زكاة الفطر تحدده دار الإفتاء أو الجهة الدينية في بلدك كل عام.', 'The amount is set yearly by your local religious authority.', 'Le montant est fixé chaque année par l’autorité religieuse locale.'],

  // الإعدادات
  'set_general': ['عام', 'General', 'Général'],
  'set_prayer': ['الصلاة والتقويم', 'Prayer and calendar', 'Prière et calendrier'],
  'set_alerts': ['التنبيهات', 'Notifications', 'Notifications'],
  'set_quran': ['القرآن', 'Quran', 'Coran'],
  'language': ['اللغة', 'Language', 'Langue'],
  'appearance': ['المظهر', 'Appearance', 'Apparence'],
  'theme_light': ['فاتح', 'Light', 'Clair'],
  'theme_dark': ['داكن', 'Dark', 'Sombre'],
  'theme_system': ['حسب النظام', 'System', 'Système'],
  'accent_color': ['لون التمييز', 'Accent color', 'Couleur d’accent'],
  'location': ['الموقع', 'Location', 'Position'],
  'use_gps': ['تحديث من GPS', 'Update from GPS', 'Mettre à jour via GPS'],
  'calc_method': ['طريقة الحساب', 'Calculation method', 'Méthode de calcul'],
  'm_algeria': ['الجزائر (18° / 17°)', 'Algeria (18° / 17°)', 'Algérie (18° / 17°)'],
  'm_mwl': ['رابطة العالم الإسلامي', 'Muslim World League', 'Ligue islamique mondiale'],
  'm_egypt': ['الهيئة المصرية', 'Egyptian General Authority', 'Autorité égyptienne'],
  'm_umm': ['أم القرى', 'Umm al-Qura', 'Umm al-Qura'],
  'm_karachi': ['جامعة العلوم الإسلامية كراتشي', 'Karachi', 'Karachi'],
  'hijri_adjust': ['تعديل التاريخ الهجري (أيام)', 'Hijri date adjustment (days)', 'Ajustement de la date hégirienne (jours)'],
  'adhan_alert': ['تنبيه عند الأذان', 'Alert at prayer time', 'Alerte à l’heure de la prière'],
  'pre_reminder': ['تنبيه قبل الوقت', 'Reminder before prayer', 'Rappel avant la prière'],
  'fasting_reminders': ['تذكير بصيام الاثنين والخميس والأيام البيض', 'Remind me to fast Mon/Thu and white days', 'Rappel du jeûne lundi/jeudi et jours blancs'],
  'occasion_alerts': ['تنبيهات المناسبات', 'Occasion alerts', 'Alertes des occasions'],
  'reciter': ['القارئ', 'Reciter', 'Récitateur'],
  'khatma_days': ['مدة الختمة (أيام)', 'Khatma duration (days)', 'Durée de la khatma (jours)'],
  'khatma_reminder': ['تذكير يومي بالورد', 'Daily reading reminder', 'Rappel de lecture quotidien'],
  'reminder_time': ['وقت التذكير', 'Reminder time', 'Heure du rappel'],
  'version': ['الإصدار', 'Version', 'Version'],
  'developed_by': ['تم تطويره بواسطة هشام السنوسي', 'Developed by Hicham Essenouci', 'Développé par Hicham Essenouci'],

  // بطاقة المشاركة
  'share': ['مشاركة', 'Share', 'Partager'],
  'share_card': ['مشاركة كصورة', 'Share as image', 'Partager en image'],
  'share_failed': ['تعذّرت المشاركة', 'Could not share', 'Partage impossible'],
  'style_paper': ['ورقي', 'Paper', 'Papier'],
  'style_green': ['زمردي', 'Emerald', 'Émeraude'],
  'style_night': ['ليلي', 'Night', 'Nuit'],

  // التنبيهات (نصوص الإشعارات)
  'prayer_now': ['حان الآن موعد صلاة {p}', 'It is time for {p}', 'C’est l’heure de {p}'],
  'prayer_soon': ['بعد {m} دقائق تقام صلاة {p}', '{p} in {m} minutes', '{p} dans {m} minutes'],
  'fast_title': ['صيام غدًا', 'Fasting tomorrow', 'Jeûne demain'],
  'fast_white': ['غدًا من الأيام البيض، فنوِ الصيام.', 'Tomorrow is one of the white days.', 'Demain est l’un des jours blancs.'],
  'fast_monthu': ['غدًا الاثنين أو الخميس، فنوِ الصيام.', 'Tomorrow is a Monday or Thursday.', 'Demain est un lundi ou un jeudi.'],
  'khatma_title': ['ورد اليوم', 'Today’s reading', 'Lecture du jour'],
  'khatma_body': ['حان وقت وردك من القرآن.', 'Time for your Quran reading.', 'C’est l’heure de votre lecture du Coran.'],
};
