APK=platforms/android/build/outputs/apk/android-release-unsigned.apk

release-android:
	rm -f csid.apk
	cp www/config.xml www/oconfig.xml
	sed 's/.CSID--Concerts//' < www/oconfig.xml | grep -vi splash > www/config.xml
	cordova build android --release
	jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1\
		-keystore ~/src/app-csid/keystore/csid.keystore $(APK)\
		csid
	jarsigner -verify -verbose -certs $(APK)
	zipalign -v 4 $(APK) csid.apk
	mv www/oconfig.xml www/config.xml

