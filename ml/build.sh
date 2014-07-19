#!/bin/sh
npm install
$(npm bin)/jison grammer.jison
$(npm bin)/coffee -o . ml.coffee
