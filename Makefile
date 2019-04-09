BUILD_DIR     = .build
DOCKER_IMAGE  = regex


all: clean test

.PHONY: run test update clean
.SILENT: run test update clean
run:
	swift run


test:
	swift test


update:
ifeq ($(shell uname),Darwin)
	swift test --generate-linuxmain
else
	@echo Tests must be generated on macOS.
endif


clean:
	rm -rf $(BUILD_DIR)


.PHONY: image container
.SILENT: image container
image:
	docker build -t $(DOCKER_IMAGE) .


container: image
	docker run -it $(DOCKER_IMAGE) bash
