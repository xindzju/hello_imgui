include(${CMAKE_CURRENT_LIST_DIR}/ios/hello_imgui_ios.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/android/hello_imgui_android.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/emscripten/hello_imgui_emscripten.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/desktop/hello_imgui_desktop.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/assets/hello_imgui_assets.cmake)

set(apkCMake_projectTemplateFolder ${CMAKE_CURRENT_LIST_DIR}/android/apkCMake/templates/sdl)
set(apkCMake_resTemplateFolder ${CMAKE_CURRENT_LIST_DIR}/android/res)
include(${CMAKE_CURRENT_LIST_DIR}/android/apkCMake/apkCMake.cmake)

function(hello_imgui_emscripten_add_local_assets app_name)
    if (IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/assets)
        message(VERBOSE "hello_imgui_emscripten_add_local_assets: ${app_name} found local assets")
        hello_imgui_bundle_assets(${app_name} ${CMAKE_CURRENT_SOURCE_DIR}/assets)
    endif()
endfunction()

function(set_bundle_variables_defaults app_name)
    if (NOT DEFINED HELLO_IMGUI_BUNDLE_IDENTIFIER_URL_PART)
        set(HELLO_IMGUI_BUNDLE_IDENTIFIER_URL_PART com.helloimgui PARENT_SCOPE)
    endif()
    if (NOT DEFINED HELLO_IMGUI_BUNDLE_IDENTIFIER_NAME_PART)
        set(HELLO_IMGUI_BUNDLE_IDENTIFIER_NAME_PART ${app_name} PARENT_SCOPE)
    endif()
    if (NOT DEFINED HELLO_IMGUI_ICON_DISPLAY_NAME)
        set(HELLO_IMGUI_ICON_DISPLAY_NAME ${app_name} PARENT_SCOPE)
    endif()
    if (NOT DEFINED HELLO_IMGUI_BUNDLE_NAME)
        set(HELLO_IMGUI_BUNDLE_NAME ${app_name} PARENT_SCOPE)
    endif()
    if (NOT DEFINED HELLO_IMGUI_BUNDLE_COPYRIGHT)
        set(HELLO_IMGUI_BUNDLE_COPYRIGHT "" PARENT_SCOPE)
    endif()
    if (NOT DEFINED HELLO_IMGUI_BUNDLE_EXECUTABLE)
        set(HELLO_IMGUI_BUNDLE_EXECUTABLE ${app_name} PARENT_SCOPE)
    endif()
    if (NOT DEFINED HELLO_IMGUI_BUNDLE_VERSION)
        set(HELLO_IMGUI_BUNDLE_VERSION 0.0.1 PARENT_SCOPE)
    endif()
    if (NOT DEFINED HELLO_IMGUI_BUNDLE_ICON_FILE)
        set(HELLO_IMGUI_BUNDLE_ICON_FILE "" PARENT_SCOPE)
    endif()
endfunction()


# hello_imgui_prepare_app is a helper function, that will prepare an app to be used with hello_imgui
#
# Usage:
# hello_imgui_prepare_app(target_name)
#
# Features:
# * It will automaticaly link the target to the required libraries (hello_imgui, OpenGl, glad, etc)
# * It will embed the assets
# * It will perform additional customization (app icon and name on mobile platforms, etc)
function(hello_imgui_prepare_app app_name)
    set_bundle_variables_defaults(${app_name})

    set(common_assets_folder ${HELLOIMGUI_BASEPATH}/hello_imgui_assets)
    hello_imgui_bundle_assets(${app_name} ${common_assets_folder})
    hello_imgui_emscripten_add_local_assets(${app_name})

    hello_imgui_platform_customization(${app_name})

    target_link_libraries(${app_name} PRIVATE hello_imgui viewer ws2_32 AFTLib Setupapi)

    if (ANDROID AND HELLOIMGUI_CREATE_ANDROID_STUDIO_PROJECT)
        set(apkCMake_applicationIdUrlPart ${HELLO_IMGUI_BUNDLE_IDENTIFIER_URL_PART})
        set(apkCMake_applicationIdNamePart ${HELLO_IMGUI_BUNDLE_IDENTIFIER_NAME_PART})
        set(apkCMake_iconDisplayName  ${HELLO_IMGUI_ICON_DISPLAY_NAME})
        # set(apkCMake_abiFilters "'arm64-v8a', 'x86', 'x86_64'")
        apkCMake_makeAndroidStudioProject(${app_name})
    endif()
endfunction()


#
# hello_imgui_add_app is a helper function, similar to cmake's "add_executable"
#
# Usage:
# hello_imgui_add_app(app_name file1.cpp file2.cpp ...)
#
# Features: see the doc for hello_imgui_prepare_app, which is called by this function
function(hello_imgui_add_app)
    set(args ${ARGN})
    list(GET args 0 app_name)
    list(REMOVE_AT args 0)
    set(app_sources ${args})

    if (ANDROID)
        add_library(${app_name} SHARED ${app_sources})
    else()
        add_executable(${app_name} ${app_sources})
    endif()

    hello_imgui_prepare_app(${app_name})

    message(VERBOSE "hello_imgui_add_app
             app_name=${app_name}
             sources=${app_sources}
            ")
endfunction()
