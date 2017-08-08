APK=platforms/android/build/outputs/apk/android-release-unsigned.apk

# To create the initial project, check it out and then run "make create",
# which will create all the Cordova build stuff.
create:
	cordova create mobile
	mv mobile/hooks mobile/platforms mobile/plugins .
	rm -r mobile
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

release-android:
	./make-file-list
	rm -f csid.apk
	cp www/config.xml www/oconfig.xml
	sed 's/.CSID--Concerts//' < www/oconfig.xml | egrep -vi 'inappbrowser|geolocation' > www/config.xml
	sed 's/only screen and (max-width: 600px)/only screen and (max-width: 6000px)/' < www/csid.css > a.css && mv a.css www/csid.css
	cordova build android --release
	jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1\
		-keystore ~/src/app-csid/keystore/csid.keystore $(APK)\
		csid
	jarsigner -verify -verbose -certs $(APK)
	zipalign -v 4 $(APK) csid.apk
	mv www/oconfig.xml www/config.xml

copy:
	rsync -av ../csid/csid.js ../csid/csid.css ../csid/pixel.png www/
	rsync -av ../csid/cross.png ../csid/home-cross.png www/
	rsync -av ../csid/logos/larger ../csid/logos/thumb www/logos
	./make-file-list
	sed 's/only screen and (max-width: 600px)/only screen and (max-width: 6000px)/' < www/csid.css > a.css && mv a.css www/csid.css
