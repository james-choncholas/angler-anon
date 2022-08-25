cmake_minimum_required (VERSION 3.10)
project (akridex-mpc)
set(NAME "akridex-mpc")

set (CMAKE_CXX_STANDARD 17)

# NAPI
cmake_policy(SET CMP0042 NEW)
include_directories(${CMAKE_JS_INC})
file(GLOB SOURCE_FILES
    "src/agmpc_singleatt_auction.cc"
    "src/agmpc_singleatt_auction.h"
    "src/agmpc_singleatt_auction_main.cc")
add_library(agmpc_singleatt_auction ${PROJECT_NAME} SHARED ${SOURCE_FILES} ${CMAKE_JS_SRC})
set_target_properties(${PROJECT_NAME} PROPERTIES PREFIX "" SUFFIX ".node")
target_link_libraries(${PROJECT_NAME} ${CMAKE_JS_LIB})

include(cmake/common.cmake)
include(cmake/source_of_randomness.cmake)
include(cmake/threading.cmake)

find_package(OpenSSL REQUIRED)
find_package(Boost REQUIRED COMPONENTS system)
find_package(emp-tool REQUIRED)
find_package(emp-ot REQUIRED)
find_package(emp-sh2pc REQUIRED)
find_package(GMP REQUIRED)

set(EMP-TOOL_LIBRARIES
  ${EMP-TOOL_LIBRARY}
  ${OPENSSL_LIBRARIES}
  ${Boost_LIBRARIES}
  ${GMP_LIBRARIES})

add_executable(agmpc_singleatt_circuit_generator src/agmpc_singleatt_circuit_generator.cc)
target_link_libraries(agmpc_singleatt_circuit_generator ${EMP-TOOL_LIBRARIES})
target_include_directories(agmpc_singleatt_circuit_generator PUBLIC
  ${EMP-TOOL_INCLUDE_DIR}
  ${EMP-OT_INCLUDE_DIRS}
  ${OPENSSL_INCLUDE_DIR}
  ${Boost_INCLUDE_DIRS}
  ${GMP_INCLUDE_DIR})

add_custom_target(
  agmpc_generate_circuits
  DEPENDS src/agmpc_singleatt_circuit_generator.cc
  COMMAND ${PROJECT_SOURCE_DIR}/build/bin/agmpc_singleatt_circuit_generator 10
)


add_executable(agmpc_singleatt_auction src/agmpc_singleatt_auction.cc)
target_link_libraries(agmpc_singleatt_auction ${EMP-TOOL_LIBRARIES})
target_include_directories(agmpc_singleatt_auction PUBLIC
  ${EMP-TOOL_INCLUDE_DIR}
  ${EMP-OT_INCLUDE_DIRS}
  ${OPENSSL_INCLUDE_DIR}
  ${Boost_INCLUDE_DIRS}
  ${GMP_INCLUDE_DIR})

add_executable(plain_singleatt_auction src/plain_singleatt_auction.cc)
target_link_libraries(plain_singleatt_auction ${EMP-TOOL_LIBRARIES})
target_include_directories(plain_singleatt_auction PUBLIC
  ${EMP-TOOL_INCLUDE_DIR}
  ${EMP-OT_INCLUDE_DIRS}
  ${OPENSSL_INCLUDE_DIR}
  ${Boost_INCLUDE_DIRS}
  ${GMP_INCLUDE_DIR})
