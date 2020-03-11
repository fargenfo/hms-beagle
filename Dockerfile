FROM ubuntu:bionic

# Set locales to UTF-8.
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
# Add conda (installed later) to path.
ENV PATH /opt/conda/bin:$PATH
# Avoid apt-get asking too many questions.
ENV DEBIAN_FRONTEND=noninteractive

LABEL \
    authors="olavur@fargen.fo" \
    description="Ubuntu Bionic image to serve as an interactive environment for bioinformatics." \
    maintainer="Olavur Mortensen <olavur@fargen.fo>" \
    captain="Robert FitzRoy"


# Install some software.
RUN apt-get update -yqq && \
    apt-get install -yqq \
    systemd \
    parallel \
    python \
    htop \
    wget \
    curl \
    unzip \
    tmux \
    tmuxp \
    vim \
    nano \
    less \
    tree \
    git \
    r-base \
    ttf-dejavu \
    make \
    perl \
    gcc \
    g++ \
    libncurses5-dev \
    zlib1g-dev \
    libmath-random-perl \
    libinline-perl \
    musl-dev

# Miniconda3 installation taken directly from continuumio/miniconda3 on DockerHub:
# https://hub.docker.com/r/continuumio/miniconda3/dockerfile
RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc
# NOTE:
# The Miniconda3 recipe from DockerHub does "conda activate base":
#echo "conda activate base" >> ~/.bashrc
# But I don't think this is a good idea.

# TODO: install RStudio server. Maybe.
## Install RStudio Server.
#RUN apt install -yqq gdebi-core && \
#    wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.2.5001-amd64.deb && \
#    gdebi rstudio-server-1.2.5001-amd64.deb

# Set up git user info.
RUN git config --global user.email "olavurmortensen@gmail.com" && git config --global user.name "Ólavur Mortensen"

# Append bashrc_extra to /root/.bashrc.
# /root is the equivalent of home.
WORKDIR /root
ADD bashrc_extra .
RUN cat bashrc_extra >> .bashrc && rm bashrc_extra
WORKDIR /

# Set up Vim configuration.
# /root is the equivalent of home.
WORKDIR /root
# Download Tim Pope's "pathogen" from https://github.com/tpope/vim-pathogen.
RUN mkdir -p .vim/autoload .vim/bundle && \
    curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
# Add the vimrc configuration.
ADD vimrc /root
RUN mv vimrc .vimrc
WORKDIR /

ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

# NOTE: if I have an environment.yml and want to create a conda env:
#COPY environment.yml /
#RUN conda env create -f /environment.yml && conda clean -a
#ENV PATH /opt/conda/envs/[name of env goes here]/bin:$PATH

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
