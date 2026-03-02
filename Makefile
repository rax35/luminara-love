SOURCE_FILES := $(wildcard game/*)
PROJECT_NAME := Luminara

.PHONY: copy clean launch

launch: copy
	adb shell am start "org.love2d.android/.MainActivity"

copy: $(PROJECT_NAME).love
	adb connect localhost:55555
	adb push $(PROJECT_NAME).love storage/emulated/0/Android/data/org.love2d.android/files/games/

$(PROJECT_NAME).love: $(SOURCE_FILES)
	rm ./$(PROJECT_NAME).love
	(cd game && zip -r ../$(PROJECT_NAME).love .)

clean:
	rm $(PROJECT_NAME).love
