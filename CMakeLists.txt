cmake_minimum_required (VERSION 3.10)
#project (akridex-mpc)
project (agmpc_singleatt_auction)
set(NAME "akridex-mpc")

set (CMAKE_CXX_STANDARD 17)

if( NODE_RUNTIMEVERSION VERSION_GREATER_EQUAL "17.0.0")
  add_compile_definitions(OPENSSL_API_COMPAT=0x10100001L)
  add_compile_definitions(OPENSSL_CONFIGURED_API=0x30000000L)
endif()

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)


add_compile_options(-fsanitize=address)
add_link_options(-fsanitize=address)
add_compile_options(-fsanitize=undefined)
add_link_options(-fsanitize=undefined)


include(cmake/common.cmake)
include(cmake/source_of_randomness.cmake)
include(cmake/threading.cmake)

find_package(OpenSSL REQUIRED)
find_package(Boost REQUIRED COMPONENTS system)
find_package(emp-tool REQUIRED)
find_package(emp-ot REQUIRED)
#find_package(emp-sh2pc REQUIRED)
#find_package(emp-agmpc REQUIRED)
find_package(GMP REQUIRED)

set(EMP-TOOL_LIBRARIES
  ${EMP-TOOL_LIBRARY}
  ${OPENSSL_LIBRARIES}
  ${Boost_LIBRARIES}
  ${GMP_LIBRARIES})

set(EMP_INCLUDE_DIRS
  ${EMP-TOOL_INCLUDE_DIR}
  ${EMP-OT_INCLUDE_DIRS}
  ${OPENSSL_INCLUDE_DIR}
  ${Boost_INCLUDE_DIRS}
  ${GMP_INCLUDE_DIR})

file(GLOB AGMPC_SINGLEATT_SOURCES
    "agmpc_singleatt_auction.cc"
    "agmpc_singleatt_auction.h"
    "agmpc_singleatt_auction_main.cc")

# AGMPC single attribute NAPI lib
cmake_policy(SET CMP0042 NEW)
include_directories(${CMAKE_JS_INC})
add_library(agmpc_singleatt_auction ${PROJECT_NAME} ${AGMPC_SINGLEATT_SOURCES} ${CMAKE_JS_SRC})
#add_library(agmpc_singleatt_auction ${PROJECT_NAME} SHARED ${AGMPC_SINGLEATT_SOURCES} ${CMAKE_JS_SRC})
set_target_properties(${PROJECT_NAME} PROPERTIES PREFIX "" SUFFIX ".node")
target_link_libraries(${PROJECT_NAME} ${CMAKE_JS_LIB})

# AGMPC single attribute executable
add_executable(agmpc_singleatt_auction_main
  ${AGMPC_SINGLEATT_SOURCES}
  agmpc_singleatt_auction_main.cc)
target_link_libraries(agmpc_singleatt_auction_main ${EMP-TOOL_LIBRARIES})
target_include_directories(agmpc_singleatt_auction_main PUBLIC ${EMP_INCLUDE_DIRS})

# AGMPC single attribute circuit generation
add_executable(agmpc_singleatt_circuit_generator agmpc_singleatt_circuit_generator.cc)
target_link_libraries(agmpc_singleatt_circuit_generator ${EMP-TOOL_LIBRARIES})
target_include_directories(agmpc_singleatt_circuit_generator PUBLIC ${EMP_INCLUDE_DIRS})

add_custom_target(agmpc_generate_circuits
  ./agmpc_singleatt_circuit_generator 10
  DEPENDS agmpc_singleatt_circuit_generator
  WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}/build/bin"
)
add_dependencies(agmpc_singleatt_auction agmpc_generate_circuits)
add_dependencies(agmpc_singleatt_auction_main agmpc_generate_circuits)

# Include Node-API wrappers
execute_process(COMMAND node -p "require('node-addon-api').include"
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE NODE_ADDON_API_DIR
        )
string(REGEX REPLACE "[\r\n\"]" "" NODE_ADDON_API_DIR ${NODE_ADDON_API_DIR})
target_include_directories(${PROJECT_NAME} PRIVATE ${NODE_ADDON_API_DIR})
add_definitions(-DNAPI_VERSION=3)
