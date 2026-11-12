@echo off


:: Where this Python keeps its headers: conda-forge moved them from include to include\python
:: with 3.15, and the FindPythonLibs this build uses only looks in the former.
for /f "usebackq delims=" %%i in (`%PYTHON% -c "import pathlib, sysconfig; print(pathlib.Path(sysconfig.get_path('include')).as_posix())"`) do set "PY_INCLUDE_DIR=%%i"
if errorlevel 1 exit 1

cmake -B build -G "Ninja" . ^
    -Wno-dev ^
    -D CMAKE_BUILD_TYPE="Release" ^
    -D PYTHON_ROOT_DIR="%PREFIX%" ^
    -D CMAKE_CXX_FLAGS="/bigobj /wd4661 /wd4244 /EHsc" ^
    -D PYTHON_EXECUTABLE:FILEPATH="%PYTHON%" ^
    -D PYTHON_INCLUDE_DIR:PATH="%PY_INCLUDE_DIR%" ^
    -D CONFIGURATION_ROOT_DIR="%SRC_DIR%/deps/config" ^
    -D SALOME_CMAKE_DEBUG=ON ^
    -D SALOME_USE_MPI=OFF ^
    -D MEDCOUPLING_BUILD_STATIC=OFF ^
    -D MEDCOUPLING_BUILD_TESTS=OFF ^
    -D MEDCOUPLING_BUILD_DOC=OFF ^
    -D MEDCOUPLING_USE_64BIT_IDS=OFF ^
    -D MEDCOUPLING_USE_MPI=OFF ^
    -D MEDCOUPLING_MEDLOADER_USE_XDR=OFF ^
    -D MEDCOUPLING_INSTALL_PYTHON=%SP_DIR% ^
    -D XDR_INCLUDE_DIRS="" ^
    -D MEDCOUPLING_ENABLE_PYTHON=ON ^
    -D MEDCOUPLING_ENABLE_PARTITIONER=ON ^
    -D MEDCOUPLING_PARTITIONER_PARMETIS=OFF ^
    -D MEDCOUPLING_PARTITIONER_METIS=OFF ^
    -D MEDCOUPLING_PARTITIONER_SCOTCH=OFF ^
    -D MEDCOUPLING_PARTITIONER_PTSCOTCH=OFF ^
    %CMAKE_ARGS%

if errorlevel 1 exit 1
cmake --build build --target install
if errorlevel 1 exit 1

:: Move dll files from %PREFIX%/Library/Lib to %PREFIX%/Library/Bin
:: This is needed for the python bindings to work

cd %LIBRARY_LIB%
move *.dll %LIBRARY_BIN%