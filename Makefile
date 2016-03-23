#
###############################################################################
# Config.

JULIA_CPU_TARGET=native
OPENBLAS_TARGET_ARCH=native

# A10
#JULIA_CPU_TARGET=bdver2
#OPENBLAS_TARGET_ARCH=BULLDOZER

OPENBLAS_DYNAMIC_ARCH=0

JOBS=6

VERSION=v0.5.0-dev
PREFIX?=~/local

###############################################################################

.PHONY: default linux_deps windows_deps

default: all

###############################################################################
# Dependecies.

linux_deps:
	sudo apt-get install bzip2 gcc gfortran git g++ make cmake m4 ncurses-dev \
		libpython-dev libssl-dev

windows_deps:
	echo 'http://www.7-zip.org/download.html                                                                           '
	echo 'http://www.python.org/download/releases/                                                                     '
	echo 'http://www.cmake.org/download/                                                                               '
	echo 'http://downloads.sourceforge.net/project/mingwbuilds/mingw-builds-install/mingw-builds-install.exe           '
	echo '		- 4.8.1, x64, win32, seh, 5                                                                            '
	echo '		- C:\mingw-builds\x64-4.8.1-win32-seh-rev5                                                             '
	echo 'http://sourceforge.net/projects/msys2/files/Base/x86_64/msys2-x86_64-20140910.exe                            '
	echo '		- MSYS2 Shell                                                                                          '
	echo '		- pacman-key --init                                                                                    '
	echo '		- pacman -Syu                                                                                          '
	echo '		- Restart shell                                                                                        '
	echo '		- pacman -S diffutils git m4 make patch tar msys/openssh unzip '                                       '
	echo '		- Restart shell                                                                                        '
	echo '		- echo "mount C:/Python27/python" >> ~/.bashrc                                                         '
	echo '		- echo "mount C:/Program\ Files\ \(x86\)/CMake /cmake" >> ~/.bashrc                                    '
	echo '		- echo "mount C:/mingw-builds/x64-4.8.1-win32-seh-rev5/mingw64 /mingw" >> ~/.bashrc                    '
	echo '		- echo "export PATH=/usr/local/bin:/usr/bin:/opt/bin:/mingw/bin:/python:/cmake/bin:\$PATH" >> ~/.bashrc'
	echo '		- Restart shell                                                                                        '

###############################################################################
# Build julia root and install packages.

status/downloaded:
	git clone git://github.com/JuliaLang/julia.git
	cd julia && make full-source-dist
	zip -9r julia-$(shell date +%F-%T | sed 's/:/-/g').zip julia/
	mkdir status
	touch $@

U=julia/Make.user
status/built: status/downloaded
	echo "prefix=${PWD}/julia_root"                       >  ${U}
	echo "JULIA_CPU_TARGET=${JULIA_CPU_TARGET}"           >> ${U}
	echo "OPENBLAS_TARGET_ARCH=${OPENBLAS_TARGET_ARCH}"   >> ${U}
	echo "OPENBLAS_DYNAMIC_ARCH=${OPENBLAS_DYNAMIC_ARCH}" >> ${U}
	make install -j${JOBS} -C julia/ VERBOSE=1
	touch $@

status/cleanup_root: status/built
	rm -f julia_root/bin/julia-debug
	rm -f julia_root/lib/julia/libjulia-debug.so
	rm -f julia_root/bin/julia-debug.exe
	rm -f julia_root/bin/libjulia-debug.dll
	rm -rf julia_root/share/julia/test/
	touch $@

S=${PWD}/julia_root/share/julia/site
status/install_packages: status/cleanup_root
	JULIA_PKGDIR=${S} julia_root/bin/julia install_packages.jl
	touch $@
	
status/cleanup_site: status/install_packages
	-find ${S}/ -name .cache -exec rm -rf {} \;
	-find ${S}/ -name .git -exec rm -rf {} \;
	rm -rf ${S}/v0.5/Silo/deps/downloads
	rm -rf ${S}/v0.5/Silo/deps/src
	rm -rf ${S}/v0.5/Silo/deps/usr/include
	rm -rf ${S}/v0.5/Silo/deps/usr/lib/libsilo.a
	rm -rf ${S}/v0.5/Silo/deps/usr/lib/libsilo.la
	rm -rf ${S}/v0.5/Silo/deps/usr/lib/libsilo.settings
	rm -rf ${S}/v0.5/Blosc/deps/c-blosc-1.5.0
	rm -rf ${S}/v0.5/Blosc/deps/c-blosc-1.5.0.tar.gz
	touch $@

all: status/cleanup_site

ID=${PREFIX}/julia/${VERSION}
install:
	mkdir -p ${ID}/
	cp -r julia_root/* ${ID}/
	mkdir -p ~/bin
	ln -sf ${ID}/bin/julia ~/bin/julia
	echo "push!(LOAD_PATH, \".\")" >> ~/.juliarc.jl

###############################################################################
# House keeping.

distclean:
	rm -rf status/
	rm -rf julia/
	rm -rf julia_root/

MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PROJECT_DIR := $(notdir $(patsubst %/,%,$(dir $(MAKEFILE_PATH))))
dist: distclean
	cd ../ && zip -9r \
		${PROJECT_DIR}-$$(date +%F-%T | sed 's/:/-/g').zip \
		${PROJECT_DIR}

###############################################################################

