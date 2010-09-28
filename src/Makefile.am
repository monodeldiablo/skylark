NULL = 

AM_CPPFLAGS = \
	$(SKYLARK_CFLAGS) \
	-include $(CONFIG_HEADER) \
	$(NULL)

AM_VALAFLAGS = \
        --pkg libsoup-2.4 \
        --thread \
        $(NULL)
#        --pkg config

bin_PROGRAMS = skylark

skylark_SOURCES = \
	main.vala \
	$(NULL)

skylark_LDADD = \
	$(SKYLARK_LIBS) \
	$(NULL)

EXTRA_DIST = \
	$(NULL)

DISTCLEANFILES = \
	$(NULL)

