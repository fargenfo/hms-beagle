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

