FROM continuumio/miniconda3:25.7.0-2

RUN conda create -n ouroboros_env \
    -c conda-forge \
    python=3.9 \
    pip=24.3.1 \
    -y

RUN conda run -n ouroboros_env \
    conda install -c conda-forge cartopy=0.23.0 -y

RUN conda run -n ouroboros_env \
    pip install ouroboros==1.0.3

ENV PATH=/opt/conda/envs/ouroboros_env/bin:$PATH

WORKDIR /data
