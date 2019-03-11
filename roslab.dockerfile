FROM nvidia/opengl:1.0-glvnd-runtime-ubuntu16.04

################################## JUPYTERLAB ##################################

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN apt-get -o Acquire::ForceIPv4=true update && apt-get -yq dist-upgrade \
 && apt-get -o Acquire::ForceIPv4=true install -yq --no-install-recommends \
	locales cmake git build-essential \
    python-pip \
	python3-pip python3-setuptools \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN pip3 install jupyterlab==0.35.4 bash_kernel==0.7.1 tornado==5.1.1 \
 && python3 -m bash_kernel.install

ENV SHELL=/bin/bash \
	NB_USER=jovyan \
	NB_UID=1000 \
	LANG=en_US.UTF-8 \
	LANGUAGE=en_US.UTF-8

ENV HOME=/home/${NB_USER}

RUN adduser --disabled-password \
	--gecos "Default user" \
	--uid ${NB_UID} \
	${NB_USER}

EXPOSE 8888

CMD ["jupyter", "lab", "--no-browser", "--ip=0.0.0.0", "--NotebookApp.token=''"]

##################################### APT ######################################

RUN apt-get -o Acquire::ForceIPv4=true update \
 && apt-get -o Acquire::ForceIPv4=true install -yq --no-install-recommends \
    libvtk6.2 libvtk6-dev \
    unzip \
    libflann-dev \
    wget \
    mercurial \
    python-numpy \
    freeglut3 freeglut3-dev \
    libglew1.5 libglew1.5-dev \
    libglu1-mesa libglu1-mesa-dev libgl1-mesa-glx libgl1-mesa-dev \
    libxmu-dev libxi-dev \
    libboost-all-dev \
    cvs \
    libgoogle-glog-dev \
    libatlas-base-dev \
    gfortran \
    gtk2.0 libgtk2.0-dev \
    libproj9 libproj-dev \
    libyaml-0-2 libyaml-dev libyaml-cpp-dev \
    libhdf5-dev libhdf5-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

##################################### COPY #####################################

RUN mkdir ${HOME}/slambench2

COPY . ${HOME}/slambench2

################################### CUSTOM #####################################

RUN cd $HOME/slambench2 \
 && make deps \
 && make

##################################### TAIL #####################################

RUN chown -R ${NB_UID} ${HOME}

USER ${NB_USER}

WORKDIR ${HOME}/slambench2
