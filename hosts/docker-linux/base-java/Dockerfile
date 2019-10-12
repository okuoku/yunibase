FROM fedora:latest
WORKDIR /build

# Install required packages:
#
#  buildsystem: cmake gcc g++
#  Kawa: make gcc findutils texinfo automake java-1.8.0-openjdk-devel
RUN dnf update -y && dnf install -y \
cmake gcc g++ \
make findutils texinfo automake java-1.8.0-openjdk-devel
