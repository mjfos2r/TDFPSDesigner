FROM nvidia/cuda:12.4.0-base-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

LABEL org.opencontainers.image.authors="Michael J. Foster" \
    org.opencontainers.image.source="https://github.com/mjfos2r/TDFPS_Designer" \
    org.opencontainers.image.description="container housing my fork of junhaiqi/TDFPS-Designer, a toolkit for the generation/demux of custom barcodes for use in ONT sequencing." \
    org.opencontainers.image.version="1.0.4" \
    maintainer="mfoster11<at>mgh<dot>harvard<dot>edu"

# Add deadsnakes ugh.
RUN apt-get update && apt-get install -y software-properties-common \
    && add-apt-repository -y ppa:deadsnakes/ppa

# now install it all
RUN apt-get update && apt-get install -y \
    build-essential \
    cuda-compiler-12-4 \
    cuda-cudart-dev-12-4 \
    cuda-nvcc-12-4 \
    libcublas-12-4 \
    libcublas-dev-12-4 \
    libcufft-12-4 \
    libcufft-dev-12-4 \
    libcurand-12-4 \
    libcurand-dev-12-4 \
    libffi-dev \
    libhdf5-dev \
    libfftw3-dev \
    libopenblas-dev \
    liblapack-dev \
    libssl-dev \
    python3.7 \
    python3.7-dev \
    python3.7-distutils \
    zlib1g-dev \
    libzstd-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/TDFPS
COPY . /opt/TDFPS
WORKDIR /tmp/

RUN wget https://bootstrap.pypa.io/pip/3.7/get-pip.py \
    && python3.7 get-pip.py \
    && rm get-pip.py

WORKDIR /opt/TDFPS
RUN python3.7 -m pip install --upgrade pip \
    && python3.7 -m pip install --no-cache-dir -r requirements.txt \
    && cd slow5lib \
    && make \
    && python3.7 -m pip install . \
    && cd ../squigulator \
    && make \
    && cp squigulator ../bin/squigulator \
    && cd .. \
    && ./scripts/compile.sh \
    && chmod u+x bin/*

# now we make sure that all of our cuda paths are kosher
ENV PATH=/usr/local/cuda/bin:${PATH} \
    LD_LIBRARY_PATH=/usr/local/cuda/lib64:${LD_LIBRARY_PATH} \
    CUDA_HOME=/usr/local/CUDA_HOME

# Set python environmental variables.
# Force to run in unbuffered mode for easier logging.
# don't write bytecode either. no *.pyc
# Set Python environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

ENTRYPOINT [ "/bin/bash" ]
