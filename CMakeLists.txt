cmake_minimum_required(VERSION 3.19)
project(gm82core C)

set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")

if(${CMAKE_C_COMPILER_ID} STREQUAL "MSVC")
    set(CMAKE_C_FLAGS "/O2 /GS- /W2 /WX")
endif()

add_library(gm82core SHARED source/gm82core.c source/hrt.c source/windows.c source/math.c source/lovey01.c source/terrible_gm8_hacking.c source/perlin.c)

target_compile_definitions(gm82core PRIVATE PSAPI_VERSION=1)

option(INSTALL_GEX "Install the generated .gex" OFF)

set(GEX_URL https://raw.githubusercontent.com/GM82Project/gm82gex/main/gm82gex.py)
set(GEX_PY ${CMAKE_SOURCE_DIR}/gm82gex.py)
file(DOWNLOAD ${GEX_URL} STATUS DOWNLOAD_STATUS)
list(GET DOWNLOAD_STATUS 0 STATUS_CODE)
if(${STATUS_CODE} EQUAL 0)
	file(DOWNLOAD ${GEX_URL} ${GEX_PY})
else()
	message(WARNING "Couldn't redownload gm82gex.py")
endif()

if (INSTALL_GEX)
	add_custom_command(
		TARGET gm82core
		POST_BUILD
		COMMAND py ${GEX_PY} gm82core.gej
		WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
		COMMENT "Building .gex"
	)
else()
	add_custom_command(
		TARGET gm82core
		POST_BUILD
		COMMAND py ${GEX_PY} gm82core.gej --noinstall
		WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
		COMMENT "Building .gex"
	)
endif()