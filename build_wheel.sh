#!/bin/env bash

if [[ -z "$PYTHON_VERSIONS" ]]; then
    PYTHON_VERSIONS=$(ls -1 /cvmfs/soft.computecanada.ca/easybuild/software/2017/Core/python/ | grep -Po "\d\.\d" | sort -u | sed 's#^#python/#')
fi

ALL_PACKAGES="nose numpy scipy Cython h5py matplotlib dateutil numexpr bottleneck pandas pyzmq qiime future pyqi bio-format cogent qiime-default-reference pynast burrito burrito-fillings gdata emperor qcli scikit-bio natsort click subprocess32 cycler python-dateutil dlib shapely affine rasterio numba llvmlite velocyto htseq mpi4py sympy mpmath blist paycheck lockfile deap arff cryptography paramiko pyparsing netifaces netaddr funcsigs mock pytz enum34 bitstring Cycler PyZMQ path.py pysqlite requests nbformat Pygments singledispatch certifi backports_abc tornado MarkupSafe Jinja2 jupyter_client functools32 jsonschema mistune ptyprocess terminado simplegeneric ipython_genutils pathlib2 pickleshare traitlets notebook jupyter_core ipykernel pexpect backports.shutil_get_terminal_size prompt_toolkit ipywidgets widgetsnbextension ipython iptest testpath cffi pycparser asn1crypto ipaddress pynacl pyasn1 bcrypt nbconvert entrypoints configparser pandocfilters dnspython pygame pyyaml fuel pillow pillow-simd olefile seaborn theano Amara bx-python python-lzo RSeQC xopen cutadapt cgat kiwisolver torchvision dask distributed arboretum netCDF4 mdtraj biom-format grpcio absl-py gast protobuf tensorboard astor Markdown metasv cvxpy cvxopt dill multiprocess scs fastcache toolz ecos CVXcanon CoffeeScript PyExecJS msmbuilder Qutip tqdm biopython torchtext wxPython bz2file smart_open gensim hypothesis murmurhash cymem preshed msgpack_python msgpack_numpy cytoolz wrapt plac thinc ujson regex spacy bigfloat aiozmq python-utils progressbar2 fast5_research sphinx-argparsei jsonnet Unidecode python-jose pycryptodome pyproj pyshp basemap MDAnalysis MDAnalysisTests attrs Cartopy OWSLib pykdtree"

PACKAGE=${1?Missing package name}
VERSION=$2
PYTHON_IMPORT_NAME="$PACKAGE"
PACKAGE_FOLDER_NAME="$PACKAGE"
PACKAGE_DOWNLOAD_NAME="$PACKAGE"
RPATH_TO_ADD=""
BDIST_WHEEL_ARGS=""
PRE_DOWNLOAD_COMMANDS=""
TMP_WHEELHOUSE=$(pwd)
PATCHES=""

if [[ -n "$VERSION" ]]; then
	PACKAGE_DOWNLOAD_ARGUMENT="$PACKAGE==$VERSION"
else
	PACKAGE_DOWNLOAD_ARGUMENT="$PACKAGE"
fi

if [[ "$PACKAGE" == "numpy" ]]; then
	MODULE_BUILD_DEPS="imkl/2019.2.187"
	PYTHON_DEPS="nose pytest"
	PYTHON_TESTS="numpy.__config__.show(); numpy.test()"
elif [[ "$PACKAGE" == "SQLAlchemy" ]]; then
	PYTHON_IMPORT_NAME="sqlalchemy"
elif [[ "$PACKAGE" == "atari_py" ]]; then
	PACKAGE_DOWNLOAD_NAME="atari-py"
	PACKAGE_FOLDER_NAME="atari-py"
elif [[ "$PACKAGE" == "PyOpenGL" ]]; then
	PYTHON_IMPORT_NAME="OpenGL"
	PYTHON_TESTS="from OpenGL.GL.ARB.shader_objects import *; from OpenGL.GL.ARB.fragment_shader import *; from OpenGL.GL.ARB.vertex_shader import *; from OpenGL.GL import *; from OpenGL.GLU import *"
elif [[ "$PACKAGE" == "msprime" ]]; then
	MODULE_BUILD_DEPS="intel/2016.4 imkl/2019.2.187 gsl/1.16"
	PYTHON_DEPS="numpy"
	RPATH_TO_ADD="$EBROOTIMKL/lib/intel64"
elif [[ "$PACKAGE" == "Box2D-kengz" ]]; then
	PYTHON_IMPORT_NAME="Box2D"
elif [[ "$PACKAGE" == "pyslurm" ]]; then
	PYTHON_DEPS="cython"
	PRE_BUILD_COMMANDS='sed -i -e "s;SLURM_INC = \"\";SLURM_INC = \"/opt/software/slurm/include/include\";g" -e "s;SLURM_LIB = \"\";SLURM_LIB = \"/opt/software/slurm/lib\";g" setup.py'
elif [[ "$PACKAGE" == "cogent" ]]; then
	PYTHON_DEPS="numpy"
	PYTHON_VERSIONS="python/2.7"
	PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
elif [[ "$PACKAGE" == "amico" ]]; then
	PYTHON_DEPS="numpy dipy scipy nibabel h5py six"
	PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/daducci/AMICO/archive/master.zip"
	PACKAGE_DOWNLOAD_NAME="master.zip"
	PACKAGE_FOLDER_NAME="AMICO-master"
