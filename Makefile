GIT_TAG := $(shell git describe --always --tags --abbrev=0 | tail -c+2)
GIT_COMMIT := $(shell git rev-list v${GIT_TAG}..HEAD --count)
VERSION := ${GIT_TAG}.${GIT_COMMIT}
IMAGE_NAME := kontur/moira-web2
RELEASE := 1
VENDOR := "SKB Kontur"
URL := "https://github.com/moira-alert/web2.0"
LICENSE := "GPLv3"

.PHONY: default build test prepare clean tar rpm deb packages docker_image docker_push docker_push_release

default: test build tar

build:
	npm run build

test: prepare
	npm run lint

prepare:
	npm install

clean:
	rm -rf build

tar:
	mkdir -p build/root/var/www/moira || true
	cp -rf favicon.ico build/root/var/www/moira/
	cp -rf config.json.example build/root/var/www/moira/
	cp -rf dist/* build/root/var/www/moira/
	tar -czvPf build/moira-web2-${VERSION}-${RELEASE}.tar.gz -C build/root  .

rpm:
	fpm -t rpm \
		-s "tar" \
		--description "Moira Web2" \
		--vendor ${VENDOR} \
		--url ${URL} \
		--license ${LICENSE} \
		--name "moira-web" \
		--version "${VERSION}" \
		--iteration "${RELEASE}" \
		-p build \
		build/moira-web2-${VERSION}-${RELEASE}.tar.gz

deb:
	fpm -t deb \
		-s "tar" \
		--description "Moira Web2" \
		--vendor ${VENDOR} \
		--url ${URL} \
		--license ${LICENSE} \
		--name "moira-web" \
		--version "${VERSION}" \
		--iteration "${RELEASE}" \
		-p build \
		build/moira-web2-${VERSION}-${RELEASE}.tar.gz

packages: clean tar rpm deb

docker_image:
	docker build -t ${IMAGE_NAME}:${VERSION} -t ${IMAGE_NAME}:latest .

docker_push:
	docker push ${IMAGE_NAME}:latest

docker_push_release:
	docker push ${IMAGE_NAME}:latest
	docker push ${IMAGE_NAME}:${VERSION}
