# CMake function to disable compiler warnings for a target
function(disable_compiler_warnings_for_target target)
    target_compile_options(${target} PRIVATE
        # Disabling common warnings for specific compilers
        $<$<CXX_COMPILER_ID:MSVC>:/wd4018>   # Example for MSVC warning
        $<$<CXX_COMPILER_ID:GNU>:-w>          # Disable all warnings for GCC
        $<$<CXX_COMPILER_ID:Clang>:-w>        # Disable all warnings for Clang
    )
endfunction()
