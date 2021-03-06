#!/bin/bash

if [ $# -ne 3 ]; then
  echo "usage: $0 <srcNamenode> <dstNamenode> <srcDir>"
  exit 1
fi

srcNamenode=$1
dstNamenode=$2
srcDir=$3
dstDir=/
mapTaskNum=50

time=`date +%Y%m%d%H%M%s`
dirName=`echo $srcDir | sed 's/\///g'`

mkdir -p full.$time/raw
./list.sh $srcNamenode $srcDir full.$time/raw/$dirName.tmp
shuf full.$time/raw/$dirName.tmp > full.$time/raw/$dirName

mkdir -p full.$time/split
./split.sh full.$time/raw/$dirName full.$time/split/$dirName $dirName $mapTaskNum

hdfsRoot=/tmp/fastcp/full.$time
hadoop fs -mkdir -p $hdfsRoot/copylist
hadoop fs -copyFromLocal full.$time/split/$dirName $hdfsRoot/copylist

hdfsCopyListDir=$hdfsRoot/copylist/$dirName
hdfsResultDir=$hdfsRoot/fastcp.result/$dirName
./fastcp.sh $hdfsCopyListDir $srcNamenode $dstNamenode $dstDir $hdfsResultDir FASTCOPY