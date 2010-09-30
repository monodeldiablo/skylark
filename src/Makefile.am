NULL = 

AM_CPPFLAGS = \
	$(SKYLARK_CFLAGS) \
	-include $(CONFIG_HEADER) \
	$(NULL)

AM_VALAFLAGS = \
        --thread \
	--vapidir $(top_srcdir)/vapi \
        --pkg config \
        --pkg libsoup-2.4 \
	--pkg json-glib-1.0 \
        $(NULL)

bin_PROGRAMS = skylark

skylark_SOURCES = \
	main.vala \
	filter.vala \
	$(NULL)

skylark_LDADD = \
	$(SKYLARK_LIBS) \
	$(NULL)

EXTRA_DIST = \
	$(NULL)

DISTCLEANFILES = \
	$(NULL)

