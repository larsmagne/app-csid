APK=platforms/android/build/outputs/apk/android-release-unsigned.apk

release-android:
	./make-file-list
	rm -f csid.apk
	cp www/config.xml www/oconfig.xml
	sed 's/.CSID--Concerts//' < www/oconfig.xml | egrep -vi 'splash|inappbrowser|geolocation' > www/config.xml
	sed 's/only screen and (max-width: 600px)/only screen and (max-width: 6000px)/' < www/csid.css > a.css && mv a.css www/csid.css
	cordova build android --release
	jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1\
		-keystore ~/src/app-csid/keystore/csid.keystore $(APK)\
		csid
	jarsigner -verify -verbose -certs $(APK)
	zipalign -v 4 $(APK) csid.apk
	mv www/oconfig.xml www/config.xml

