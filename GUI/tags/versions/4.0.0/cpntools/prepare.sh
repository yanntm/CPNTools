#!/bin/bash
./ReplaceVistaIcon.exe ./cpntools.exe images/logo.ico
chmod a+rwx cpntools.exe
./upx.exe ./cpntools.exe
