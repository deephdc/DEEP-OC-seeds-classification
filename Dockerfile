FROM ubuntu:18.04
LABEL maintainer="Lara Lloret Iglesias <lloret@ifca.unican.es>"
LABEL version="0.1"
LABEL description="DEEP as a Service: Container for seeds classification"

RUN apt-get update && \
    apt-get upgrade -y

RUN apt-get install -y --no-install-recommends \
        curl \
        git \
        python-setuptools \
        python-pip

# We could shrink the dependencies, but this is a demo container, so...
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
         build-essential \
         python-dev \
         python-wheel \
         python-numpy \
         python-scipy \
         python-tk

RUN pip install --upgrade https://github.com/Theano/Theano/archive/master.zip
RUN pip install --upgrade https://github.com/Lasagne/Lasagne/archive/master.zip

WORKDIR /srv

RUN apt-get install -y nano


#seeds

RUN git clone https://github.com/indigo-dc/seeds-classification-theano -b package  && \
    cd seeds-classification-theano && \
    pip install -e . && \
    cd ..


#Install deepaas
RUN pip install deepaas


ENV SWIFT_CONTAINER_seeds https://cephrgw01.ifca.es:8080/swift/v1/seeds/
ENV THEANO_TR_WEIGHTS_seeds resnet50_493classes_30epochs.npz
ENV THEANO_TR_JSON_seeds resnet50_493classes_30epochs.json
ENV SYNSETS_seeds synsets.txt
ENV INFO_seeds info.txt


RUN curl -o ./seeds-classification-theano/seeds_classification/training_weights/${THEANO_TR_WEIGHTS_seeds} ${SWIFT_CONTAINER_seeds}${THEANO_TR_WEIGHTS_seeds}

RUN curl -o ./seeds-classification-theano/seeds_classification/training_info/${THEANO_TR_JSON_seeds} ${SWIFT_CONTAINER_seeds}${THEANO_TR_JSON_seeds}

RUN curl -o ./seeds-classification-theano/data/data_splits/synsets.txt  ${SWIFT_CONTAINER_seeds}${SYNSETS_seeds}



EXPOSE 5000

RUN apt-get install nano

CMD deepaas-run --listen-ip 0.0.0.0