elif [[ "$PACKAGE" == "dipy" ]]; then
	PYTHON_DEPS="numpy"
elif [[ "$PACKAGE" == "termcolor" ]]; then
	PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
elif [[ "$PACKAGE" == "ScientificPython" ]]; then
	PYTHON_DEPS="numpy"
	PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
elif [[ "$PACKAGE" == "snakemake" ]]; then
	PYTHON_VERSIONS="python/3.5 python/3.6 python/3.7"
elif [[ "$PACKAGE" == "protobuf" ]]; then
	PYTHON_IMPORT_NAME="google.protobuf"
elif [[ "$PACKAGE" == "pyani" ]]; then
	PYTHON_VERSIONS="python/3.5 python/3.6 python/3.7"
elif [[ "$PACKAGE" == "cherrypy" ]]; then
	PACKAGE_DOWNLOAD_NAME="CherryPy"
elif [[ "$PACKAGE" == "arch" ]]; then
	PYTHON_DEPS="numpy Cython"
elif [[ "$PACKAGE" == "EukRep" ]]; then
	PYTHON_VERSIONS="python/3.5 python/3.6 python/3.7"
#elif [[ "$PACKAGE" == "parasail" ]]; then
#	MODULE_BUILD_DEPS="intel/2018.3 parasail"
elif [[ "$PACKAGE" == "multipledispatch" ]]; then
	PYTHON_DEPS="six"
elif [[ "$PACKAGE" == "dask_glm" ]]; then
	PACKAGE_DOWNLOAD_NAME="dask-glm"
	PACKAGE_FOLDER_NAME=$PACKAGE_DOWNLOAD_NAME
elif [[ "$PACKAGE" == "dask_ml" ]]; then
	MODULE_BUILD_DEPS="llvm/6.0.1"
	PACKAGE_DOWNLOAD_NAME="dask-ml"
	PACKAGE_FOLDER_NAME=$PACKAGE_DOWNLOAD_NAME
elif [[ "$PACKAGE" == "kPAL" ]]; then
	PYTHON_IMPORT_NAME="kpal"
elif [[ "$PACKAGE" == "configargparse" ]]; then
	PACKAGE_DOWNLOAD_NAME="ConfigArgParse"
	PACKAGE_FOLDER_NAME="ConfigArgParse"
#elif [[ "$PACKAGE" == "mageck-vispr" ]]; then
#	PYTHON_VERSIONS="python/3.5 python/3.6 python/3.7"
#	PACKAGE_DOWNLOAD_ARGUMENT="https://bitbucket.org/liulab/mageck-vispr/get/v0.5.4.tar.gz"
#	PACKAGE_DOWNLOAD_NAME="v0.5.4"
#	PACKAGE_FOLDER_NAME="liulab-mageck-vispr"
#	PYTHON_IMPORT_NAME=""
elif [[ "$PACKAGE" == "statsmodels" ]]; then
	PYTHON_DEPS="numpy"
elif [[ "$PACKAGE" == "anvio" ]]; then
	PYTHON_VERSIONS="python/3.5 python/3.6 python/3.7"
	PYTHON_DEPS="numpy Cython statsmodels==0.9.0"
	MODULE_BUILD_DEPS="gcc/5.4.0 gsl/2.3"
elif [[ "$PACKAGE" == "django" ]]; then
	PYTHON_VERSIONS="python/3.5 python/3.6 python/3.7"
	PACKAGE_DOWNLOAD_NAME="Django"
	PACKAGE_FOLDER_NAME="Django"
elif [[ "$PACKAGE" == "Sphinx" ]]; then
	PYTHON_IMPORT_NAME="sphinx"
elif [[ "$PACKAGE" == "OBITools" ]]; then
	PYTHON_DEPS="Cython Sphinx ipython virtualenv"
	PYTHON_IMPORT_NAME="obitools"
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "gdata" ]]; then
	PYTHON_DEPS="numpy"
	PYTHON_VERSIONS="python/2.7"
	PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
elif [[ "$PACKAGE" == "scikit-bio" ]]; then
	PYTHON_DEPS="numpy natsort"
	PYTHON_IMPORT_NAME="skbio"
elif [[ "$PACKAGE" == "qcli" ]]; then
	PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "emperor" ]]; then
	PYTHON_DEPS="qcli"
	PYTHON_VERSIONS="python/2.7"
	PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
elif [[ "$PACKAGE" == "pynast" ]]; then
	PYTHON_DEPS="cogent>=1.5.3 numpy"
	PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
elif [[ "$PACKAGE" == "qutip" ]]; then
	PYTHON_DEPS="Cython numpy scipy matplotlib"
elif [[ "$PACKAGE" == "msmbuilder" ]]; then
	PYTHON_DEPS="numpy scipy scikit-learn mdtraj pandas cython<0.28 cvxopt nose"
elif [[ "$PACKAGE" == "fastrlock" ]]; then
	# need to patch it so it supports bdist_wheel
	PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
elif [[ "$PACKAGE" == "openslide-python" ]]; then
	PYTHON_IMPORT_NAME="openslide"
	MODULE_BUILD_DEPS="intel/2016.4 openslide"
	PRE_BUILD_COMMANDS='sed -i -e "/import sys/a import os" -e "s;.libopenslide.so.0.;os.environ.get(\"EBROOTOPENSLIDE\",\"$EBROOTOPENSLIDE\") + \"/lib/libopenslide.so.0\";g" $(find . -name "lowlevel.py")'
