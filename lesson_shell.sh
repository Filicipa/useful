#!/bin/bash
for i in {1..10}; do echo "stdout: $i"; echo "stderr: $i" >&2; done >stdout.log 2>stderr.log
