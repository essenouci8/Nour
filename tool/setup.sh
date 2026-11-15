#!/usr/bin/env bash
# يولّد مجلد android ويضبط الأذونات. شغّله مرة واحدة من جذر المشروع:  bash tool/setup.sh
set -euo pipefail

flutter create . --org com.essenouci --project-name nour --platforms android
M=android/app/src/main/AndroidManifest.xml

python3 - "$M" <<'PY'
import sys,re
p=sys.argv[1]; s=open(p,encoding='utf-8').read()
perms=["INTERNET","ACCESS_COARSE_LOCATION","ACCESS_FINE_LOCATION","POST_NOTIFICATIONS",
       "SCHEDULE_EXACT_ALARM","RECEIVE_BOOT_COMPLETED","VIBRATE","WAKE_LOCK"]
add="".join(f'    <uses-permission android:name="android.permission.{x}"/>\n' for x in perms
            if f'android.permission.{x}"' not in s)
s=s.replace("<application",add+"    <application",1)
s=re.sub(r'android:label="[^"]*"','android:label="نور"',s,1)
rec='''        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
            </intent-filter>
        </receiver>
'''
if "ScheduledNotificationReceiver" not in s:
    s=s.replace("</application>",rec+"    </application>",1)
open(p,"w",encoding="utf-8").write(s)
PY

# core library desugaring (مطلوب لـ flutter_local_notifications)
G=android/app/build.gradle
[ -f "$G" ] || G=android/app/build.gradle.kts
python3 - "$G" <<'PY'
import sys,re
p=sys.argv[1]; s=open(p).read()
kts=p.endswith(".kts")
if "isCoreLibraryDesugaringEnabled" not in s and "coreLibraryDesugaringEnabled" not in s:
    flag="isCoreLibraryDesugaringEnabled = true" if kts else "coreLibraryDesugaringEnabled true"
    s=re.sub(r'(compileOptions\s*\{)',r'\1\n        '+flag,s,1)
    dep='coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")' if kts else "coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'"
    if re.search(r'^dependencies\s*\{',s,re.M):
        s=re.sub(r'^(dependencies\s*\{)',r'\1\n    '+dep,s,1,flags=re.M)
    else:
        s+="\ndependencies {\n    "+dep+"\n}\n"
open(p,"w").write(s)
PY

rm -f test/widget_test.dart
flutter pub get
dart run flutter_launcher_icons
echo "تم. شغّل:  flutter run"