elif [[ "$PACKAGE" == "cupy" ]]; then
	PYTHON_DEPS="numpy fastrlock"
	MODULE_BUILD_DEPS="gcc/7.3.0 cuda/10 cudnn nccl"
	# needed otherwise it does not find libcuda.so
	PRE_DOWNLOAD_COMMANDS='export LDFLAGS="-L$EBROOTCUDA/lib64/stubs -L$EBROOTNCCL/lib" ; export CFLAGS="-I$EBROOTNCCL/include/"'
elif [[ "$PACKAGE" == "chainer" ]]; then
        PYTHON_DEPS="filelock"
elif [[ "$PACKAGE" == "chainermn" ]]; then
        PYTHON_DEPS="chainer"
        PRE_BUILD_COMMANDS='module load mpi4py'
elif [[ "$PACKAGE" == "deepchem" ]]; then
	PYTHON_DEPS="numpy pandas joblib scikit-learn tensorflow_gpu pillow simdna"
	MODULE_RUNTIME_DEPS="gcc/5.4.0 rdkit/2018.03.3"
elif [[ "$PACKAGE" == "prometheus-client" ]]; then
	PACKAGE_DOWNLOAD_NAME="prometheus_client"
	PACKAGE_FOLDER_NAME=$PACKAGE_DOWNLOAD_NAME
	PYTHON_IMPORT_NAME=$PACKAGE_DOWNLOAD_NAME
elif [[ "$PACKAGE" == "ray" ]]; then
	if [[ -z "$VERSION" ]]; then
		VERSION="0.4.0"
	fi
	PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/ray-project/ray/archive/ray-$VERSION.tar.gz"
	MODULE_BUILD_DEPS="gcc/5.4.0 qt/5.10.1"
	PYTHON_DEPS="numpy scipy cython"
	PACKAGE_FOLDER_NAME="ray-ray-*/python"
	PRE_BUILD_COMMANDS="pwd; sed -i -e 's/-DPARQUET_BUILD_TESTS=off/-DPARQUET_BUILD_TESTS=off -DCMAKE_SKIP_RPATH=ON -DCMAKE_SKIP_INSTALL_RPATH=ON/g' ../thirdparty/scripts/build_parquet.sh && sed -i -e 's/-DARROW_WITH_ZSTD=off/-DARROW_WITH_ZSTD=off  -DCMAKE_SKIP_RPATH=ON -DCMAKE_SKIP_INSTALL_RPATH=ON/g' ../thirdparty/scripts/build_arrow.sh"
elif [[ "$PACKAGE" == "scs" ]]; then
	PYTHON_DEPS="numpy scipy"
elif [[ "$PACKAGE" == "PyWavelets" ]]; then
	PYTHON_DEPS="numpy cython"
	PYTHON_IMPORT_NAME="pywt"
elif [[ "$PACKAGE" == "scikit-image" ]]; then
	PYTHON_DEPS="numpy cython scipy"
	PYTHON_IMPORT_NAME="skimage"
elif [[ "$PACKAGE" == "pygdal" ]]; then
	PYTHON_DEPS="numpy"
	MODULE_BUILD_DEPS="gcc gdal"
elif [[ "$PACKAGE" == "keras-vis" ]]; then
	PYTHON_IMPORT_NAME="vis"
	PACKAGE_DOWNLOAD_NAME="keras_vis"
elif [[ "$PACKAGE" == "keras-applications" ]]; then
	PYTHON_IMPORT_NAME="keras.applications"
	PACKAGE_DOWNLOAD_NAME="Keras_Applications"
elif [[ "$PACKAGE" == "keras-preprocessing" ]]; then
	PYTHON_IMPORT_NAME="keras.preprocessing"
	PACKAGE_DOWNLOAD_NAME="Keras_Preprocessing"
elif [[ "$PACKAGE" == "absl-py" ]]; then
	PYTHON_IMPORT_NAME="absl"
elif [[ "$PACKAGE" == "CoffeeScript" ]]; then
	PYTHON_DEPS="PyExecJS"
elif [[ "$PACKAGE" == "PyExecJS" ]]; then
	PYTHON_IMPORT_NAME="execjs"
elif [[ "$PACKAGE" == "CVXcanon" ]]; then
	PYTHON_DEPS="numpy scipy"
elif [[ "$PACKAGE" == "ecos" ]]; then
	PYTHON_DEPS="numpy scipy"
elif [[ "$PACKAGE" == "cvxpy" ]]; then
	PYTHON_DEPS="numpy multiprocess scs fastcache scipy six toolz CVXcanon dill"
elif [[ "$PACKAGE" == "cvxopt" ]]; then
	MODULE_BUILD_DEPS="gcc suitesparse fftw imkl"
	PRE_BUILD_COMMANDS="export CVXOPT_LAPACK_LIB=mkl_rt; export CVXOPT_BLAS_LIB=mkl_rt; export CVXOPT_BLAS_LIB_DIR=$MKLROOT/lib; export CVXOPT_SUITESPARSE_LIB_DIR=$EBROOTSUITESPARSE/lib; export CVXOPT_SUITESPARSE_INC_DIR=$EBROOTSUITESPARSE/include; export CVXOPT_BUILD_FFTW=1; export CVXOPT_FFTW_LIB_DIR=$EBROOTFFTW/lib; export  CVXOPT_FFTW_INC_DIR=$EBROOTFFTW/include; "
