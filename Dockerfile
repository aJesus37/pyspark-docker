# Set base image as debian 10 Buster
FROM debian:10
# Set default user and password
ENV username user
ENV password UserPasswd!
ENV node_path /usr/local/lib/nodejs/node-v14.18.0-linux-x64/bin
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
RUN apt update -y && apt dist-upgrade -yqq
# Install dependencies
RUN apt install tmux git sudo software-properties-common python3 python3-pip python3-pandas zip unzip curl wget libblas-dev  liblapack-dev gfortran build-essential libssl-dev libffi-dev python-dev -y
# Install openjdk-8
RUN wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - && add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ && apt-get update && apt-get install adoptopenjdk-8-hotspot -y
# Install jupyterlab
RUN pip3 install jupyterlab plotly-express jupyterlab-git findspark
# Download Apache Spark 3.1.2 with Hadoop 3.2
RUN wget -q https://archive.apache.org/dist/spark/spark-3.1.2/spark-3.1.2-bin-hadoop3.2.tgz && tar -vzxf spark-3.1.2-bin-hadoop3.2.tgz && mv spark-3.1.2-bin-hadoop3.2 /opt/spark
# Set SPARK_HOME for all the users and add PATH to nodejs bin
RUN echo -e 'export SPARK_HOME=/opt/spark\nexport JAVA_HOME="/usr/lib/jvm/adoptopenjdk-8-hotspot-amd64/"\nexport PYTHONPATH=$SPARK_HOME/python:$PYTHONPATH\nexport PYSPARK_DRIVER_PYTHON="jupyter-lab"\nexport PYSPARK_PYTHON=python3\nexport PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin:$JAVA_HOME/jre/bin:/usr/local/lib/nodejs/node-v14.18.0-linux-x64/bin' >> /etc/skel/.bashrc
# Create non-root user
RUN adduser --gecos "" --disabled-password ${username} && chpasswd <<<"${username}:${password}"
# Add user as owner of /opt/spark
RUN chown -R user:user /opt/spark
# Add user to sudoers
RUN usermod -aG sudo user
#Install Nodejs v14.18.0
RUN wget https://nodejs.org/dist/v14.18.0/node-v14.18.0-linux-x64.tar.xz && mkdir -p /usr/local/lib/nodejs && tar -xJvf node-v14.18.0-linux-x64.tar.xz -C /usr/local/lib/nodejs && ln -s ${node_path}/node /usr/bin/node && ln -s ${node_path}/npm /usr/bin/npm && ln -s ${node_path}/npx /usr/bin/npx
# Add permission to folder where extensions are installed
RUN chown -R user:user /usr/local/share/jupyter
# Set user to newly created user
USER user
WORKDIR /home/user
# Enable jupyter on 0.0.0.0 (default localhost only, do not work with -p 8888:8888)
RUN jupyter-lab --generate-config && sed -i "s/^# c.ServerApp.ip = 'localhost'$/c.ServerApp.ip = '0.0.0.0'/g" /home/user/.jupyter/jupyter_lab_config.py
# Set dark theme as default
RUN mkdir -p /usr/local/share/jupyter/lab/settings/ && echo -e '{\n  "@jupyterlab/apputils-extension:themes": {\n    "theme": "JupyterLab Dark"\n  }\n}' > /usr/local/share/jupyter/lab/settings/overrides.json
# Install  extensions
RUN jupyter labextension install jupyterlab-chart-editor
# Add alias to python=python3 and pip=pip3
RUN alias python=python3 && alias pip=pip3