# VERSION / RELEASE
# If no version is specified as a parameter of make, the last git hash
# value is taken.
EPOCH=0
VERSION?=3.18.0
RELEASE=0
ARCH=x86_64

# RPM_PACKAGE_NAME
# Defines the name of the rpm package. This name is required to install the rpm package with an rpm package manager like
# dnf, rpm or yum.
RPM_PACKAGE_NAME=prometheus-x509-certificate-exporter
RPM_FILE_NAME_SHORT=${RPM_PACKAGE_NAME}.rpm
RPM_FILE_NAME_FULL:=${RPM_PACKAGE_NAME}-${EPOCH}-${VERSION}-${RELEASE}.${ARCH}.rpm

root_dir:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# BUILD
# ==============================================================================
PHONY:=${RPM_FILE_NAME_SHORT}
${RPM_FILE_NAME_SHORT}: ${RPM_FILE_NAME_FULL}

${RPM_FILE_NAME_FULL}: clean

	git clone https://github.com/enix/x509-certificate-exporter.git ./src/${RPM_PACKAGE_NAME}
	go build -C ./src/${RPM_PACKAGE_NAME}/cmd/x509-certificate-exporter/ -o ${RPM_PACKAGE_NAME}

	install -D --mode 0644 "${root_dir}/src/systemd.service" "${root_dir}/pkg/usr/lib/systemd/system/${RPM_PACKAGE_NAME}.service"
	install -D --mode 0755 --target-directory "${root_dir}/pkg/usr/bin" "${root_dir}/src/${RPM_PACKAGE_NAME}/cmd/x509-certificate-exporter/${RPM_PACKAGE_NAME}"
	install -D --mode 0600 /dev/null "${root_dir}/pkg/etc/conf.d/${RPM_PACKAGE_NAME}"
	install -D --mode 0755 --target-directory "${root_dir}/pkg/usr/share/licenses/${RPM_PACKAGE_NAME}" "${root_dir}/src/${RPM_PACKAGE_NAME}/LICENSE"

	rpm-builder \
		--dir pkg/:/ \
		--epoch ${EPOCH} \
		--version ${VERSION} \
		--release ${RELEASE} \
		--arch ${ARCH} \
		--out ${RPM_FILE_NAME_FULL} \
			${RPM_PACKAGE_NAME}

# # CLEAN
# # ==============================================================================
clean:
	- rm --force --recursive ./pkg ./src/${RPM_PACKAGE_NAME}
	- rm --force ${RPM_FILE_NAME_FULL}

# PHONY
# ==============================================================================
# Declare the contents of the PHONY variable as phony. We keep that information
# in a variable so we can use it in if_changed.
.PHONY: ${PHONY}
