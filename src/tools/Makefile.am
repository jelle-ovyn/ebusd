AM_CXXFLAGS = -I$(top_srcdir)/src \
	      -isystem$(top_srcdir) \
          -Wno-unused-parameter

bin_PROGRAMS = ebuspicloader

ebuspicloader_SOURCES = ebuspicloader.cpp intelhex/intelhexclass.cpp
ebuspicloader_LDADD = ../lib/utils/libutils.a

distclean-local:
	-rm -f Makefile.in
	-rm -rf .libs
