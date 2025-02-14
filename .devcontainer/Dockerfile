# Dockerfile
FROM nvidia/cuda:12.1.0-cudnn8-devel-ubuntu22.04

# Define ARGs
ARG ENV_NAME=data_science_bball_homo
ARG PYTHON_VER=3.10

# Prevent tzdata from asking for user input
ENV DEBIAN_FRONTEND=noninteractive

# Set environment variables
ENV CONDA_DIR=/opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH
ENV ENV_NAME=$ENV_NAME

# Install system dependencies
RUN apt-get update --fix-missing && \
    apt-get install -y \
    wget \
    bzip2 \
    ca-certificates \
    curl \
    git \
    vim \
    python3-pip \
    python3-dev \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgl1-mesa-glx \
    libusb-1.0-0-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py310_23.5.2-0-Linux-x86_64.sh -O ~/miniconda.sh \
    && chmod +x ~/miniconda.sh \
    && ~/miniconda.sh -b -p $CONDA_DIR \
    && rm ~/miniconda.sh \
    && echo ". $CONDA_DIR/etc/profile.d/conda.sh" >> ~/.bashrc \
    && find $CONDA_DIR/ -follow -type f -name '*.a' -delete \
    && find $CONDA_DIR/ -follow -type f -name '*.js.map' -delete \
    && $CONDA_DIR/bin/conda clean -afy

# Add required Conda channels and environment file
RUN conda config --add channels defaults && \
    conda config --add channels conda-forge

COPY .devcontainer/environment.yml /tmp/environment.yml
RUN sed -i 's/${ENV_NAME}/'"$ENV_NAME"'/g' /tmp/environment.yml && \
    sed -i 's/${PYTHON_VER}/'"$PYTHON_VER"'/g' /tmp/environment.yml

# Update Conda base and create the environment
RUN conda update -n base -c defaults conda && \
    conda env create -n $ENV_NAME -f /tmp/environment.yml && \
    conda env list && \
    conda clean -afy

# Upgrade specific packages
RUN conda run -n $ENV_NAME conda update --all -y && \
    conda run -n $ENV_NAME pip install --upgrade pip pandas

# Install additional pip packages
RUN conda run -n $ENV_NAME pip install --no-cache-dir torch>=2.3.1 torchvision>=0.18.1 torchaudio --index-url https://download.pytorch.org/whl/cu121 && \
    conda run -n $ENV_NAME pip install --no-cache-dir ultralytics sahi supervision roboflow yt-dlp

# Clone the sam2 repository
RUN git clone https://github.com/facebookresearch/sam2.git /opt/sam2

# Install sam2 in the conda environment
RUN conda run -n $ENV_NAME pip install -e /opt/sam2[dev]

# Verify installation
RUN conda run -n $ENV_NAME python -c "import sam2; print(f'sam2 installed at {sam2.__file__}')"

# Set working directory
WORKDIR /workspace

# Set the default command to bash
CMD ["/bin/bash", "-c", "source ~/.bashrc && exec bash"]