elif [[ "$PACKAGE" == "multiprocess" ]]; then
	PYTHON_DEPS="dill"
elif [[ "$PACKAGE" == "grpcio" ]]; then
	PYTHON_IMPORT_NAME="grpc"
elif [[ "$PACKAGE" == "metasv" ]]; then
	PYTHON_DEPS="cython pysam"
elif [[ "$PACKAGE" == "scipy" ]]; then
	MODULE_BUILD_DEPS="imkl/2018.3.312"
	PYTHON_DEPS="nose numpy pytest"
	PYTHON_TESTS="scipy.__config__.show(); scipy.test()"
	if [[ "$VERSION" == "0.13.3" ]]; then
		PRE_BUILD_COMMANDS='sed -i -e "s/numpy.distutils.core/setuptools/g" setup.py'
	fi
elif [[ "$PACKAGE" == "mdtraj" ]]; then
	PYTHON_DEPS="cython numpy scipy pandas"
elif [[ "$PACKAGE" == "biom-format" ]]; then
	PYTHON_DEPS="scipy"
	PACKAGE_DOWNLOAD_NAME="biom_format"
elif [[ "$PACKAGE" == "netCDF4" ]]; then
	MODULE_BUILD_DEPS="gcc openmpi hdf5-mpi netcdf-mpi"
	PYTHON_DEPS="numpy Cython"
	PRE_BUILD_COMMANDS='module load mpi4py; export HDF5_DIR=$EBROOTHDF5; export NETCDF4_DIR=$EBROOTNETCDF'
	RPATH_TO_ADD="$EBROOTOPENMPI/lib"
elif [[ "$PACKAGE" == "arboretum" ]]; then
	PYTHON_DEPS="numpy scipy scikit-learn pandas dask distributed"
elif [[ "$PACKAGE" == "Cython" ]]; then
	MODULE_BUILD_DEPS=""
	PYTHON_DEPS=""
elif [[ "$PACKAGE" == "cutadapt" ]]; then
	PYTHON_DEPS="xopen"
elif [[ "$PACKAGE" == "cgat" ]]; then
	PYTHON_IMPORT_NAME="cgat"
	PYTHON_DEPS="numpy cython pysam setuptools pyparsing pyaml alignlib-lite matplotlib biopython"
elif [[ "$PACKAGE" == "h5py" ]]; then
	MODULE_BUILD_DEPS="gcc/7.3.0 hdf5"
	PYTHON_DEPS="nose numpy six Cython unittest2"
	PYTHON_TESTS="h5py.run_tests()"
elif [[ "$PACKAGE" == "matplotlib" ]]; then
	PYTHON_DEPS="pyparsing pytz six cycler python-dateutil numpy backports.functools-lru-cache kiwisolver"
elif [[ "$PACKAGE" == "python-dateutil" ]]; then
	PYTHON_IMPORT_NAME="dateutil"
elif [[ "$PACKAGE" == "numexpr" ]]; then
	PYTHON_DEPS="numpy"
	PYTHON_TESTS="numexpr.test()"
elif [[ "$PACKAGE" == "bottleneck" ]]; then
	PYTHON_DEPS="numpy nose"
	PYTHON_TESTS="bottleneck.test();" # bottleneck.bench()"
	PACKAGE_DOWNLOAD_NAME="Bottleneck"
	PACKAGE_FOLDER_NAME="Bottleneck"
elif [[ "$PACKAGE" == "tables" ]]; then
	MODULE_BUILD_DEPS="gcc hdf5"
	PYTHON_DEPS="h5py numpy numexpr six nose mock"
	PYTHON_TESTS="tables.test()"
elif [[ "$PACKAGE" == "bx-python" ]]; then
	PYTHON_DEPS="numpy python-lzo six"
	PYTHON_IMPORT_NAME="bx"
elif [[ "$PACKAGE" == "RSeQC" ]]; then
	PYTHON_DEPS="bx-python"
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "pandas" ]]; then
	PYTHON_DEPS="numpy python-dateutil pytz Cython numexpr bottleneck scipy tables matplotlib nose pytest moto"
#	PYTHON_TESTS="pandas.test()"
elif [[ "$PACKAGE" == "pyzmq" ]]; then
	PYTHON_IMPORT_NAME="zmq"
	MODULE_BUILD_DEPS="zeromq"
elif [[ "$PACKAGE" == "qiime" ]]; then
	PYTHON_DEPS="numpy scipy matplotlib mock nose cycler decorator enum34 functools32 ipython matplotlib pexpect emperor qcli natsort<4.0.0"
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "dlib-cpu" ]]; then
	MODULE_BUILD_DEPS="gcc/7.3.0 boost imkl"    # it does not work with Intel, and requires Boost
	PRE_BUILD_COMMANDS='sed -i -e "s;/opt/intel/mkl/lib/intel64;${MKLROOT}/lib/intel64;g" $(find . -name "*find_blas.*") '
	PACKAGE="dlib"
	PYTHON_IMPORT_NAME="$PACKAGE"
	PACKAGE_FOLDER_NAME="$PACKAGE"
	PACKAGE_DOWNLOAD_NAME="$PACKAGE"
        PACKAGE_DOWNLOAD_ARGUMENT="$PACKAGE"
	PACKAGE_SUFFIX='-cpu'
        BDIST_WHEEL_ARGS='--yes CMAKE_SKIP_RPATH'
