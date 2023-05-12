#! /usr/bin/env bash
dart format lib/src/
git add . && git commit -m "RELEASE" && git push -u origin main 
dart pub publish