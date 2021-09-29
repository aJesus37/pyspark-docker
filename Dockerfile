# Set base image as debian 10 Buster
FROM debian:10
# Set default user and password
ENV username user
ENV password UserPasswd!
# Maintainer nick
LABEL maintainer="aJesus37 ajesus37@protonmail.com"
# Supresses some warnings during package update/install phase
ENV DEBIAN_FRONTEND noninteractive
# Set the workdir to the root's home
WORKDIR /root
# Set default shell for docker build
SHELL ["/bin/bash", "-c"]
# Set correct Timezone (For me :D)
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# Update packages on OS
RUN apt update && apt dist-upgrade -yqq
# Install dependencies
RUN apt install tmux sudo software-properties-common python3 python3-pip python3-pandas zip unzip curl wget -y
# Install openjdk-8
RUN wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - && add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ && apt-get update && apt-get install adoptopenjdk-8-hotspot -y
# Install jupyterlab
RUN pip3 install jupyterlab plotly-express seaborn
# Download Apache Spark 3.1.2 with Hadoop 3.2
RUN wget -q https://archive.apache.org/dist/spark/spark-3.1.2/spark-3.1.2-bin-hadoop3.2.tgz && tar -vzxf spark-3.1.2-bin-hadoop3.2.tgz && mv spark-3.1.2-bin-hadoop3.2 /opt/spark
# Set SPARK_HOME for all the users
RUN echo -e 'export SPARK_HOME=/opt/spark\nexport JAVA_HOME="/usr/lib/jvm/adoptopenjdk-8-hotspot-amd64/"\nexport PYTHONPATH=$SPARK_HOME/python:$PYTHONPATH\nexport PYSPARK_DRIVER_PYTHON="jupyter-lab"\nexport PYSPARK_PYTHON=python3\nexport PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin:$JAVA_HOME/jre/bin' >> /etc/skel/.bashrc
# Create non-root user
RUN adduser --gecos "" --disabled-password ${username} && chpasswd <<<"${username}:${password}"
# Add user as owner of /opt/spark
RUN chown -R user:user /opt/spark
# Add user to sudoers
RUN usermod -aG sudo user
# Set user to newly created user
USER user
WORKDIR /home/user