elif [[ "$PACKAGE" == "dlib-gpu" ]]; then
	MODULE_BUILD_DEPS="gcc/7.3.0 boost imkl cuda cudnn"    # it does not work with Intel, and requires Boost
	PRE_BUILD_COMMANDS='export CUDNN_HOME=$EBROOTCUDNN; sed -i -e "s;/opt/intel/mkl/lib/intel64;${MKLROOT}/lib/intel64;g" $(find . -name "*find_blas.*")'
	PACKAGE="dlib"
	PYTHON_IMPORT_NAME="$PACKAGE"
	PACKAGE_FOLDER_NAME="$PACKAGE"
	PACKAGE_DOWNLOAD_NAME="$PACKAGE"
        PACKAGE_DOWNLOAD_ARGUMENT="$PACKAGE"
	PACKAGE_SUFFIX='-gpu'
        BDIST_WHEEL_ARGS='--yes CMAKE_SKIP_RPATH'
elif [[ "$PACKAGE" == "shapely" ]]; then
	MODULE_BUILD_DEPS="gcc geos"
	# need to patch geos.py to find libgeos_c.so based on the module that was loaded at build time
	PRE_BUILD_COMMANDS='sed -i -e "s;os.path.join(sys.prefix, \"lib\", \"libgeos_c.so\"),;\"$EBROOTGEOS/lib/libgeos_c.so\",;g" $(find . -name "geos.py")'
	PACKAGE_FOLDER_NAME="Shapely"
	PACKAGE_DOWNLOAD_NAME="Shapely"
elif [[ "$PACKAGE" == "rasterio" ]]; then
	PYTHON_DEPS="numpy affine snuggs cligj click-plugins enum34"
	MODULE_BUILD_DEPS="gcc gdal"
elif [[ "$PACKAGE" == "numba" ]]; then
	if [[ "$VERSION" == "0.31.0" ]]; then
		PYTHON_DEPS="numpy enum34 llvmlite==0.16.0"
	else
		PYTHON_DEPS="numpy enum34 llvmlite"
	fi
elif [[ "$PACKAGE" == "roboschool" ]]; then
	MODULE_BUILD_DEPS="gcc/7.3.0 boost bullet qt/5.6.1"
	PYTHON_VERSIONS="python/3.5 python/3.6 python/3.7"
	PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/openai/roboschool/archive/1.0.46.tar.gz"
	PACKAGE_DOWNLOAD_NAME="1.0.46.tar.gz"
	PACKAGE_FOLDER_NAME="roboschool-1.0.46"
	PRE_BUILD_COMMANDS="pushd roboschool/cpp-household && make && popd "
	if [[ "$RSNT_ARCH" == "avx2" ]]; then
		export CFLAGS="-march=core-avx2"
	elif [[ "$RSNT_ARCH" == "avx512" ]]; then
		export CFLAGS="-march=skylake-avx512"
	fi
	PATCHES="$PWD/patches/roboschool-cpp-household.patch"
elif [[ "$PACKAGE" == "llvmlite" ]]; then
	PYTHON_DEPS="enum34"
	MODULE_BUILD_DEPS="llvm cuda/10 tbb"
        PATCHES="$PWD/patches/llvmlite-0.28.0-fpic.patch"
elif [[ "$PACKAGE" == "scikit-learn" ]]; then
	PYTHON_IMPORT_NAME="sklearn"
	PYTHON_DEPS="numpy scipy"
elif [[ "$PACKAGE" == "velocyto" ]]; then
	PYTHON_DEPS="numpy scipy cython llvmlite==0.16.0 numba==0.31.0 matplotlib scikit-learn h5py click loompy"
	PYTHON_VERSIONS="python/3.6"
	unset PYTHON_IMPORT_NAME
elif [[ "$PACKAGE" == "Send2Trash" ]]; then
	PYTHON_IMPORT_NAME="send2trash"
elif [[ "$PACKAGE" == "htseq" ]]; then
	PYTHON_DEPS="numpy Cython pysam"
	PACKAGE_FOLDER_NAME="HTSeq"
	PACKAGE_DOWNLOAD_NAME="HTSeq"
	PYTHON_IMPORT_NAME="HTSeq"
elif [[ "$PACKAGE" == "mpi4py" ]]; then
	MODULE_BUILD_DEPS="intel openmpi"
elif [[ "$PACKAGE" == "mpmath" ]]; then
	# need to patch it so it supports bdist_wheel
	PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
elif [[ "$PACKAGE" == "backcall" ]]; then
	# need to patch it so it supports bdist_wheel
	PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
elif [[ "$PACKAGE" == "preprocess" ]]; then
	PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "paycheck" ]]; then
	# need to patch it so it supports bdist_wheel
	PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
elif [[ "$PACKAGE" == "bitstring" ]]; then
	# need to patch it so it supports bdist_wheel
	PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
elif [[ "$PACKAGE" == "pandocfilters" ]]; then
	# need to patch it so it supports bdist_wheel
	PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
elif [[ "$PACKAGE" == "Amara" ]]; then
	# need to patch it so it supports bdist_wheel
	PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
	PYTHON_IMPORT_NAME="amara"
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "pysqlite" ]]; then
	# need to patch it so it supports bdist_wheel
	PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
	PYTHON_IMPORT_NAME="pysqlite2"
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "python-lzo" ]]; then
	PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" -e "s;/usr/include;$NIXUSER_PROFILE/include;g" setup.py'
	PYTHON_IMPORT_NAME="lzo"
