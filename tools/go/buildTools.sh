#! /bin/bash
if [ ! -d "linuxbin" ]; then
  mkdir linuxbin
fi
if [ ! -d "osxbin" ]; then
  mkdir osxbin
fi
if [ ! -d "winbin" ]; then
  mkdir winbin
fi

env GOOS=linux   GOARCH=amd64 go build  -o linuxbin   -ldflags "-X main.gitRepo=`git config --get remote.origin.url` -X main.compileDate=`date -u +%Y%m%d.%H%M%S` -X main.gitHash=`git rev-parse --verify HEAD` -X main.gitBranch=`git branch | grep \* | cut -d ' ' -f2`" salsanci.com/propforth/src/goterm
env GOOS=darwin  GOARCH=amd64 go build -o osxbin     -ldflags "-X main.gitRepo=`git config --get remote.origin.url` -X main.compileDate=`date -u +%Y%m%d.%H%M%S` -X main.gitHash=`git rev-parse --verify HEAD` -X main.gitBranch=`git branch | grep \* | cut -d ' ' -f2`" salsanci.com/propforth/src/goterm
env GOOS=windows GOARCH=amd64 go build -o winbin     -ldflags "-X main.gitRepo=`git config --get remote.origin.url` -X main.compileDate=`date -u +%Y%m%d.%H%M%S` -X main.gitHash=`git rev-parse --verify HEAD` -X main.gitBranch=`git branch | grep \* | cut -d ' ' -f2`" salsanci.com/propforth/src/goterm

env GOOS=linux   GOARCH=amd64 go build  -o linuxbin   -ldflags "-X main.gitRepo=`git config --get remote.origin.url` -X main.compileDate=`date -u +%Y%m%d.%H%M%S` -X main.gitHash=`git rev-parse --verify HEAD` -X main.gitBranch=`git branch | grep \* | cut -d ' ' -f2`" salsanci.com/propforth/src/gocmd
env GOOS=windows GOARCH=amd64 go build -o winbin     -ldflags "-X main.gitRepo=`git config --get remote.origin.url` -X main.compileDate=`date -u +%Y%m%d.%H%M%S` -X main.gitHash=`git rev-parse --verify HEAD` -X main.gitBranch=`git branch | grep \* | cut -d ' ' -f2`" salsanci.com/propforth/src/gocmd
