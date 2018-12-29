#! /usr/bin/env bash

git push origin master
hexo g
cp -r raw/* public/
hexo d
