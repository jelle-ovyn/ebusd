add_definitions(-Wno-unused-parameter)

set(ebuspicloader_SOURCES ebuspicloader.cpp intelhex/intelhexclass.cpp)

include_directories(../lib/ebus)
include_directories(../lib/utils)
include_directories(intelhex)

add_executable(ebuspicloader ${ebuspicloader_SOURCES})
target_link_libraries(ebuspicloader utils ${ebuspicloader_LIBS})

install(TARGETS ebuspicloader EXPORT ebusd DESTINATION bin)
