#!/bin/bash

yarn install
export NODE_ENV=production
npm run pack
npm run build linux
npm run build darwin
