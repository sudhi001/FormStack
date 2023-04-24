#! /usr/bin/env bash
git add .
git commit -m "Stable implementation" 
git push -u origin main 
dart pub publish