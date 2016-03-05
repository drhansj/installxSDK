#!/bin/sh

PREFIX="notset"
WITHGIT="git"
SKIPMAKE="0"
for i in "$@"
  do
  case $i in
    -h|--help)
      echo "xSDK Installer help:"
      echo "--prefix=\"installation directory\" [--download-ideas] [other standard configure options such as mpicc=  etc]"
      SKIPMAKE="1"
      PREFIX="dummy"      
    ;;
    --prefix=*)
      PREFIX="${i#*=}"
      if [ "${PREFIX}" == "/usr" ]; then
        echo "Do not use /usr as your --prefix install location"
        exit
      fi
      if [ "${PREFIX}" == "/usr/local" ]; then
        echo "Do not use /usr/local as your --prefix install location"
        exit
      fi
    ;;
    --with-git=*)
	WITHGIT="${i#*=}"
    ;;
    --download-pflotran|--download-ideas)
      SKIPMAKE="1"
    ;;					 
    --download-pflotran=*|--download-ideas=*)
      SKIPMAKE="${i#*=}"
    ;;
    *)
            # unknown option
    ;;
  esac
done

if [ "${PREFIX}" == "notset" ]; then
  echo "You must provide a --prefix=\"installation directory\" option"
  exit
fi
 
# make directory where builds will occur
if [ ! -d xsdk ]; then
  mkdir xsdk
  printf "Creating work directory xsdk for all temporary files"  
fi
cd xsdk

#PETSC_BRANCH='barry/downloads'
# Get PETSc
if [ ! -d petsc ]; then
  if [ "${WITHGIT}" != "0" ]; then
    ${WITHGIT} clone https://bitbucket.org/petsc/petsc.git petsc
  else
    curl https://bitbucket.org/petsc/petsc/get/master.tar.gz > petsc.tar.gz
    dir=`tar -tzf petsc.tar.gz  | head -1`
    tar zxf petsc.tar.gz
    mv -f ${dir} petsc
    cd petsc
  fi
else
  if [ "${WITHGIT}" != "0" ]; then
    cd petsc
    git fetch
    #git checkout $PETSC_BRANCH
    git pull
  fi
fi


# Install the packages
export PETSC_DIR=`pwd`
./configure --download-xsdk $*
if [ "${SKIPMAKE}" == "0" ]; then
  make
  make install
fi

