#!/bin/bash

# Start Jupyter.
# If the JUPYTER_SERVER_CONFIG environment variable points to a valid config file, this will be used. If either
# the variable doesn't exist, or points to a non-existing file, then default configuration is used.
/opt/conda/envs/hms-beagle/bin/jupyter lab --config=`ls $JUPYTER_SERVER_CONFIG` &

# FIXME: I'm not 100% sure if this is the correct initialization of tini. In the Dockerfile, the way
# to do it is like this:
#ENTRYPOINT [ "/usr/bin/tini", "--" ]
# But in order to run the command here, I need to supply some command after the hyphens (--) and need
# to register as a subreaper with -s.

# tini cleans up dead processes in the container. Dead processes can lead to clutter and eventually
# kernel crashing.
/usr/bin/tini -s -- /bin/bash

