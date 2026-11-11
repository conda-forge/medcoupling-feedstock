@echo off

:: The Python headers and import library, stated rather than searched for: CMake < 4's
:: FindPythonLibs only looks for the versions it was released knowing, so a newer Python (3.15)
:: is "not found".
for /f "delims=" %%i in ('"%PYTHON%" -c "import sys; print('python%%d%%d.lib' %% sys.version_info[:2])"') do set "PY_IMPLIB=%%i"

cmake -B build -G "Ninja" . ^
    -Wno-dev ^
    -D CMAKE_BUILD_TYPE="Release" ^
    -D PYTHON_ROOT_DIR="%PREFIX%" ^
    -D PYTHON_INCLUDE_DIR:PATH="%PREFIX%\include" ^
    -D PYTHON_LIBRARY:FILEPATH="%PREFIX%\libs\%PY_IMPLIB%" ^
    -D CMAKE_CXX_FLAGS="/bigobj /wd4661 /wd4244 /EHsc" ^
    -D PYTHON_EXECUTABLE:FILEPATH="%PYTHON%" ^
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