FROM ubuntu:bionic

# Set locales to UTF-8.
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
# Avoid apt-get asking too many questions.
ENV DEBIAN_FRONTEND=noninteractive

LABEL \
    authors="olavur@fargen.fo" \
    description="Ubuntu Bionic image to serve as an interactive environment for bioinformatics." \
    maintainer="Olavur Mortensen <olavur@fargen.fo>" \
    captain="Robert FitzRoy"


# Install some software.

# Add repo for r-base 4.0.
RUN apt-get update -yqq && apt-get install -yqq gnupg apt-transport-https software-properties-common
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
    add-apt-repository -y 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran40/'

# Install all sorts of stuff.
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
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    musl-dev \
    dos2unix \
    libcurl4-openssl-dev \
    ghostscript-x \
    python3-venv

# Install RStudio Server.
RUN apt-get update -yqq && apt-get install -yqq gdebi-core && \
    wget --quiet https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.2.5001-amd64.deb && \
    gdebi -n rstudio-server-1.2.5001-amd64.deb && \
    rm rstudio-server-1.2.5001-amd64.deb

# Configure RStudio Server to run on 0.0.0.0/80.
RUN echo "www-port=81" >> /etc/rstudio/rserver.conf
RUN echo "www-address=0.0.0.0" >> /etc/rstudio/rserver.conf

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

# Miniconda3 installation taken directly from continuumio/miniconda3 on DockerHub:
# https://hub.docker.com/r/continuumio/miniconda3/dockerfile
RUN apt-get update --fix-missing && \
    apt-get install -y bzip2 ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc

# Make a folder for the conda executable and add it to the path.
# NOTE: "conda init" usually does this, but I can't find a way to run that command in a Dockerfile.
# NOTE: if I add /opt/conda/bin to path, the conda python executable is in the path, which is not desirable.
RUN mkdir /opt/conda/condabin && \
    cp /opt/conda/bin/conda /opt/conda/condabin
ENV PATH /opt/conda/condabin:$PATH

# Update conda.
# NOTE: this Dockerfile will have different versions of conda depending on build time.
RUN conda update -n base -c defaults conda -y

# Install the hms-beagle conda environment defined in the YAML file.
# Copy file to image.
COPY environment.yml /
# Create environment, installing dependencies.
RUN conda env create -f /environment.yml && conda clean -a
# Remove YAML file from image.
RUN rm /environment.yml

# Append this command to the bashrc to activate the hms-beagle environment
# on startup.
RUN echo "conda activate hms-beagle" >> ~/.bashrc

# Configure Jupyter.
# Normally, you would run this command:
# jupyter lab -generate-config
# To make the .jupyter folder in the home folder (~) , and create the
# template config file "jupyter_lab_config.py".
# Create the jupyter user directory.
RUN mkdir /root/.jupyter
# Copy the custom config file to the image.
COPY jupyter_lab_config.py /root/.jupyter

# Add tmux config.
# This maps the prefix to Ctrl+a. The default Ctrl+b prefix is problematic,
# as it clashes with various other shortcuts when working in a browser in Jupyter.
COPY tmux.conf /root/.tmux.conf

# Install Node.js and npm.
# Installation instructions:
# https://github.com/nodesource/distributions/blob/master/README.md#installation-instructions
# Update GPG key first.
RUN sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get update -yqq && \
    apt-get install -yqq nodejs

# Download IGV Web App release from GitHub.
RUN wget --quiet https://github.com/igvteam/igv-webapp/archive/1.3.0.tar.gz
RUN tar xzf 1.3.0.tar.gz
RUN rm 1.3.0.tar.gz

# Build IGV Web App NPM package.
WORKDIR igv-webapp-1.3.0
RUN npm install
RUN npm run build
WORKDIR /root

# Install Rancher v2.2.
# Rancher website: https://rancher.com/
# The executable is placed in /opt/rancher and this folder is added to path.
RUN mkdir /opt/rancher
WORKDIR /opt/rancher
RUN wget --quiet https://releases.rancher.com/cli2/v2.2.0/rancher-linux-amd64-v2.2.0.tar.gz && \
    tar zxf rancher-linux-amd64-v2.2.0.tar.gz && \
    mv rancher-v2.2.0/rancher . && \
    rm -r rancher-v2.2.0 rancher-linux-amd64-v2.2.0.tar.gz
ENV PATH /opt/rancher:$PATH
WORKDIR /root

# Install kubectl v1.21.0.
# The executable is placed in /opt/rancher and this folder is added to path.
# To get the latest release version number, run this command:
# curl -L -s https://dl.k8s.io/release/stable.txt
RUN mkdir /opt/kubectl
WORKDIR /opt/kubectl
RUN curl -LOs "https://dl.k8s.io/release/v1.21.0/bin/linux/amd64/kubectl" && \
    chmod +x kubectl
ENV PATH /opt/kubectl:$PATH
WORKDIR /root

# Run the entrypoint script, which starts jupyter and initializes tini.
COPY entrypoint.sh /run
RUN chmod +x /run/entrypoint.sh
ENTRYPOINT /run/entrypoint.sh

# NOTE: Normally it would be a good idea to run bash here like this:
#CMD [ "/bin/bash" ]
# However, because of my entrypoint script above, this seems to have no effect.
