#!/bin/bash

# Save the list of existing environment variables before sourcing the env_rpmbuild.conf file.
before_vars=$(compgen -v)

source rpm/env_rpmbuild.conf

# Save the list of environment variables after sourcing the env_rpmbuild.conf file
after_vars=$(compgen -v)

# Find new variables created from configuration file
new_vars=$(comm -13 <(echo "$before_vars" | sort) <(echo "$after_vars" | sort))

# Export variables so that scripts or child processes can access them
for var in $new_vars; do
    export "$var"
done

set -eE

# validate parameters
chmod a+x rpm/validate_parameters.sh
./rpm/validate_parameters.sh location SQLITE_VERSION SQLITE_YEAR PGSPIDER_RPM_ID IMAGE_TAG DOCKERFILE ARTIFACT_DIR proxy no_proxy PACKAGE_RELEASE_VERSION PGSPIDER_BASE_POSTGRESQL_VERSION PGSPIDER_RELEASE_VERSION SQLITE_FDW_RELEASE_VERSION

# get sqlite download version
SQLITE_DOWNLOAD_VERSION=$(./rpm/convert_sqlite_download_version.sh $SQLITE_VERSION)

# clone sqlite
if [[ ! -f "rpm/deps/sqlite-autoconf-${SQLITE_DOWNLOAD_VERSION}.tar.gz" ]]; then
	cd rpm/deps
	chmod -R 777 ./
	wget https://www.sqlite.org/${SQLITE_YEAR}/sqlite-autoconf-${SQLITE_DOWNLOAD_VERSION}.tar.gz
	cd ../../
fi

if [[ ${PGSPIDER_RPM_ID} ]]; then
    PGSPIDER_RPM_ID_POSTFIX="-${PGSPIDER_RPM_ID}"
fi

# clone sqlite_fdw spec
## At this moment, we based on commit:df216ffca23020a436ca964a294e229a9073f4a8 on https://git.postgresql.org/gitweb/?p=pgrpms.git;a=summary
cd rpm
rm -rf sqlite_fdw.spec
wget "https://git.postgresql.org/gitweb/?p=pgrpms.git;a=blob_plain;f=rpm/redhat/main/non-common/sqlite_fdw/main/sqlite_fdw.spec;h=864e7ce58825eea3a7658b55305fb1365d51e917;hb=df216ffca23020a436ca964a294e229a9073f4a8" -O sqlite_fdw.spec
## apply patch
patch -u sqlite_fdw.spec -i sqlite_fdw_spec_pgspider.patch
cd ..

# create rpm on container environment
if [[ $location == [gG][iI][tT][lL][aA][bB] ]];
then 
    ./rpm/validate_parameters.sh ACCESS_TOKEN API_V4_URL PGSPIDER_PROJECT_ID SQLITE_FDW_PROJECT_ID
    docker build -t $IMAGE_TAG \
                 --build-arg proxy=${proxy} \
                 --build-arg no_proxy=${no_proxy} \
                 --build-arg ACCESS_TOKEN=${ACCESS_TOKEN} \
                 --build-arg PACKAGE_RELEASE_VERSION=${PACKAGE_RELEASE_VERSION} \
                 --build-arg PGSPIDER_BASE_POSTGRESQL_VERSION=${PGSPIDER_BASE_POSTGRESQL_VERSION} \
                 --build-arg PGSPIDER_RELEASE_VERSION=${PGSPIDER_RELEASE_VERSION} \
                 --build-arg PGSPIDER_RPM_ID=${PGSPIDER_RPM_ID_POSTFIX} \
                 --build-arg PGSPIDER_RPM_URL="$API_V4_URL/projects/${PGSPIDER_PROJECT_ID}/packages/generic/rpm_rhel8/${PGSPIDER_BASE_POSTGRESQL_VERSION}" \
                 --build-arg SQLITE_FDW_RELEASE_VERSION=${SQLITE_FDW_RELEASE_VERSION} \
                 --build-arg SQLITE_VERSION=${SQLITE_VERSION} \
                 --build-arg SQLITE_YEAR=${SQLITE_YEAR} \
                 --build-arg SQLITE_DOWNLOAD_VERSION=${SQLITE_DOWNLOAD_VERSION} \
                 -f rpm/$DOCKERFILE .
