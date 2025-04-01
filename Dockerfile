# This Dockerfile is intended to add IBM's ACS to a ppc64le xfce x11docker image

FROM smanceau44/xfce

# Warn builder about mandatory dependencies
RUN echo "/!\  Please provide IBM's ACS IBMiAccess_v1r1.zip in build directory" && \
  echo "/!\  Or press Ctrl-C now to exit (waiting 60s)" && \
  sleep 60

# Install some packages
RUN echo "deb http://debian.mirrors.ovh.net/debian bullseye main" > /etc/apt/sources.list && \
    echo "deb http://debian.mirrors.ovh.net/debian-security bullseye-security main" >> /etc/apt/sources.list && \
    echo "deb http://debian.mirrors.ovh.net/debian bullseye-updates main" >> /etc/apt/sources.list && \
    echo "deb-src http://debian.mirrors.ovh.net/debian bullseye main" >> /etc/apt/sources.list && \
    apt-get update && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      default-jdk \
      firefox-esr \
      dialog

# Copy and unpack ACS source into our working environment
COPY IBMiAccess_v1r1.zip /tmp/
RUN mkdir /tmp/acs && cd /tmp/acs && jar -xf /tmp/IBMiAccess_v1r1.zip && rm /tmp/IBMiAccess_v1r1.zip

# Customization steps
RUN cd /tmp/acs/ && \
    cp AcsConfig.properties AcsConfig_org.properties && \
    echo "com.ibm.iaccess.InstallType=preset" >> /tmp/acs/AcsConfig.properties && \
    echo "com.ibm.iaccess.IncludeComps=console,vcp,hmc," >> /tmp/acs/AcsConfig.properties && \
    echo "com.ibm.iaccess.autoimport={HOME}/x11docker_share/acs_bak.zip" >> /tmp/acs/AcsConfig.properties && \
    echo "com.ibm.iaccess.autoimport.version=*" >> /tmp/acs/AcsConfig.properties && \
    echo "com.ibm.iaccess.splf.FilterRestricted=true" >> /tmp/acs/AcsConfig.properties && \
    echo "com.ibm.iaccess.desktopshortcuts=yes" >> /tmp/acs/AcsConfig.properties && \
    echo "com.ibm.iaccess.InstallType=preset" >> /tmp/acs/AcsConfig.properties

# Run the setup programm
RUN cd /tmp/acs/Linux_Application && chmod +x ./install_acs_xx && ./install_acs_xx /Q

# Cleanup our room
RUN cd && rm -rf /tmp/acs/
