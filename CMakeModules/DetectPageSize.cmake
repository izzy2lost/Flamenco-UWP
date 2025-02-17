# DetectPageSize.cmake

function(detect_page_size var)
    if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
        # For regular Windows platforms (e.g., Win32, x64)
        set(${var} 4096 PARENT_SCOPE)  # Default page size for Windows
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
        # For Linux-based systems
        execute_process(COMMAND getconf PAGE_SIZE OUTPUT_VARIABLE PAGESIZE OUTPUT_STRIP_TRAILING_WHITESPACE)
        set(${var} ${PAGESIZE} PARENT_SCOPE)
    elseif(CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        # For UWP (Windows Store apps) platforms
        set(${var} 4096 PARENT_SCOPE)  # Default page size for UWP (same as standard Windows)
    else()
        message(FATAL_ERROR "Unsupported platform for detect_page_size: ${CMAKE_SYSTEM_NAME}")
    endif()
endfunction()
