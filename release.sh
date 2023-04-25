#! /usr/bin/env bash
git add . && git commit -m "feat:0.4.0 Release" 
git push -u origin main 
dart pub publish