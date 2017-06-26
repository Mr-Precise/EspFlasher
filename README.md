# EspFlasher

乐鑫WIFI芯片的下载工具，对esptool进行了GUI包装，主要用于linux平台，免去了每次敲命令的麻烦。目前用于ESP8266，如果需要，稍微修改下即可用于ESP32。

## 编译
要求Qt版本>=5.8

## 运行

必须在系统里安装好[esptool](https://github.com/espressif/esptool)，安装方法见官方说明。

## 使用
除额外设置esptool.py路径以外，其他与乐鑫官方下载工具[Flash_Download_Tool](http://bbs.espressif.com/viewtopic.php?f=57&t=433)用法类似。
如果提示没有权限，则需要提升到管理权限运行,如Ubuntu下:

$ sudo ./EspFlasher

## 软件截图
![image](https://github.com/mengzawj/EspFlasher/raw/master/screenshots/preview.png)

