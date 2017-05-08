#!/bin/bash -e
. /etc/profile.d/modules.sh
# MPICH deploy script
module add deploy
module add gcc/${GCC_VERSION}

cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
rm -rf *
export FC=`which gfortran`
export FCFLAGS=
export F90=
export F90FLAGS=

../configure \
--prefix=$SOFT_DIR-gcc-${GCC_VERSION} \
--enable-shared \
--enable-threads=multiple \
--enable-fortran=all \
--enable-cxx \
--enable-romio \
--enable-versioning
make

make install
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
module add gcc/$GCC_VERSION
module-whatis "$NAME $VERSION."
setenv MPICH_VERSION $VERSION
setenv MPICH_DIR $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION-gcc-$GCC_VERSION
prepend-path PATH $::env(MPICH_DIR)/bin
prepend-path LD_LIBRARY_PATH $::env(MPICH_DIR)/lib
prepend-path GCC_INCLUDE_DIR $::env(MPICH_DIR)/include
MODULE_FILE
) > modules/${VERSION}-gcc-${GCC_VERSION}
mkdir -p ${COMPILERS}/${NAME}
cp modules/${VERSION}-gcc-${GCC_VERSION} ${COMPILERS}/${NAME}

module avail ${NAME}

module add ${NAME}/${VERSION}-gcc-${GCC_VERSION}
