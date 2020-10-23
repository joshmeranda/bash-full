install_dir=/usr/local/bin

scripts:=$(realpath $(shell ls ./bin/*))
bins:=$(addprefix ${install_dir}/, $(notdir ${scripts}))

.PHONY: install uninstall

install:
	for script in ${scripts}; do \
		ln --verbose --force --symbolic $$script ${install_dir}; \
	done

uninstall:
	rm --force --verbose ${bins}
