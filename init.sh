#/bin/sh

set -eo pipefail

GRAPHS_DIR=${1:-~/graphs}
MATRICES_DIR=${2:-~/matrices}
GRAPHALYTICS_VERSION=1.8.0
PROJECT_VERSION=0.1-SNAPSHOT
PROJECT=graphalytics-$GRAPHALYTICS_VERSION-graphblas-$PROJECT_VERSION

# cleanup previously compiled wrapper artifacts
rm -rf bin/exe

rm -rf $PROJECT
mvn package
tar xf $PROJECT-bin.tar.gz
cd $PROJECT/

cp -r config-template config
# set directories
sed -i.bkp "s|^graphs.root-directory =$|graphs.root-directory = $GRAPHS_DIR|g" config/benchmark.properties
sed -i.bkp "s|^graphs.validation-directory =$|graphs.validation-directory = $GRAPHS_DIR|g" config/benchmark.properties
# set the number of threads to use
sed -i.bkp "s|^platform.graphblas.num-threads =$|platform.graphblas.num-threads = $(nproc --all)|g" config/platform.properties

bin/sh/compile-benchmark.sh

if [ -d $MATRICES_DIR ]; then
	bin/sh/link-matrix-market-graphs.sh $MATRICES_DIR
fi
