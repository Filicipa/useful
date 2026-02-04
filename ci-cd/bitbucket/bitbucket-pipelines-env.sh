#!/bin/sh

STAGE=$(echo $BITBUCKET_BRANCH | cut -d'/' -f2)
echo "Stage: $STAGE"

export STAGE