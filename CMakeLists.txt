# https://github.com/Mr-Precise/EspFlasher
cmake_minimum_required(VERSION 3.7)

if(${CMAKE_VERSION} VERSION_LESS "3.12.0")
    project(EspFlasher)
else()
    project(EspFlasher CXX)
endif()

if(MINGW)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mwindows -s")
endif(MINGW)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt5 COMPONENTS Core Qml Quick SerialPort REQUIRED)

set(SRC
    main.cpp
    EspProcess.cpp
)

set(HEADERS
    EspProcess.h
)

qt5_add_resources(RESOURCES qml.qrc)

add_executable(${PROJECT_NAME}
    ${SRC}
    ${HEADERS}
    ${RESOURCES}
)

target_link_libraries(${PROJECT_NAME}
    Qt5::Qml
    Qt5::Quick
    Qt5::SerialPort
)

# for Qt 5.15+
# qt_import_plugins(${PROJECT_NAME})
# tests
# qt_import_plugins(${PROJECT_NAME} INCLUDE Qt::QtQuick Qt::qtquick2plugin)


# Define additional compiler flags if needed
# target_compile_definitions(${PROJECT_NAME} PRIVATE QT_DEPRECATED_WARNINGS)
# target_compile_definitions(${PROJECT_NAME} PRIVATE QT_DISABLE_DEPRECATED_BEFORE=0x060000)

install(TARGETS ${PROJECT_NAME} DESTINATION ${CMAKE_INSTALL_BINDIR})
