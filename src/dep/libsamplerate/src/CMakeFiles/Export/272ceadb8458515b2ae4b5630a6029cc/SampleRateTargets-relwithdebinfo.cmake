#----------------------------------------------------------------
# Generated CMake target import file for configuration "RelWithDebInfo".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "SampleRate::samplerate" for configuration "RelWithDebInfo"
set_property(TARGET SampleRate::samplerate APPEND PROPERTY IMPORTED_CONFIGURATIONS RELWITHDEBINFO)
set_target_properties(SampleRate::samplerate PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELWITHDEBINFO "C"
  IMPORTED_LOCATION_RELWITHDEBINFO "${_IMPORT_PREFIX}/lib/samplerate.lib"
  )

list(APPEND _cmake_import_check_targets SampleRate::samplerate )
list(APPEND _cmake_import_check_files_for_SampleRate::samplerate "${_IMPORT_PREFIX}/lib/samplerate.lib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
