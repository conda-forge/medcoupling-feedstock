#!/bin/bash

set -ex

if [[ "$mpi" == "nompi" ]]; then
  on_mpi="OFF"
else
  on_mpi="ON"
fi

# The Python headers and library, stated rather than searched for: CMake < 4's FindPythonLibs only
# looks for the versions it was released knowing, so a newer Python (3.15) is "not found".
PY_INCLUDE_DIR="$($PYTHON -c 'import sysconfig; print(sysconfig.get_path("include"))')"
PY_LIBRARY="${PREFIX}/lib/libpython$($PYTHON -c 'import sysconfig; print(sysconfig.get_config_var("LDVERSION"))').so"

 # Disable PTScotch because petsc is not built against int64
cmake  -B build . \
    -DCMAKE_BUILD_TYPE="Release" \
    -DPYTHON_ROOT_DIR="${PREFIX}" \
    -DPYTHON_EXECUTABLE:FILEPATH="$PYTHON" \
    -DPYTHON_INCLUDE_DIR:PATH="${PY_INCLUDE_DIR}" \
    -DPYTHON_LIBRARY:FILEPATH="${PY_LIBRARY}" \
    -Wno-dev \
    -DCONFIGURATION_ROOT_DIR="${SRC_DIR}/deps/config" \
    -DSALOME_CMAKE_DEBUG=ON \
    -DMED_INT_IS_LONG=ON \
    -DSALOME_USE_MPI=${on_mpi} \
    -DMEDCOUPLING_BUILD_TESTS=OFF \
    -DMEDCOUPLING_BUILD_DOC=OFF \
    -DMEDCOUPLING_USE_64BIT_IDS=ON \
    -DMEDCOUPLING_USE_MPI=${on_mpi} \
    -DMEDCOUPLING_MEDLOADER_USE_XDR=OFF \
    -DXDR_INCLUDE_DIRS="" \
    -DMEDCOUPLING_PARTITIONER_PARMETIS=OFF \
    -DMEDCOUPLING_PARTITIONER_METIS=OFF \
    -DMEDCOUPLING_PARTITIONER_SCOTCH=OFF \
    -DMEDCOUPLING_PARTITIONER_PTSCOTCH=OFF \
    -DMPI_C_COMPILER:PATH="$(which mpicc)" \
    -DMPI_CXX_COMPILER:PATH="$(which mpicxx)" \
    ${CMAKE_ARGS}

cd build
make install -j$CPU_COUNT