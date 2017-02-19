build:
	docker build -t cloud-cpu-bench --build-arg VERSION=`git describe --tags` .
