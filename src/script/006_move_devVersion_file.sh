#!/bin/sh

if [ -e $PRJROOT/src/update/.development_revision ]; then
	mv -f $PRJROOT/src/update/.development_revision $PRJROOT/src/firmware/.development_revision
fi
