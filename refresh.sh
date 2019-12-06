#!/usr/bin/env /bin/bash
#
# Read list of github repos with cross-builds in JVM and ScalaJS
# from xbuildrepos.txt, git clone or git pull on repos as needed,
# and build API docs with sbt.
# Copy resulting API docs from the jvm branch's 2.12 directory
# into the corresponding ghpages directory.
# Write a time-stamped index file in the root of the ghpages directory.
#
# Requirements:  sbt, git, POSIX.
#
export GIT=`which git`
export SED=`which sed`
export PWD=`which pwd`
export LS=`which ls`
export CP=`which cp`
export SBT=`which sbt`
export DATE=`which date`
export CAT=`which cat`
export RM=`which rm`

export DOCSSUBDIR=jvm/target/scala-2.12/api
export ROOT=`pwd`

for REPO in $(cat xbuildrepos.txt) ; do
  echo $REPO
  DIR=`$SED "s#https://github.com/[A-Za-z]*/##" <<<"$REPO"`
  if [ ! -d $DIR ]
  then
    echo "Cloning " $REPO "... "
    $GIT clone $REPO
  fi
  echo "Pulling and building in " $ROOT/$DIR
  (cd $ROOT/$DIR && $GIT pull &&  $SBT doc)
  #(cd $ROOT/$DIR && exec echo "After cd $ROOT/$DIR, working in "`$PWD`)

  cd $ROOT
  export APIDOCS=$DIR/$DOCSSUBDIR
  #echo "APIDOCS IS " $APIDOCS
  printf "\n"
  echo $CP " -r" $APIDOCS  docs/$DIR
  $CP -r $APIDOCS docs/$DIR
  printf "\n\n"
done;

export STAMPED=`date`
printf "## CITE architecture libraries: version numbers and API documentation\n\nLast updated: $STAMPED\n\n" > header.md
$CAT header.md links.md > docs/index.md
$RM header.md

export MSG="Committing automatically generated API docs."


echo "Committing and pushing..."
$GIT add docs
$GIT commit -m "$MSG"
$GIT push
