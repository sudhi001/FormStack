#! /usr/bin/env bash
dart format lib/src/
git add . && git commit -m "feat:0.4.1 Release" 
git push -u origin main 
dart pub publish