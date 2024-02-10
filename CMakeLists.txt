cmake_minimum_required(VERSION 3.14)

# Project configuration
project(zsign VERSION 1.0)
set(CMAKE_CXX_STANDARD 20)
set (SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)

# Configure version header
configure_file(${SRC_DIR}/zsign_config.h.in zsign_config.h)

# Main sources
file(GLOB SRC ${SRC_DIR}/**/**.cpp ${SRC_DIR}/**.cpp)
add_executable(zsign ${SRC})

# Dependencies
# On macOS, search Homebrew for keg-only versions of OpenSSL because system provided /usr/lib/libssl.dylib cannot be linked
if (CMAKE_HOST_SYSTEM_NAME MATCHES "Darwin")
    execute_process(
        COMMAND brew --prefix OpenSSL 
        RESULT_VARIABLE BREW_OPENSSL
        OUTPUT_VARIABLE BREW_OPENSSL_PREFIX
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if (BREW_OPENSSL EQUAL 0 AND EXISTS "${BREW_OPENSSL_PREFIX}")
        message(STATUS "Found OpenSSL keg installed by Homebrew at ${BREW_OPENSSL_PREFIX}")
        set(OPENSSL_ROOT_DIR "${BREW_OPENSSL_PREFIX}/")
        set(OPENSSL_INCLUDE_DIR "${BREW_OPENSSL_PREFIX}/include")
        set(OPENSSL_LIBRARIES "${BREW_OPENSSL_PREFIX}/lib/libssl.dylib;${BREW_OPENSSL_PREFIX}/lib/libcrypto.dylib")
    endif()
else()
    find_package(OpenSSL REQUIRED)
endif()

# Configure OpenSSL
message("OpenSSL include dir: ${OPENSSL_INCLUDE_DIR}")
message("OpenSSL libraries: ${OPENSSL_LIBRARIES}")
target_include_directories(zsign PRIVATE ${OPENSSL_INCLUDE_DIR})
list(APPEND LIB_LIST ${OPENSSL_LIBRARIES})

# Configure ZLIB
find_package(ZLIB REQUIRED)
message("zlib include dir: ${ZLIB_INCLUDE_DIR}")
message("zlib libraries: ${ZLIB_LIBRARIES}")
target_include_directories(zsign PRIVATE ${ZLIB_INCLUDE_DIR})
list(APPEND LIB_LIST ${ZLIB_LIBRARIES})

# Finalize
target_include_directories(zsign PRIVATE ${SRC_DIR})
target_link_libraries(zsign ${LIB_LIST})

target_include_directories(zsign PUBLIC ${CMAKE_CURRENT_BINARY_DIR})