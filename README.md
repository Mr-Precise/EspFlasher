# EspFlasher

Espressif WIFI chip download tool，GUI for esptool，mainly for linux platform，eliminates the discomfort of typing commands every time.  
Currently used for ESP8266，it can be used for ESP32 with slight modification if needed.

## Build & install  
### Dependencies:
Required Qt version >=5.8  
Debian/Ubuntu:  
`sudo apt install cmake git make qt5-default libqt5serialport5-dev`  
Arch/Manjaro:  
`sudo pacman -S cmake git make qt5-serialport`  

Clone git repo:  
`git clone https://github.com/Mr-Precise/EspFlasher`
### Build:

```bash
cd EspFlasher
mkdir build && cd build
cmake .. -G "Unix Makefiles"
make
```
After this, if desired, you can also build an linux .AppImage
```
./appimage.sh
```

## To run:  
It must be installed [esptool](https://github.com/espressif/esptool)，see the official instructions for the installation method.

`$ ./EspFlasher` or  
`$ sudo ./EspFlasher`

## Screenshot:
![image](https://github.com/Mr-Precise/EspFlasher/raw/main/screenshots/preview_en.png)
