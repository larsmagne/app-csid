APK=platforms/android/build/outputs/apk/android-release-unsigned.apk

# To create the initial project, check it out and then run "make create",
# which will create all the Cordova build stuff.
create:
	#cordova create mobile
	#mv mobile/hooks mobile/platforms mobile/plugins .
	#rm -r mobile
	cordova platform add ios
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
	rsync -av ../csid/csid.js ../csid/csid.css ../csid/pixel.png www/
	rsync -av ../csid/cross.png ../csid/home-cross.png www/
	rsync -av ../csid/logos/larger ../csid/logos/thumb www/logos
	./make-file-list
	sed 's/only screen and (max-width: 600px)/only screen and (max-width: 6000px)/' < www/csid.css > a.css && mv a.css www/csid.css

release-android:
	./make-file-list
	rm -f csid.apk
	cp www/config.xml www/oconfig.xml
	sed 's/.CSID--Concerts//' < www/oconfig.xml | egrep -vi 'inappbrowser|geolocation' > www/config.xml
	sed 's/only screen and (max-width: 600px)/only screen and (max-width: 6000px)/' < www/csid.css > a.css && mv a.css www/csid.css
	JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home\
		PATH=/Users/larsi/Applications/gradle-7.1/bin:${JAVA_HOME}/bin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin\
		cordova build android --release --buildConfig build.json
	cp ./platforms/android/app/build/outputs/apk/release/app-release-unsigned.apk unsigned.apk
	jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256\
		-keystore ./keystore/csid.keystore unsigned.apk\
		csid
	/Users/larsi/Library/Android/sdk/build-tools/30.0.3/zipalign -v 4 unsigned.apk csid.apk

icon=images/base-icon-1024x1024.png
icons:
	for size in 1024 57 72 152 60 120 76 29 58 87 40 80 50 100 114 144 167; do\
		convert -resize "$${size}x$${size}!" $(icon) \
		images/icon$${size}.png;\
	done