elif [[ "$PACKAGE" == "iptest" ]]; then
	PACKAGE_FOLDER_NAME="IPTest"
	PACKAGE_DOWNLOAD_NAME="IPTest"
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "sympy" ]]; then
	PYTHON_DEPS="mpmath"
elif [[ "$PACKAGE" == "cffi" ]]; then
	PYTHON_DEPS="pycparser"
elif [[ "$PACKAGE" == "ipaddress" ]]; then
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "pynacl" ]]; then
	PACKAGE_FOLDER_NAME="PyNaCl"
	PACKAGE_DOWNLOAD_NAME="PyNaCl"
	PYTHON_IMPORT_NAME="nacl"
elif [[ "$PACKAGE" == "functools32" ]]; then
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "MarkupSafe" ]]; then
	PYTHON_IMPORT_NAME="markupsafe"
elif [[ "$PACKAGE" == "pygame" ]]; then
	PRE_BUILD_COMMANDS="export LOCALBASE=$NIXUSER_PROFILE"
elif [[ "$PACKAGE" == "pyyaml" ]]; then
	PACKAGE_FOLDER_NAME="PyYAML"
	PACKAGE_DOWNLOAD_NAME="PyYAML"
	PYTHON_IMPORT_NAME="yaml"
elif [[ "$PACKAGE" == "pillow" ]]; then
	PYTHON_DEPS="olefile"
	PACKAGE_FOLDER_NAME="Pillow"
	PACKAGE_DOWNLOAD_NAME="Pillow"
	PYTHON_IMPORT_NAME="PIL"
elif [[ "$PACKAGE" == "pillow-simd" ]]; then
	PACKAGE_FOLDER_NAME="Pillow-SIMD"
	PACKAGE_DOWNLOAD_NAME="Pillow-SIMD"
	PRE_BUILD_COMMANDS="export CC=\"cc -mavx2\""
	PYTHON_IMPORT_NAME="PIL"
elif [[ "$PACKAGE" == "olefile" ]]; then
	# need to patch it so it supports bdist_wheel
	PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
elif [[ "$PACKAGE" == "fuel" ]]; then
	PYTHON_DEPS="numpy six picklable_itertools pyyaml h5py tables progressbar2 pyzmq scipy pillow numexpr"
elif [[ "$PACKAGE" == "seaborn" ]]; then
	PYTHON_DEPS="numpy scipy matplotlib pandas"
elif [[ "$PACKAGE" == "backports.functools-lru-cache" ]]; then
	PYTHON_IMPORT_NAME="backports.functools_lru_cache"
elif [[ "$PACKAGE" == "theano" ]]; then
	PACKAGE_FOLDER_NAME="Theano"
	PACKAGE_DOWNLOAD_NAME="Theano"
	PYTHON_DEPS="numpy scipy six"
elif [[ "$PACKAGE" == "alignlib-lite" ]]; then
	MODULE_BUILD_DEPS="boost"
elif [[ "$PACKAGE" == "torchvision" ]]; then
    # torch_cpu is only for testing purposes. It is not in torchvision requirements.
    # torchvision should be installed along with : torch-[cg]pu
	PYTHON_DEPS="numpy six pillow-simd torch-cpu"

    # Remove torch requirements from wheel as the user need to either install torch-[cg]pu wheel
    # Otherwise, it does not install because torchvision has a `torch` requirement, and no pypi version is supplied, thus failing.
    PATCH_WHEEL_COMMANDS="sed -i -e 's/Requires-Dist: torch//' torchvision-*.dist-info/METADATA; sed -i -e 's/, \"torch\"//' torchvision-*.dist-info/metadata.json"
elif [[ "$PACKAGE" == "Pillow" ]]; then
	PYTHON_IMPORT_NAME="PIL"
elif [[ "$PACKAGE" == "biopython" ]]; then
        PYTHON_DEPS="numpy"
        PYTHON_IMPORT_NAME="Bio"
elif [[ "$PACKAGE" == "torchtext" ]]; then
        # torch_cpu, six and numpy are only for testing purposes. They are not in torchtext requirements.
        # torchtext should be installed along with : numpy, six, torch-[cg]pu
        PYTHON_DEPS="certifi urllib3 chardet idna requests tqdm six numpy torch_cpu"
        
        # Remove torch requirements as the user need to either install torch-[cg]pu wheel and not PyPI torch.
        # Remove egg-info artefact as we are rebuilding a wheel.
        PRE_BUILD_COMMANDS="sed -i -e \"s/'torch',//g\" setup.py; rm -r torchtext.egg-info;"
elif [[ "$PACKAGE" == "wxPython" ]]; then
        MODULE_BUILD_DEPS="gtk+3/3.20.9"
        PYTHON_DEPS="six typing PyPubSub"
        PRE_BUILD_COMMANDS='export LDFLAGS=-Wl,-rpath,\$ORIGIN,-rpath,$EBROOTGTKPLUS3/lib'
        PYTHON_IMPORT_NAME="wx"
elif [[ "$PACKAGE" == "bz2file" ]]; then
        PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
elif [[ "$PACKAGE" == "smart_open" ]]; then
        PYTHON_DEPS="boto>=2.32 bz2file requests boto3"
