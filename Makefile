# Don't install any of the OS versions of npm nodejs android-sdk.
# Instead get the Android SDK from https://developer.android.com/studio/install
#  Also need to install stuff from the sdkmanager i Android Studio --
#    cmdline-tools ...
#
# Start emulator:
# /home/larsi/Android/Sdk/emulator/emulator -avd Pixel_2_API_34 &
# Test:
# make copy; ANDROID_HOME=/home/larsi/Android/Sdk cordova emulate android

# To test on phone:
# Go to Goolge Play Console, choose app, testing->internal testing,
# "create new release", upload .aab, finish, get link, use link on phone
# to update.

# Get the Cordova stuff from https://cordova.apache.org/docs/en/latest/guide/cli/

# npm install -g cordova


APK=platforms/android/build/outputs/apk/android-release-unsigned.apk

# To create the initial project, check it out and then run "make create",
# which will create all the Cordova build stuff.
create:
	#cordova create mobile
	#mv mobile/hooks mobile/platforms mobile/plugins .
	#rm -r mobile
	cordova platform add android
	cordova plugin add cordova-plugin-device
	cordova plugin add cordova-plugin-file
	cordova plugin add cordova-plugin-geolocation
	cordova plugin add cordova-plugin-inappbrowser
	cordova plugin add cordova-plugin-network-information
	cordova plugin add cordova-plugin-statusbar
	cordova plugin add cordova-plugin-calendar
	cordova plugin add cordova-plugin-x-socialsharing
	cordova plugin add cordova-plugin-slashscreen
	cordova plugin add cordova-plugin-androidx

release-ios:
	./make-file-list
	sed 's/only screen and (max-width: 600px)/only screen and (max-width: 6000px)/' < www/csid.css > a.css && mv a.css www/csid.css
	cordova build ios --buildConfig build.json --device --release
	cp platforms/ios/build/device/Concerts\ in\ Oslo.ipa ~/Desktop/csid.ipa 

test-ios:
	./make-file-list
	sed 's/only screen and (max-width: 600px)/only screen and (max-width: 6000px)/' < www/csid.css > a.css && mv a.css www/csid.css
	cordova build ios --buildConfig build.json --device
	cp platforms/ios/build/device/Concerts\ in\ Oslo.ipa ~/Desktop/csid.ipa 

copy:
	rsync -av ../csid/csid.js ../csid/pikaday.js ../csid/csid.css ../csid/dark.css ../csid/pixel.png www/
	rsync -av ../csid/cross.png ../csid/home-cross.png www/
	rsync -av --exclude='*.webp' ../csid/logos/thumb www/logos
	./make-file-list
	sed 's/only screen and (max-width: 600px)/only screen and (max-width: 6000px)/' < www/csid.css > a.css && mv a.css www/csid.css

release-android:
	./make-file-list
	rm -f csid.apk
	cp www/config.xml www/oconfig.xml
	sed 's/.CSID--Concerts//' < www/oconfig.xml | egrep -vi 'inappbrowser|geolocation' > www/config.xml
	sed 's/only screen and (max-width: 600px)/only screen and (max-width: 6000px)/' < www/csid.css > a.css && mv a.css www/csid.css
	ANDROID_HOME=/home/larsi/Android/Sdk\
		cordova build android --release --buildConfig build.json
	cp platforms/android/app/build/outputs/bundle/release/app-release.aab \
		unsigned.aab
	jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256\
		-keystore ./keystore/csid.keystore unsigned.aab\
		csid
	rm -f csid.aab
	/home/larsi/Android/Sdk/build-tools/33.0.2/zipalign -v 4 unsigned.aab csid.aab

icon=images/base-icon-1024x1024.png
icons:
	for size in 1024 57 72 152 60 120 76 29 58 87 40 80 50 100 114 144 167; do\
		/opt/local/lib/ImageMagick7/bin/convert -resize "$${size}x$${size}!" $(icon) \
		images/icon-$${size}.png;\
	done

