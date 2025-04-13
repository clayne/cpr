include(CheckCXXSourceRuns)

set(ALL_SAN_FLAGS "")

 # No sanitizers when cross compiling to prevent stuff like this: https://github.com/whoshuu/cpr/issues/582
if(NOT CMAKE_CROSSCOMPILING)
    # Thread sanitizer
    if(CPR_DEBUG_SANITIZER_FLAG_THREAD)
        set(THREAD_SAN_FLAGS "-fsanitize=thread")
        set(PREV_FLAG ${CMAKE_REQUIRED_FLAGS})
        set(CMAKE_REQUIRED_FLAGS "${THREAD_SAN_FLAGS}")
        check_cxx_source_runs("int main() { return 0; }" THREAD_SANITIZER_AVAILABLE_AND_ENABLED)
        set(CMAKE_REQUIRED_FLAGS ${PREV_FLAG})
        # Do not add the ThreadSanitizer for builds with all sanitizers enabled because it is incompatible with other sanitizers.
    endif()

    # Address sanitizer
    if(CPR_DEBUG_SANITIZER_FLAG_ADDR)
        set(ADDR_SAN_FLAGS "-fsanitize=address")
        set(PREV_FLAG ${CMAKE_REQUIRED_FLAGS})
        set(CMAKE_REQUIRED_FLAGS "${ADDR_SAN_FLAGS}")
        check_cxx_source_runs("int main() { return 0; }" ADDRESS_SANITIZER_AVAILABLE_AND_ENABLED)
        set(CMAKE_REQUIRED_FLAGS ${PREV_FLAG})
        if(ADDRESS_SANITIZER_AVAILABLE_AND_ENABLED)
            set(ALL_SAN_FLAGS "${ALL_SAN_FLAGS} ${ADDR_SAN_FLAGS}")
        endif()
    endif()

    # Leak sanitizer
    if(CPR_DEBUG_SANITIZER_FLAG_LEAK)
        set(LEAK_SAN_FLAGS "-fsanitize=leak")
        set(PREV_FLAG ${CMAKE_REQUIRED_FLAGS})
        set(CMAKE_REQUIRED_FLAGS "${LEAK_SAN_FLAGS}")
        check_cxx_source_runs("int main() { return 0; }" LEAK_SANITIZER_AVAILABLE_AND_ENABLED)
        set(CMAKE_REQUIRED_FLAGS ${PREV_FLAG})
        if(LEAK_SANITIZER_AVAILABLE_AND_ENABLED)
            set(ALL_SAN_FLAGS "${ALL_SAN_FLAGS} ${LEAK_SAN_FLAGS}")
        endif()
    endif()

    # Undefined behavior sanitizer
    if(CPR_DEBUG_SANITIZER_FLAG_UB)
        set(UDEF_SAN_FLAGS "-fsanitize=undefined")
        set(PREV_FLAG ${CMAKE_REQUIRED_FLAGS})
        set(CMAKE_REQUIRED_FLAGS "${UDEF_SAN_FLAGS}")
        check_cxx_source_runs("int main() { return 0; }" UNDEFINED_BEHAVIOR_SANITIZER_AVAILABLE_AND_ENABLED)
        set(CMAKE_REQUIRED_FLAGS ${PREV_FLAG})
        if(UNDEFINED_BEHAVIOR_SANITIZER_AVAILABLE_AND_ENABLED)
            set(ALL_SAN_FLAGS "${ALL_SAN_FLAGS} ${UDEF_SAN_FLAGS}")
        endif()
    endif()

    # All sanitizer (without thread sanitizer)
    if(CPR_DEBUG_SANITIZER_FLAG_ALL AND NOT ALL_SAN_FLAGS STREQUAL "")
        set(PREV_FLAG ${CMAKE_REQUIRED_FLAGS})
        set(CMAKE_REQUIRED_FLAGS "${ALL_SAN_FLAGS}")
        check_cxx_source_runs("int main() { return 0; }" ALL_SANITIZERS_AVAILABLE_AND_ENABLED)
        set(CMAKE_REQUIRED_FLAGS ${PREV_FLAG})
    endif()

    if(THREAD_SANITIZER_AVAILABLE_AND_ENABLED)
        set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} ${THREAD_SAN_FLAGS}" CACHE INTERNAL "Flags used by the C compiler during thread sanitizer builds." FORCE)
        set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} ${THREAD_SAN_FLAGS}" CACHE INTERNAL "Flags used by the C++ compiler during thread sanitizer builds." FORCE)
        set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "${CMAKE_SHARED_LINKER_FLAGS_DEBUG}" CACHE INTERNAL "Flags used for the linker during thread sanitizer builds" FORCE)
    elseif(ADDRESS_SANITIZER_AVAILABLE_AND_ENABLED)
        set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} ${ADDR_SAN_FLAGS} -fno-omit-frame-pointer -fno-optimize-sibling-calls" CACHE INTERNAL "Flags used by the C compiler during address sanitizer builds." FORCE)
        set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} ${ADDR_SAN_FLAGS} -fno-omit-frame-pointer -fno-optimize-sibling-calls" CACHE INTERNAL "Flags used by the C++ compiler during address sanitizer builds." FORCE)
        set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "${CMAKE_SHARED_LINKER_FLAGS_DEBUG}" CACHE INTERNAL "Flags used for the linker during address sanitizer builds" FORCE)
    elseif(LEAK_SANITIZER_AVAILABLE_AND_ENABLED)
        set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} ${LEAK_SAN_FLAGS} -fno-omit-frame-pointer" CACHE INTERNAL "Flags used by the C compiler during leak sanitizer builds." FORCE)
        set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} ${LEAK_SAN_FLAGS} -fno-omit-frame-pointer" CACHE INTERNAL "Flags used by the C++ compiler during leak sanitizer builds." FORCE)
        set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "${CMAKE_SHARED_LINKER_FLAGS_DEBUG}" CACHE INTERNAL "Flags used for the linker during leak sanitizer builds" FORCE)
    elseif(UNDEFINED_BEHAVIOR_SANITIZER_AVAILABLE_AND_ENABLED)
        set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} ${UDEF_SAN_FLAGS}" CACHE INTERNAL "Flags used by the C compiler during undefined behavior sanitizer builds." FORCE)
        set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} ${UDEF_SAN_FLAGS}" CACHE INTERNAL "Flags used by the C++ compiler during undefined behavior sanitizer builds." FORCE)
        set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "${CMAKE_SHARED_LINKER_FLAGS_DEBUG}" CACHE INTERNAL "Flags used for the linker during undefined behavior sanitizer builds" FORCE)
    elseif(ALL_SANITIZERS_AVAILABLE_AND_ENABLED)
        set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} ${ALL_SAN_FLAGS} -fno-omit-frame-pointer -fno-optimize-sibling-calls" CACHE INTERNAL "Flags used by the C compiler during most possible sanitizer builds." FORCE)
        set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} ${ALL_SAN_FLAGS} -fno-omit-frame-pointer -fno-optimize-sibling-calls" CACHE INTERNAL "Flags used by the C++ compiler during most possible sanitizer builds." FORCE)
        set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "${CMAKE_SHARED_LINKER_FLAGS_DEBUG}" CACHE INTERNAL "Flags used for the linker during most possible sanitizer builds" FORCE)
    endif()
endif()
