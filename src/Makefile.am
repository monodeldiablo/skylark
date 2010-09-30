NULL = 

AM_CPPFLAGS = \
	$(SKYLARK_CFLAGS) \
	-include $(CONFIG_HEADER) \
	$(NULL)

AM_VALAFLAGS = \
        --thread \
	--vapidir $(top_srcdir)/vapi \
	--library=skylark \
        --pkg gmodule-2.0 \
        --pkg libsoup-2.4 \
        --pkg config \
        $(NULL)

bin_PROGRAMS = skylark

skylark_SOURCES = \
	main.vala \
	loader.vala \
	filter.vala \
	$(NULL)

skylark_LDADD = \
	$(SKYLARK_LIBS) \
	$(NULL)

EXTRA_DIST = \
	$(NULL)

DISTCLEANFILES = \
	$(NULL)

