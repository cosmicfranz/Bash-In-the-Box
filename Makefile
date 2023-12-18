

####################


## VARIABLES

SRC_DIR := .
PHONY =
SILENT =

include config.mk
include $(PACKAGE_NAME)/package.mk
include $(addsuffix /package.mk,$(PACKAGE_NAME)/$(PACKAGES))

PACKAGES_INSTALL_TARGETS := $(addprefix install-pkg-,$(PACKAGES))
PACKAGES_UNINSTALL_TARGETS := $(addprefix un,$(PACKAGES_INSTALL_TARGETS))


####################


## FUNCTIONS


# Finds and deletes all editor generated backup files
clean_backup_files = find $(1) -type f -name '*~' -delete


####################


## BUILD TARGETS


# Default target that prepares some files for the installation.
PHONY += all
SILENT += all
all : $(PACKAGE_NAME).sh


# Bash profile initialization script.
# Used to set BIB_HOME environment variable.
SILENT += $(NAME).sh
$(PACKAGE_NAME).sh : $(PACKAGE_NAME)-profile.sh.template
	echo "Creating Bash profile initialization script..."
	
	sed 's%__BIB_HOME__%$(DATADIR)/$(NAME)%' \
	    $< > $@
	
	echo "Done"


####################


## INSTALL TARGETS

# Install all the libraries and the support files.
PHONY += install
SILENT += install
install : install-main install-packages install-profile install-man


# Install package “main”
PHONY += install-main
SILENT += install-main
install-main :
	echo "Installing main package..."
	
	install --directory \
	    --mode 0755 \
	    $(DESTDIR)$(DATADIR)/$(NAME)/$(PACKAGE_NAME)
	install --mode 0644 \
	    $(LIBS_SOURCES[main]) \
	    $(DESTDIR)$(DATADIR)/$(NAME)/$(PACKAGE_NAME)
	
	echo "Done"


# Install all the packages
PHONY += install-packages $(PACKAGES_INSTALL_TARGETS)
SILENT += install-packages $(PACKAGES_INSTALL_TARGETS)
install-packages : $(PACKAGES_INSTALL_TARGETS)


$(PACKAGES_INSTALL_TARGETS) : install-pkg-% : install-main
	echo "Package $*: installing..."
	
	install --directory \
	    --mode 0755 \
	    $(DESTDIR)$(DATADIR)/$(NAME)/$(PACKAGE_NAME)/$*
	install --mode 0644 \
	    $(LIBS_SOURCES[$*]) \
	    $(DESTDIR)$(DATADIR)/$(NAME)/$(PACKAGE_NAME)/$*
	
	echo "Package $*: done"


# Install man pages
PHONY += install-man
SILENT += install-man
# SUPPORTED_LOCALES := it
install-man :
	echo "Installing man pages..."
	
	install --directory \
	    --mode 0755 \
	    $(DESTDIR)$(MANDIR)/man7
	install --mode 0644 \
	    $(wildcard docs/*.7) \
	    $(DESTDIR)$(MANDIR)/man7/
	
	echo "Done"


# Install Bash profile initialization script
PHONY += install-profile
SILENT += install-profile
install-profile :
	echo "Installing Bash profile initialization script..."
	
	install --directory \
	    --mode 0755 \
	    $(DESTDIR)$(SYSCONFDIR)/profile.d
	install --mode 0644 \
	    $(PACKAGE_NAME).sh \
	    $(DESTDIR)$(SYSCONFDIR)/profile.d/
	
	echo "Done"


####################


## UNINSTALL TARGETS


# Uninstall all the libraries and the support files.
PHONY += uninstall
SILENT += uninstall
uninstall : uninstall-main uninstall-packages uninstall-profile uninstall-man
	-rmdir $(DESTDIR)$(DATADIR)/$(NAME)


# Uninstall package “main”
PHONY += uninstall-main
SILENT += uninstall-main
uninstall-main : uninstall-packages
	echo "Uninstalling main package..."
	
	for file_path in $(LIBS_SOURCES[main]); \
	do \
	    rm --force $(DESTDIR)$(DATADIR)/$(NAME)/$${file_path}; \
	done
	-rmdir $(DESTDIR)$(DATADIR)/$(NAME)/$(PACKAGE_NAME)
	
	echo "Done"


# Uninstall all the packages
PHONY += uninstall-packages $(PACKAGES_UNINSTALL_TARGETS)
SILENT += uninstall-packages $(PACKAGES_UNINSTALL_TARGETS)
uninstall-packages : $(PACKAGES_UNINSTALL_TARGETS)


$(PACKAGES_UNINSTALL_TARGETS) : uninstall-pkg-% :
	echo "Package $*: uninstalling..."
	
	for file_path in $(LIBS_SOURCES[$*]); \
	do \
	    rm --force $(DESTDIR)$(DATADIR)/$(NAME)/$${file_path}; \
	done
	-rmdir $(DESTDIR)$(DATADIR)/$(NAME)/$(PACKAGE_NAME)/$*
	
	echo "Package $*: done"


# Uninstall Bash profile initialization script
PHONY += uninstall-profile
SILENT += uninstall-profile
uninstall-profile :
	echo "Uninstalling Bash profile initialization script..."
	
	rm --force $(DESTDIR)$(SYSCONFDIR)/profile.d/$(PACKAGE_NAME).sh
	
	echo "Done"


# Uninstall man pages
PHONY += uninstall-man
SILENT += uninstall-man
uninstall-man :
	echo "Uninstalling man pages..."
	
	rm --force $(DESTDIR)$(MANDIR)/man7/*.7
	
	echo "Done"


####################


## OTHER TARGETS

# Run self-tests
PHONY += check
SILENT += check
check :
	BIB_HOME=${PWD} ./run_tests.sh


# Finds and deletes all editor generated backup files
PHONY += distclean
SILENT += distclean
distclean :
	echo "Removing stale backup files..."
	
	$(call clean_backup_files,.)
	
	echo "Done"


# Deletes generated files
PHONY += clean
SILENT += clean
clean :
	echo "Removing $(PACKAGE_NAME).sh..."
	
	rm --force "$(PACKAGE_NAME).sh"
	
	echo "Done"


# Prints help message
PHONY += help
SILENT += help
include $(SRC_DIR)/help_text.mk
help :
	$(info $(HELP_TEXT))


####################


## SPECIAL TARGETS

.SILENT : $(SILENT)

.PHONY : $(PHONY)
