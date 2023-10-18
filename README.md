# Docker-based Smapp with Xpra GUI

This will build Smapp from source (see building below) and create a docker image based on [ubuntu](https://hub.docker.com/_/ubuntu/) with the linux package installed. The Ubuntu image runs an [Xpra](https://xpra.org/) server, which allows remote access to the Smapp GUI.

Notes:

* This mode of running Smapp is **not officially supported**! (Use only if you know what you're doing.)
* Currently, the dockerized Smapp version **does not auto-update**. This means you must manually update when a new version of Smapp is released (or your node may stop working correctly). 
* This version was only tested with Nvidia GPUs. 

## Building and Updating

* For a first build, 
  
  - run, in the current directory:
    
        cp sample-env .env
  
  - Optionally, Edit the  `SMESH_HOST_DATA_PATH` in `.env`.  This will determine where the smapp and node data is stored.

* Edit the `SMAPP_VERSION` in `.env` to reflect the [latest smapp version](https://github.com/spacemeshos/smapp/releases).

* Run:
  
      docker compose build
  
  This will clone the [smapp repository](https://github.com/spacemeshos/smapp) from Github, install nodejs (in the docker container), build  smapp from source, then install the `.deb` package in a new container.

## Running

* Run: 
  
      docker compose up -d
  
  This will start smapp, storing the data as specified in the `.env` variable `SMESH_HOST_DATA_PATH`. Note that the directory specified will be mapped to `/home/spacemesh/` inside the container.

* Connect to the gui by running an Xpra client on the *host*.  If you're running on the same host as the docker engine, run 
  
         xpra attach tcp://localhost:6070