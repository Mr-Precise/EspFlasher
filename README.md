# EspFlasher
乐鑫WIFI芯片的下载工具，对esptool进行了GUI包装，主要用于linux平台，免去了每次敲命令的麻烦。

## 编译
要求Qt版本>=5.8

## 运行
必须在系统里安装好[esptool](https://github.com/espressif/esptool)

## 使用
除额外设置esptool.py路径以外，其他与乐鑫官方下载工具用法类似。
如果提示没有权限，则需要提升到管理权限运行（如Ubuntu下，$ sudo ./EspFlasher）
