REM Download Cygwin installer
powershell wget http://cygwin.com/setup-x86_64.exe -OutFile setup-x86_64.exe
setup-x86_64.exe -s http://ftp.iij.ad.jp/pub/cygwin -R %~dp0\cyg64 -l %~dp0\cache64 -B -v -q -N -d -g -P cmake,git,gcc,make,gcc-g++,automake,autoconf,libtool,libgmp-devel,libonig-devel,flex,gettext-devel,pkg-config,libunistring-devel,libffi-devel,libgc-devel,texinfo,zlib-devel
