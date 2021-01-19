# Second Voyage of HMS Beagle

On the 27th of December 1831, the HMS Beagle embarked on its _Second Voyage_. Onboard the sloop was the young Charles Darwin, who set out on a journey that would define his career. By deploying `hms-beagle:second-voyage` we too shall embark on a journey, a journey of biology and computation.

<img src="https://raw.githubusercontent.com/olavurmortensen/hms-beagle/master/images/PSM_V57_D097_Hms_beagle_in_the_straits_of_magellan.png" width=500>

## Usage

### Running the container

Pull the HMS Beagle image from DockerHub.

```bash
sudo docker pull olavurmortensen/hms-beagle:second-voyage
```

Deploy a container with this image.

```bash
sudo docker run -it -p80:80 hms-beagle:second-voyage
```

Then from the container command-line, run Jupyter:
```bash
jupyter lab
```

The Jupyter Lab server is now running on IP `0.0.0.0` on port `80`. Go to `0.0.0.0` in your browser and type in the token (shown in the log of the command above).

For information about how to use Jupyter, [read the docs](https://jupyterlab.readthedocs.io/en/stable/index.html).

### Build image from source

Download source code.

```bash
git clone https://github.com/olavurmortensen/hms-beagle.git
```

Build Docker image.

```bash
cd hms-beagle
sudo docker build -t hms-beagle .
```

Run container.

```bash
sudo docker run -it -p80:80 hms-beagle
```

Proceed as in the previous section.

## Software

This section lists various software available in the image, and how they are set up.

### Conda

The [conda](https://docs.conda.io/en/latest/miniconda.html) package manager is installed via Miniconda. By default the `hms-beagle` conda environment, which is defined in the [environment.yml](https://github.com/olavurmortensen/hms-beagle/blob/master/environment.yml) file, is activated in the container.

### tmux

The [tmux](https://github.com/tmux/tmux/wiki) terminal multiplexer is installed, and configured in the [tmux.conf](https://github.com/olavurmortensen/hms-beagle/blob/master/tmux.conf) file. While usually the prefix used in tmux is `Ctrl+B`, this is changed to `Ctrl+A`, to avoid clash with browser and Jupyter shortcuts.

### Vim

The [Vim](https://www.vim.org/) text editor is installed, and is configured using the [vimrc](https://github.com/olavurmortensen/hms-beagle/blob/master/vimrc) file. The configuration adds syntax highlighting, among other things.

### Jupyter

[Jupyter Lab]() is installed via to the `hms-beagle` conda environment, and configured in the [jupyter_lab_config.py](https://github.com/olavurmortensen/hms-beagle/blob/master/jupyter_lab_config.py) file.

The configuration ensures that Jupyter is runnable in the container, which means the IP used is `0.0.0.0`, the port is `80`, and `--allow-root` is `True`.

The `nb_conda_kernels` package is installed to the `hms-beagle` environment, such that you can switch between Python kernels, if you have multiple conda environments with Jupyter Lab installed.

### RStudio Server

[RStudio Server](https://rstudio.com/products/rstudio/download-server/) is installed on the image. To run RStudio you need to follow the instructions below.

Run the container, and add a new user.

```
useradd [ username ]
```

Make a password for this new user:

```
passwd [ username ]
```

Then give this user rights to your working directory, for example where your data is:

```
chown -R [ username ] [ data/workdir path ]
```

Now start the RStudio Server service.

```
rstudio-server start
```

Access RStudio in the browser via `0.0.0.0:80`.
