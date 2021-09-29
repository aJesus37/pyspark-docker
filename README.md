# pyspark-docker
Docker container that have pyspark and jupyter pre-configured


## Build

cd pyspark-docker

`docker build -t pyspark-docker .`


## Run

`docker run -it --name pyspark-docker --net=host pyspark-docker`

**Detail:** I've used `--net=host` above, but you can also use `-p 8888:8888` to let only jupyter-lab UI be shareable on your host.