# Version: 0.0.1 - WebRTC ready Certified Asterisk 13.13-cert2 with sip and pjsip channels
FROM centos:latest
MAINTAINER Pedro Howat "pedro.howat@gmail.com"
RUN yum -y update
RUN yum -y install tar gcc gcc-c++ make wget subversion libxml2-devel ncurses-devel openssl-devel sqlite-devel libuuid-devel jansson-devel unixODBC unixODBC-devel libtool-ltdl libtool-ltdl-devel subversion speex-devel mysql-devel openssl epel-release
RUN yum -y install libsrtp-devel uuid-devel sqlite-devel libxml2-devel ncurses-devel gsm-devel libuuid-devel

WORKDIR /usr/src
RUN svn co http://svn.pjsip.org/repos/pjproject/trunk/ pjproject-trunk
WORKDIR /usr/src/pjproject-trunk
RUN touch pjlib/include/pj/config_site.h
RUN echo "#define PJSIP_MAX_PKT_LEN 8000" > pjlib/include/pj/config_site.h
RUN ./configure --libdir=/usr/lib64 --prefix=/usr --enable-shared --disable-sound --disable-resample --disable-video --disable-opencore-amr CFLAGS='-O2 -DNDEBUG'
RUN make dep
RUN make
RUN make install
RUN ldconfig
RUN ldconfig -p | grep pj
WORKDIR /usr/src
RUN wget http://downloads.asterisk.org/pub/telephony/certified-asterisk/asterisk-certified-13.13-current.tar.gz
RUN tar -zxvf asterisk-certified-13.13-current.tar.gz
WORKDIR /usr/src/asterisk-certified-13.13-cert2
RUN sh contrib/scripts/get_mp3_source.sh
COPY menuselect.makeopts /usr/src/asterisk-certified-13.13-cert2/menuselect.makeopts
RUN ./configure CFLAGS='-g -O2 -mtune=native' --libdir=/usr/lib64
RUN make
RUN make install
RUN make samples
WORKDIR /root
CMD ["/usr/sbin/asterisk", "-vvvvvvv"]
