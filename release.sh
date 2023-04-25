#! /usr/bin/env bash
dart format lib/src/
git add . && git commit -m "feat: more styles and nested step to show mutiple step in single view" && git push -u origin main 
dart pub publish