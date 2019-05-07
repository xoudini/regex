_BUILD_DIR      = .build
_DOCKER_IMAGE   = regex
_DESTINATION    = 'platform=macOS,arch=x86_64'
_DOCS_DIR       = Docs
_DD_DIR         = /tmp/RegexData
_COVERAGE       = coverage.txt
_EXECUTABLE     = rift
_PROF_PATH      = $(shell find $(_DD_DIR)/. -name Coverage.profdata)
_FMWK_PATH      = $(shell find $(_DD_DIR)/. -name Regex.framework)
CONFIG         ?= Debug


all: clean test


.SILENT: test $(_COVERAGE) coverage
test:
	$(call colorize,3,"Running tests...")

	xcodebuild test                                 \
	    -project Regex.xcodeproj                    \
	    -scheme Regex                               \
	    -configuration $(CONFIG)                    \
	    -destination $(_DESTINATION)                \
	    -derivedDataPath $(_DD_DIR)                 \
	    -enableCodeCoverage YES                     \
	    -quiet

	$(if $$?=0,$(call colorize,2,"All tests passed"),)

$(_COVERAGE): test
	$(call colorize,3,"Generating coverage report...")

	xcrun llvm-cov report -instr-profile            \
	    $(_PROF_PATH)                               \
	    $(_FMWK_PATH)/Regex                         \
	    > $(_DOCS_DIR)/$(_COVERAGE)

	$(call colorize,2,"Generated coverage at: $(_DOCS_DIR)/$(_COVERAGE)")

	open -a TextEdit $(_DOCS_DIR)/$(_COVERAGE)

coverage: $(_COVERAGE)


.SILENT: $(_EXECUTABLE)
$(_EXECUTABLE):
	swift build --configuration release
	ln -s $(_BUILD_DIR)/release/$(_EXECUTABLE) $(_EXECUTABLE)


.PHONY: run update clean
.SILENT: run update clean
run:
	$(call colorize,3,"Running using Swift package manager.")
	swift run


update:
ifeq ($(shell uname),Darwin)
	$(call colorize,3,"Resolving tests for Linux...")
	swift test --generate-linuxmain
else
	$(call colorize,1,"Tests must be generated on macOS.")
endif


clean:
	$(call colorize,3,"Removing build files...")
	rm -rf $(_BUILD_DIR)
	rm -rf $(_DD_DIR)
	rm -f $(_EXECUTABLE)


# Docker

.PHONY: image container
.SILENT: image container
image:
	$(call colorize,3,"Building Docker image...")
	docker build -t $(_DOCKER_IMAGE) .


container: image
	$(call colorize,3,"Starting Docker container...")
	docker run -it $(_DOCKER_IMAGE) bash


# Functions

define colorize
	@tput setaf $1
	@echo $2
	@tput sgr0
endef
