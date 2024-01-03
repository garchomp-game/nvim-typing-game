TESTS_INIT=tests/minimal_init.lua
TESTS_DIR=tests/
TESTS_OUTPUT=test_result/results.txt

.PHONY: test

test:
	@mkdir -p test_result
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "PlenaryBustedDirectory ${TESTS_DIR} { minimal_init = '${TESTS_INIT}' }" \
		| tee /dev/tty | sed 's/\x1b\[[0-9;]*m//g' > ${TESTS_OUTPUT}