elif [[ "$PACKAGE" == "gensim" ]]; then
        PYTHON_DEPS="numpy>=1.11.3 scipy>=0.18.1 six>=1.5.0 smart_open>=1.2.1"
elif [[ "$PACKAGE" == "preshed" ]]; then
        PYTHON_DEPS="cymem>=1.30,<1.32.0"
elif [[ "$PACKAGE" == "cytoolz" ]]; then
        PYTHON_DEPS="toolz>=0.8.0"
elif [[ "$PACKAGE" == "wrapt" ]]; then
        PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
elif [[ "$PACKAGE" == "msgpack-python" ]]; then
        PYTHON_IMPORT_NAME="msgpack"
elif [[ "$PACKAGE" == "thinc" ]]; then
        PYTHON_DEPS="cython>=0.25.0 numpy>=1.7.0 msgpack>=0.5.6,<1.0.0 msgpack-numpy==0.4.1 murmurhash>=0.28.0,<0.29.0 cymem>=1.30.0,<1.32.0 preshed>=1.0.0,<2.0.0 cytoolz>=0.9.0,<0.10 wrapt>=1.10.0,<1.11.0 plac>=0.9.6,<1.0.0 tqdm>=4.10.0,<5.0.0 six>=1.10.0,<2.0.0 hypothesis<3,>=2 dill>=0.2.7,<0.3.0 pathlib==1.0.1;python_version<'3.4'"
elif [[ "$PACKAGE" == "spacy" ]]; then
        PYTHON_DEPS="cython>=0.24,<0.28.0 numpy>=1.7 murmurhash>=0.28,<0.29 cymem<1.32,>=1.30 preshed>=1.0.0,<2.0.0 thinc>=6.10.3,<6.11.0 plac<1.0.0,>=0.9.6 ujson>=1.35 dill>=0.2,<0.3 regex==2017.4.5 requests>=2.13.0,<3.0.0 pathlib==1.0.1;python_version<'3.4'"
elif [[ "$PACKAGE" == "bigfloat" ]]; then
    PYTHON_DEPS="cython"
    PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
elif [[ "$PACKAGE" == "python-utils" ]]; then
    PYTHON_IMPORT_NAME="python_utils"
elif [[ "$PACKAGE" == "progressbar2" ]]; then
    PYTHON_IMPORT_NAME="progressbar"
elif [[ "$PACKAGE" == "fast5_research" ]]; then
    PYTHON_DEPS="numpy h5py"
elif [[ "$PACKAGE" == "sphinx-argparse" ]]; then
    PYTHON_IMPORT_NAME="sphinxarg"
elif [[ "$PACKAGE" == "jsonnet" ]]; then
    PYTHON_IMPORT_NAME="_jsonnet"
elif [[ "$PACKAGE" == "Unidecode" ]]; then
    PYTHON_IMPORT_NAME=""
elif [[ "$PACKAGE" == "python-jose" ]]; then
    PYTHON_IMPORT_NAME="jose"
elif [[ "$PACKAGE" == "pycryptodome" ]]; then
    PYTHON_IMPORT_NAME="Crypto"
elif [[ "$PACKAGE" == "pyproj" ]]; then
    PYTHON_IMPORT_NAME="pyproj"
    MODULE_BUILD_DEPS="proj geos"
elif [[ "$PACKAGE" == "pyshp" ]]; then
    PYTHON_IMPORT_NAME="shapefile"
elif [[ "$PACKAGE" == "basemap" ]]; then
    if [[ -z "$VERSION" ]]; then
        VERSION="1.2.0"
    fi
    if [[ "$VERSION" == "1.2.0" ]]; then
            PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/matplotlib/basemap/archive/v1.2.0rel.tar.gz"
            PACKAGE_DOWNLOAD_NAME="v1.2.0rel.tar.gz"
            PRE_BUILD_COMMANDS="sed -i \"s/__version__ = '1.1.0'/__version__ = '1.2.0'/\"  lib/mpl_toolkits/basemap/__init__.py"
    else
            PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/matplotlib/basemap/archive/v${VERSION}.tar.gz"
            PACKAGE_DOWNLOAD_NAME="v${VERSION}.tar.gz"
    fi
    PACKAGE_FOLDER_NAME="basemap-${VERSION}"
    MODULE_BUILD_DEPS="proj geos"
    PYTHON_DEPS="numpy matplotlib pyproj pyshp python-dateutil"
    PRE_DOWNLOAD_COMMANDS="export GEOS_DIR=${EBROOTGEOS} "
    PYTHON_IMPORT_NAME="mpl_toolkits.basemap"
elif [[ "$PACKAGE" == "MDAnalysis" ]]; then
    PYTHON_DEPS="gsd Cython joblib numpy mock GridDataFormats scipy matplotlib networkx biopython mmtf-python six duecredit"
elif [[ "$PACKAGE" == "MDAnalysisTests" ]]; then
    PYTHON_DEPS="MDAnalysis hypothesis pytest joblib pbr"
    # Generates py2.py3 wheel anyway
    PYTHON_VERSIONS="python/3.6"
elif [[ "$PACKAGE" == "attrs" ]]; then
    PYTHON_IMPORT_NAME="attr"
elif [[ "$PACKAGE" == "Cartopy" ]]; then
    MODULE_BUILD_DEPS="proj geos gdal"
    PYTHON_DEPS="Cython numpy shapely pyshp six Pillow pyepsg pykdtree scipy OWSLib"
    PYTHON_IMPORT_NAME="cartopy"
