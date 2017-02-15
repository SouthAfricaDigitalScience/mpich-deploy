#!/bin/bash
# MPICH check-build
. /etc/profile.d/modules.sh
module add ci
module add gcc/${GCC_VERSION}
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}

make check

make install # this will install to /data/ci-build
mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
puts stderr " This module does nothing but alert the user"
puts stderr " that the [module-info name] module is not available"
}
module-whatis "$NAME $VERSION."
setenv MPICH_VERSION $VERSION
setenv MPICH_DIR /data/ci-build/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION-gcc-$GCC_VERSION
prepend-path LD_LIBRARY_PATH $::env(MPICH_DIR)/lib
prepend-path PATH            $::env(MPICH_DIR)/bin
prepend-path GCC_INCLUDE_DIR $::env(MPICH_DIR)/include
MODULE_FILE
) > modules/${VERSION}-gcc-${GCC_VERSION}
mkdir -p ${LIBRARIES_MODULES}/${NAME}
cp modules/${VERSION}-gcc-${GCC_VERSION} ${LIBRARIES_MODULES}/${NAME}

module avail ${NAME}
module add ${NAME}/${VERSION}-gcc-${GCC_VERSION}
which mpiexec
