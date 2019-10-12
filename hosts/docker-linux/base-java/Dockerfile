FROM openjdk:8-jdk-stretch
WORKDIR /build

# Install required packages:
#
#  buildsystem: cmake gcc g++
#  NMosh(stable): libgmp-dev libonig-dev
#  Kawa: ant automake texinfo (Do we still need ant??)
RUN apt-get update && apt-get install -y \
cmake gcc g++ \
libgmp-dev libonig-dev \
ant automake texinfo
