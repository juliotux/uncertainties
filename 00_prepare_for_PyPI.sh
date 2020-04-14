#!/bin/sh

# This script prepares the package for PyPI. It must be run
# before uploading it on PyPI.

# This script must be run from its directory.

# WARNING: this script erases any uncertainties-py23 and uncertainties-py27
# found in the current directory.

# Fail the script at the first failed command:
set -e 

echo "****************************************************************"
echo "WARNING: if any commit fails, RESOLVE IT before running this"
echo "script again. Otherwise conflict marks will be committed by the"
echo "second run!"
echo "****************************************************************"

## Only committed versions are packaged, to help with debugging published code:
git commit -a

# We make sure that the release and master branches are merged (changes
# may have been made on both sides):
git checkout master
git merge release

git checkout release
git merge master

# The Python 2.3-2.5 version should always be up to date:
git checkout release_python2.3
git merge release

# Default branch for working on the code:
git checkout release

## Getting the Python 2.7+ version:

rm -rf uncertainties-py27
git archive --output /tmp/u.tar release uncertainties
tar -C /tmp -xf /tmp/u.tar
mv /tmp/uncertainties uncertainties-py27
echo "Python 2.7+ version imported"

## Getting the Python 2.3 version:

rm -rf uncertainties-py23
git archive --output /tmp/u.tar release_python2.3 uncertainties
tar -C /tmp -xf /tmp/u.tar
mv /tmp/uncertainties uncertainties-py23
echo "Python 2.3 version imported"

# Packaging. We include wheels because it makes it easier to install,
# in some cases (https://github.com/lebigot/uncertainties/pull/108,
# https://discourse.slicer.org/t/problems-installing-lmfit-python-package/9210/6):
python setup.py sdist bdist_wheel
echo "Package created.  The package can be uploaded with twine upload dist/...*"
echo "where ...* is the new versions."
echo "WARNING: current git branch is:"
git branch | grep '^\*'
