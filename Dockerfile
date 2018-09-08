# xArch Orthanc Release Image
# Derek Merck, Summer 2018

ARG RESIN_ARCH="intel-nuc"

FROM resin/${RESIN_ARCH}-debian:stretch
MAINTAINER Derek Merck <derek_merck@brown.edu>

RUN apt update  \
    && apt install -y --no-install-recommends \
      git \
      build-essential \
      unzip \
      cmake \
      mercurial \
      uuid-dev \
      libcurl4-openssl-dev \
      liblua5.1-0-dev \
      libgtest-dev \
      libpng-dev \
      libjpeg-dev \
      libsqlite3-dev \
      libssl1.0-dev \
      zlib1g-dev \
      libdcmtk2-dev \
      libboost-all-dev \
      libwrap0-dev \
      libjsoncpp-dev \
      libpugixml-dev \
      libgdcm-tools \
    && apt-get clean

ARG ORX_BRANCH="master"
#ARG ORTHANC_BRANCH="Orthanc-1.3.2"

# Get the number of available cores to speed up the builds
RUN COUNT_CORES=`grep -c ^processor /proc/cpuinfo` \
    && echo "Will use $COUNT_CORES parallel jobs to build Orthanc"

RUN hg clone 'https://bitbucket.org/sjodogne/orthanc' '-r' $ORX_BRANCH '/opt/orthanc/source' \
    && mkdir '/opt/orthanc/build' \
    && chdir '/opt/orthanc/build' \
    && cmake -DALLOW_DOWNLOADS=ON \
          -DUSE_SYSTEM_MONGOOSE=OFF \
          -DUSE_GOOGLE_TEST_DEBIAN_PACKAGE=ON \
          -DDCMTK_LIBRARIES=dcmjpls \
#          -DSTATIC_BUILD=ON \
          -DCMAKE_BUILD_TYPE=Release \
          /opt/orthanc/source \
    && make -j$COUNT_CORES \
    && make install \
    && mkdir /var/lib/orthanc \
    && mkdir /etc/orthanc

COPY orthanc.json /etc/orthanc

RUN hg clone 'https://bitbucket.org/sjodogne/orthanc-postgresql' '/opt/orthanc-postgresql/source' \
    && mkdir '/opt/orthanc-postgresql/build' \
    && chdir '/opt/orthanc-postgresql/build' \
    && cmake -DALLOW_DOWNLOADS=ON \
          -DUSE_GOOGLE_TEST_DEBIAN_PACKAGE=ON \
          -DUSE_SYSTEM_JSONCPP:BOOL=OFF \
          /opt/orthanc-postgresql/source \
    && make -j$COUNT_CORES

RUN mkdir -p /usr/share/orthanc/plugins
RUN cp libOrthancPostgreSQLIndex.so   /usr/share/orthanc/plugins/
RUN cp libOrthancPostgreSQLStorage.so /usr/share/orthanc/plugins/

VOLUME /var/lib/orthanc/db/

EXPOSE 8042 4242

ENV TZ=America/New_York
# Disable resin.io's systemd init system
ENV INITSYSTEM off

CMD /usr/local/sbin/Orthanc /etc/orthanc/orthanc.json
