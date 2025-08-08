

get-deps: get_node get_vma get-direnv
	echo "Not implemented"

dev:
	go install github.com/hairyhenderson/gomplate/v3/cmd/gomplate@latest

toml:
	gomplate -f config.toml.tmpl -o config.toml

iso: toml get-deps
	rm -rf output
	mkdir output
	podman pull quay.io/rh-ee-chbutler/fedora-bootc-dashboard:latest
	podman pull quay.io/centos-bootc/bootc-image-builder:latest
	podman run \
			--rm \
			-it \
			--privileged \
			--pull=newer \
			--security-opt label=type:unconfined_t \
			-v $(CURDIR)/config.toml:/config.toml:ro \
			-v $(CURDIR)/output:/output \
			-v /var/lib/containers/storage:/var/lib/containers/storage \
			quay.io/centos-bootc/bootc-image-builder:latest \
			--type iso \
			quay.io/rh-ee-chbutler/fedora-bootc-dashboard:latest


qcow: toml get-deps
	rm -rf output
	mkdir output
	podman pull quay.io/rh-ee-chbutler/fedora-bootc-dashboard:latest
	podman pull quay.io/centos-bootc/bootc-image-builder:latest
	podman run \
			--rm \
			-it \
			--privileged \
			--pull=newer \
			--security-opt label=type:unconfined_t \
			-v $(CURDIR)/config.toml:/config.toml:ro \
			-v $(CURDIR)/output:/output \
			-v /var/lib/containers/storage:/var/lib/containers/storage \
			quay.io/centos-bootc/bootc-image-builder:latest \
			--local \
			--type qcow2 \
		  quay.io/rh-ee-chbutler/fedora-bootc-dashboard:latest