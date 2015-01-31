#!/bin/bash

# Architecture Assignment
[[ -z "$ARCH" ]] && ARCH="$(uname -m)"
case "$ARCH" in
   x86_64)
      X86=true && X86_64=true
      ;;
   i686)   X86=true;;
   armv*)
      ARM=true && export FORMAT_COMPILER_TARGET=armv
      export RARCHCFLAGS="${RARCHCFLAGS} -marm"
      case "$ARCH" in
         armv5tel) ARMV5=true;;
         armv6l)   ARMV6=true;;
         armv7l)   ARMV7=true;;
      esac;;
esac

if [[ -n "$PROCESSOR_ARCHITEW6432" && $PROCESSOR_ARCHITEW6432 -eq "AMD64" ]]; then
   ARCH=x86_64
   X86=true && X86_64=true
fi

if [ -z "$JOBS" ]; then
  if command -v nproc >/dev/null; then
     JOBS=$(nproc)
  else
     JOBS=1
  fi
fi

# Platform Assignment
[ -z "$platform" ] && platform="$(uname)"
case "$platform" in
   *BSD*)
      FORMAT_EXT='so'
      FORMAT_COMPILER_TARGET=unix
      DIST_DIR=bsd;;
   osx|*Darwin*)
      FORMAT_EXT='dylib'
      FORMAT_COMPILER_TARGET=osx
      DIST_DIR=osx;;
   win|*mingw32*|*MINGW32*|*MSYS_NT*)
      FORMAT_EXT='dll'
      FORMAT_COMPILER_TARGET=win
      DIST_DIR=win_x86;;
   win64|*mingw64*|*MINGW64*)
      FORMAT_EXT='dll'
      FORMAT_COMPILER_TARGET=win
      DIST_DIR=win_x64;;
   *psp1*)
      FORMAT_EXT='a'
      FORMAT_COMPILER_TARGET=psp1
      DIST_DIR=psp1;;
   *ios|theos_ios*)
      FORMAT_EXT='dylib'
      FORMAT_COMPILER_TARGET=theos_ios
      DIST_DIR=theos;;
   android)
      FORMAT_EXT='so'
      FORMAT_COMPILER_TARGET=android
      DIST_DIR=android;;
   *android-armv7*)
      FORMAT_EXT='so'
      FORMAT_COMPILER_TARGET=android-armv7
      DIST_DIR=android/armeabi-v7a;;
   *)
      FORMAT_EXT='so'
      FORMAT_COMPILER_TARGET=unix
      DIST_DIR=unix;;
esac

export FORMAT_COMPILER_TARGET_ALT="$FORMAT_COMPILER_TARGET"

echo "PLATFORM: $platform"
echo "ARCHITECTURE: $ARCH"
echo "TARGET: $FORMAT_COMPILER_TARGET"


#if uncommented, will fetch repos with read+write access. Useful for committers
#export WRITERIGHTS=1


#if uncommented, will build experimental cores as well which are not yet fit for release.
#export BUILD_EXPERIMENTAL=1

#ARM DEFINES
#===========

#if uncommented, will build cores with Cortex A8 compiler optimizations
#export CORTEX_A8=1

#if uncommented, will build cores with Cortex A9 compiler optimizations
#export CORTEX_A9=1

#if uncommented, will build cores with ARM hardfloat ABI
#export ARM_HARDFLOAT=1

#if uncommented, will build cores with ARM softfloat ABI
#export ARM_SOFTFLOAT=1

#if uncommented, will build cores with ARM NEON support (ARMv7+ only)
#export ARM_NEON=1

#OPENGL DEFINES
#==============

#if uncommented, will build libretro GL cores. Ignored for mobile platforms - GL cores will always be built there.
export BUILD_LIBRETRO_GL=1

#if uncommented, will build cores with OpenGL ES 2 support. Not needed
#for platform-specific cores - only for generic core builds (ie. libretro-build.sh)
#export ENABLE_GLES=1

#ANDROID DEFINES
#================

export TARGET_ABIS="armeabi armeabi-v7a x86"

#uncomment to define NDK standalone toolchain for ARM
#export NDK_ROOT_DIR_ARM = 

#uncomment to define NDK standalone toolchain for MIPS
#export NDK_ROOT_DIR_MIPS = 

#uncomment to define NDK standalone toolchain for x86
#export NDK_ROOT_DIR_X86 =

# android version target if GLES is in use
export NDK_GL_HEADER_VER=android-18

# android version target if GLES is not in use
export NDK_NO_GL_HEADER_VER=android-9

# Retroarch target android API level
export RA_ANDROID_API=android-18

# Retroarch minimum API level (defines low end android version compatability)
export RA_ANDROID_MIN_API=android-9

#OSX DEFINES
#===========

# Define this to skip the universal build
# export NOUNIVERSAL=1

if [[ "${FORMAT_COMPILER_TARGET}" = "osx" && -z "${NOUNIVERSAL}" ]]; then
   case "${ARCH}" in
      i385|x86_64)
         export ARCHFLAGS="-arch i386 -arch x86_64"

         # FIXME: These are a temp shortcut for approx 40 cores 2015-02-01
         export CFLAGS="-arch i386 -arch x86_64 ${CFLAGS}"
         export CXXFLAGS="-arch i386 -arch x86_64 ${CXXFLAGS}"
         export LDFLAGS="-arch i386 -arch x86_64 ${LDFLAGS}"
         ;;
      ppc|ppc64)
         export ARCHFLAGS="-arch ppc -arch ppc64"
         ;;
      *)
         echo "Universal build requested with unknown ARCH=\"${ARCH}\""
   esac
fi

#CORE BUILD SUMMARY
#==================

# Set this to disable the core build summary
# export NOBUILD_SUMMARY=1

BUILD_SUMMARY=$(pwd)/build-summary.log
BUILD_SUCCESS=$(pwd)/build-success.log
BUILD_FAIL=$(pwd)/build-fail.log
if [ -z "${BUILD_SUMMARY_FMT}" ]; then
   if command -v column >/dev/null; then
      BUILD_SUMMARY_FMT=column
   else
      BUILD_SUMMARY_FMT=cat
   fi
fi


#USER DEFINES
#------------
#These options should be defined inside your own
#local libretro-config-user.sh file rather than here.
#The following below is just a sample.

if [ -f "libretro-config-user.sh" ]; then
. ./libretro-config-user.sh
fi

