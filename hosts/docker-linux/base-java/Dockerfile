FROM java:openjdk-8-jdk
WORKDIR /build

# Install required packages:
#
#  buildsystem: cmake gcc g++
#  NMosh(stable): libgmp-dev libonig-dev
#  Kawa: ant
RUN apt-get update && apt-get install -y \
cmake gcc g++ \
libgmp-dev libonig-dev \
ant
