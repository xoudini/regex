_BUILD_DIR      = .build
_DOCKER_IMAGE   = regex
_DESTINATION    = 'platform=macOS,arch=x86_64'
_DOCS_DIR       = Docs
_SAMPLE_DIR     = Samples
_JAZZY_OUT      = $(_DOCS_DIR)/Jazzy
_DD_DIR         = /tmp/RegexData
_COVERAGE       = coverage.txt
_TEST_SCRIPT    = comparison.sh
_TEST_RESULT    = $(_DOCS_DIR)/performance.csv
_EXECUTABLE     = rift
_PROF_PATH      = $(shell find $(_DD_DIR)/. -name Coverage.profdata)
_FMWK_PATH      = $(shell find $(_DD_DIR)/. -name Regex.framework)
_TEST_FILES     = $(wildcard $(_SAMPLE_DIR)/*.txt)
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


.SILENT: $(_JAZZY_OUT) jazzy
$(_JAZZY_OUT):
	$(call colorize,3,"Generating documentation...")

	jazzy                                           \
	    -o $(_JAZZY_OUT)                            \
	    -a "Dan Lindholm"                           \
	    -m "Regex"                                  \
		-x "-project,Regex.xcodeproj"               \
		--min-acl private

	$(call colorize,2,"Generated documentation at: $(_JAZZY_OUT)")

	open $(_JAZZY_OUT)

jazzy: $(_JAZZY_OUT)


.SILENT: $(_EXECUTABLE) comparison
$(_EXECUTABLE):
	swift build --configuration release
	ln -s $(_BUILD_DIR)/release/$(_EXECUTABLE) $(_EXECUTABLE)


comparison: $(_EXECUTABLE) $(_TEST_FILES)
	@echo filename,lines,bytes,regex,rift,grep,matches > $(_TEST_RESULT)
	$(foreach file,$(_TEST_FILES),./$(_TEST_SCRIPT) $(file);)

# $(foreach file,$(_TEST_FILES),$(call runcomparison,$(file));)

.PHONY: update clean
.SILENT: update clean
update:
ifeq ($(shell uname),Darwin)
	$(call colorize,3,"Resolving tests for Linux...")
	swift test --generate-linuxmain
else
	$(call colorize,1,"Tests must be generated on macOS.")
endif


clean:
	$(call colorize,1,"Removing build files...")
	rm -rf $(_BUILD_DIR)
	rm -rf $(_DD_DIR)

	$(call colorize,1,"Removing link to executable...")
	rm -f $(_EXECUTABLE)

	$(call colorize,1,"Removing auto-generated documentation...")
	rm -rf $(_JAZZY_OUT)


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
