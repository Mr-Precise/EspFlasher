# https://github.com/Mr-Precise/EspFlasher
cmake_minimum_required(VERSION 3.7)

if(${CMAKE_VERSION} VERSION_LESS "3.12.0")
    project(EspFlasher)
else()
    project(EspFlasher CXX)
endif()

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(MINGW)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mwindows -s")
endif(MINGW)

find_package(Qt5 REQUIRED COMPONENTS Core Qml Quick SerialPort)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

qt5_add_resources(QT_RESOURCES src/qml.qrc)

set(SRC
    src/main.cpp
    src/EspProcess.cpp
)

set(HEADERS
    src/EspProcess.h
)

add_executable(${PROJECT_NAME}
    ${SRC}
    ${HEADERS}
    ${QT_RESOURCES}
)

target_link_libraries(${PROJECT_NAME}
    Qt5::Quick
    Qt5::SerialPort
    Qt5::Qml
)

option(STATIC_LINUX_QT_PLUGINS "Static link QtQuick plugin on qt5 5.15 static build" OFF)
if(STATIC_LINUX_QT_PLUGINS)
    find_package(Qt5QmlImportScanner REQUIRED)
    # for Qt 5.15+
    qt5_import_qml_plugins(${PROJECT_NAME})
    # ???
    qt_import_plugins(${PROJECT_NAME} INCLUDE Qt::QtQuick Qt::qtquick2plugin)
endif(STATIC_LINUX_QT_PLUGINS)

# Define additional compiler flags if needed
# target_compile_definitions(${PROJECT_NAME} PRIVATE QT_DEPRECATED_WARNINGS)
# disables all the APIs deprecated before Qt 6.0.0
# target_compile_definitions(${PROJECT_NAME} PRIVATE QT_DISABLE_DEPRECATED_BEFORE=0x060000)

# Install desktop
install(FILES linux/espflasher.desktop DESTINATION share/applications)

# install icons
install(DIRECTORY linux/icons DESTINATION share)

install(
    TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# uninstall target
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
    IMMEDIATE @ONLY
)

add_custom_target(uninstall
    ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake
)
