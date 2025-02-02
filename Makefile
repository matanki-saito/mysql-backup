.PHONY: build push test

TAG ?= latest
IMAGE ?= gnagaoka/mysql-backup
BUILDIMAGE ?= $(IMAGE):build
TARGET ?= $(IMAGE):$(TAG)


build:
	docker build -t $(BUILDIMAGE) .

push: build
	docker tag $(BUILDIMAGE) $(TARGET)
	docker push $(TARGET)

test_dump:
	cd test && DEBUG=$(DEBUG) ./test_dump.sh

test_cron:
	cd test && ./test_cron.sh

test_source_target:
	cd test && ./test_source_target.sh

test: test_dump test_cron test_source_target

.PHONY: clean-test-stop clean-test-remove clean-test
clean-test-stop:
	@echo Kill Containers
	$(eval IDS:=$(strip $(shell docker ps --filter label=mysqltest -q)))
	@if [ -n "$(IDS)" ]; then docker kill $(IDS); fi
	@echo

clean-test-remove:
	@echo Remove Containers
	$(eval IDS:=$(shell docker ps -a --filter label=mysqltest -q))
	@if [ -n "$(IDS)" ]; then docker rm $(IDS); fi
	@echo
	@echo Remove Volumes
	$(eval IDS:=$(shell docker volume ls --filter label=mysqltest -q))
	@if [ -n "$(IDS)" ]; then docker volume rm $(IDS); fi
	@echo

clean-test-network:
	@echo Remove Networks
	$(eval IDS:=$(shell docker network ls --filter label=mysqltest -q))
	@if [ -n "$(IDS)" ]; then docker network rm $(IDS); fi
	@echo

clean-test: clean-test-stop clean-test-remove clean-test-network