else
    ./rpm/validate_parameters.sh OWNER_GITHUB PGSPIDER_PROJECT_GITHUB SQLITE_FDW_PROJECT_GITHUB SQLITE_FDW_RELEASE_ID PGSPIDER_RELEASE_PACKAGE_VERSION
    docker build -t $IMAGE_TAG \
                 --build-arg proxy=${proxy} \
                 --build-arg no_proxy=${no_proxy} \
                 --build-arg PACKAGE_RELEASE_VERSION=${PACKAGE_RELEASE_VERSION} \
                 --build-arg PGSPIDER_BASE_POSTGRESQL_VERSION=${PGSPIDER_BASE_POSTGRESQL_VERSION} \
                 --build-arg PGSPIDER_RELEASE_VERSION=${PGSPIDER_RELEASE_VERSION} \
                 --build-arg PGSPIDER_RPM_URL="https://github.com/${OWNER_GITHUB}/${PGSPIDER_PROJECT_GITHUB}/releases/download/${PGSPIDER_RELEASE_PACKAGE_VERSION}" \
                 --build-arg SQLITE_FDW_RELEASE_VERSION=${SQLITE_FDW_RELEASE_VERSION} \
                 --build-arg SQLITE_VERSION=${SQLITE_VERSION} \
                 --build-arg SQLITE_YEAR=${SQLITE_YEAR} \
                 --build-arg SQLITE_DOWNLOAD_VERSION=${SQLITE_DOWNLOAD_VERSION} \
                 -f rpm/$DOCKERFILE .
fi

# copy binary to outside
mkdir -p $ARTIFACT_DIR
docker run --rm -v $(pwd)/$ARTIFACT_DIR:/tmp \
                -u "$(id -u $USER):$(id -g $USER)" \
                -e LOCAL_UID=$(id -u $USER) \
                -e LOCAL_GID=$(id -g $USER) \
                $IMAGE_TAG /bin/sh -c "cp /home/user1/rpmbuild/RPMS/x86_64/*.rpm /tmp/"
rm -f $ARTIFACT_DIR/*-debuginfo-*.rpm

# Push binary on repo
if [[ $location == [gG][iI][tT][lL][aA][bB] ]];
then
    curl_command="curl --header \"PRIVATE-TOKEN: ${ACCESS_TOKEN}\" --insecure --upload-file"
    package_uri="$API_V4_URL/projects/${SQLITE_FDW_PROJECT_ID}/packages/generic/rpm_rhel8/${PGSPIDER_BASE_POSTGRESQL_VERSION}"

    # sqlite
    eval "$curl_command ${ARTIFACT_DIR}/sqlite-${SQLITE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $package_uri/sqlite-${SQLITE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
    # sqlite_fdw
    eval "$curl_command ${ARTIFACT_DIR}/sqlite_fdw_${PGSPIDER_BASE_POSTGRESQL_VERSION}-${SQLITE_FDW_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $package_uri/sqlite_fdw_${PGSPIDER_BASE_POSTGRESQL_VERSION}-${SQLITE_FDW_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
    # debugsource
    eval "$curl_command ${ARTIFACT_DIR}/sqlite_fdw_${PGSPIDER_BASE_POSTGRESQL_VERSION}-debugsource-${SQLITE_FDW_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $package_uri/sqlite_fdw_${PGSPIDER_BASE_POSTGRESQL_VERSION}-debugsource-${SQLITE_FDW_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
    # llvmjit
    eval "$curl_command ${ARTIFACT_DIR}/sqlite_fdw_${PGSPIDER_BASE_POSTGRESQL_VERSION}-llvmjit-${SQLITE_FDW_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $package_uri/sqlite_fdw_${PGSPIDER_BASE_POSTGRESQL_VERSION}-llvmjit-${SQLITE_FDW_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
else
    curl_command="curl -L \
                            -X POST \
                            -H \"Accept: application/vnd.github+json\" \
                            -H \"Authorization: Bearer ${ACCESS_TOKEN}\" \
                            -H \"X-GitHub-Api-Version: 2022-11-28\" \
                            -H \"Content-Type: application/octet-stream\" \
                            --retry 20 \
                            --retry-max-time 120 \
                            --insecure"
    assets_uri="https://uploads.github.com/repos/${OWNER_GITHUB}/${SQLITE_FDW_PROJECT_GITHUB}/releases/${SQLITE_FDW_RELEASE_ID}/assets"
    binary_dir="--data-binary \"@${ARTIFACT_DIR}\""

    # sqlite
    eval "$curl_command $assets_uri?name=sqlite-${SQLITE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $binary_dir/sqlite-${SQLITE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
    # sqlite_fdw
    eval "$curl_command $assets_uri?name=sqlite_fdw_${PGSPIDER_BASE_POSTGRESQL_VERSION}-${SQLITE_FDW_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $binary_dir/sqlite_fdw_${PGSPIDER_BASE_POSTGRESQL_VERSION}-${SQLITE_FDW_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
    # debugsource
    eval "$curl_command $assets_uri?name=sqlite_fdw_${PGSPIDER_BASE_POSTGRESQL_VERSION}-debugsource-${SQLITE_FDW_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $binary_dir/sqlite_fdw_${PGSPIDER_BASE_POSTGRESQL_VERSION}-debugsource-${SQLITE_FDW_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
    # llvmjit
    eval "$curl_command $assets_uri?name=sqlite_fdw_${PGSPIDER_BASE_POSTGRESQL_VERSION}-llvmjit-${SQLITE_FDW_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $binary_dir/sqlite_fdw_${PGSPIDER_BASE_POSTGRESQL_VERSION}-llvmjit-${SQLITE_FDW_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"

fi

# Clean
docker rmi $IMAGE_TAG