elif [[ "$PACKAGE" == "OWSLib" ]]; then
    PYTHON_IMPORT_NAME="owslib"
elif [[ "$PACKAGE" == "pykdtree" ]]; then
    MODULE_BUILD_DEPS="imkl"
    PYTHON_DEPS="numpy"
fi

DIR=tmp.$$
mkdir $DIR
pushd $DIR
module --force purge
module load nixpkgs gcc/7.3.0
for pv in $PYTHON_VERSIONS; do
	if [[ -n "$MODULE_BUILD_DEPS" ]]; then
		module load $MODULE_BUILD_DEPS
	fi
	if [[ -n "$MODULE_RUNTIME_DEPS" ]]; then
		module load $MODULE_RUNTIME_DEPS
	fi
	module load $pv
	module list

	if [[ $pv =~ python/2 ]]; then
		PYTHON_CMD=python2
	else
		PYTHON_CMD=python3
	fi
	PVDIR=${pv//\//-}

	echo "Setting up build environment"
	virtualenv build_$PVDIR || pyvenv build_$PVDIR
	source build_$PVDIR/bin/activate
	if [[ -n "$PYTHON_DEPS" ]]; then
		pip install $PYTHON_DEPS --find-links=$TMP_WHEELHOUSE
	fi
	pip freeze
	eval $PRE_DOWNLOAD_COMMANDS
	echo "Downloading source"
	mkdir $PVDIR
        # Do not collect binaries and don't install dependencies
        pip download --no-binary $PACKAGE_DOWNLOAD_ARGUMENT --no-deps $PACKAGE_DOWNLOAD_ARGUMENT
        if [[ $PACKAGE_DOWNLOAD_NAME =~ (.zip|.tar.gz|.tgz|.whl)$ ]]; then
                ARCHNAME="$PACKAGE_DOWNLOAD_NAME"
        else
                ARCHNAME=$(ls $PACKAGE_DOWNLOAD_NAME-[0-9]*{.zip,.tar.gz,.tgz,.whl})
        fi
        # skip packages that are already in whl format
        if [[ $ARCHNAME == *.whl ]]; then
                # Patch the content of the wheel file (eg remove `torch` dependency as torch
                # has no pypi wheel and we build [cg]pu wheel versions).
                if [[ -n "$PATCH_WHEEL_COMMANDS" ]]; then
                    unzip -o $ARCHNAME
                    eval $PATCH_WHEEL_COMMANDS
                    zip -u $ARCHNAME -r $PACKAGE $PACKAGE-*.dist-info
                fi
                cp $ARCHNAME ..
                continue
        fi
        unzip $ARCHNAME -d $PVDIR || tar xfv $ARCHNAME -C $PVDIR
        pushd $PVDIR
        pushd $PACKAGE_FOLDER_NAME*

        echo "Patching"
        for p in $PATCHES;
        do
            patch --verbose -p1 < $p
        done

	echo "Building"
	pwd
	ls
	module list
	which $PYTHON_CMD
	if [[ "$PACKAGE" == "numpy" ]]; then
		cat << EOF > site.cfg
[mkl]
library_dirs = $MKLROOT/lib/intel64
include_dirs = $MKLROOT/include
mkl_libs = mkl_rt
lapack_libs =
EOF
	fi
	eval $PRE_BUILD_COMMANDS
	# change the name of the wheel to add a suffix
	if [[ -n "$PACKAGE_SUFFIX" ]]; then
            sed -i -e "s/name='$PACKAGE'/name='$PACKAGE$PACKAGE_SUFFIX'/g" $(find . -name "setup.py")
	fi
	$PYTHON_CMD setup.py bdist_wheel $BDIST_WHEEL_ARGS |& tee build.log
	pushd dist || cat build.log
	WHEEL_NAME=$(ls *.whl)
	if [[ -n "$RPATH_TO_ADD" ]]; then
		echo "Running /cvmfs/soft.computecanada.ca/easybuild/bin/setrpaths.sh --path $WHEEL_NAME --add_path=$RPATH_TO_ADD --any_interpreter"
		/cvmfs/soft.computecanada.ca/easybuild/bin/setrpaths.sh --path $WHEEL_NAME --add_path $RPATH_TO_ADD --any_interpreter
	fi
	pwd
	ls
	cp -v $WHEEL_NAME $TMP_WHEELHOUSE
	popd
	popd
	popd

	echo "Testing..."
	if [[ -n "$MODULE_BUILD_DEPS" ]]; then
		module unload $MODULE_BUILD_DEPS
	fi
	module list
	pip install ../$WHEEL_NAME --no-cache --find-links=$TMP_WHEELHOUSE
	if [[ -n "$PYTHON_IMPORT_NAME" ]]; then
		$PYTHON_CMD -c "import $PYTHON_IMPORT_NAME; $PYTHON_TESTS"
	fi
	SUCCESS=$?
	deactivate
	if [[ $SUCCESS -ne 0 ]]; then
		echo "Error happened"
		cd ..
		exit $SUCCESS
	fi
done

popd

echo "Build done, you can now remove $DIR"
echo "If you are satisfied with the built wheel, you can copy them to /cvmfs/soft.computecanada.ca/custom/python/wheelhouse/[generic,avx2,avx,sse3] and synchronize CVMFS"
