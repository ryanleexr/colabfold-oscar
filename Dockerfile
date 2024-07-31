ARG CUDA_VERSION=12.2.0
ARG COLABFOLD_VERSION=1.5.5
FROM --platform=linux/amd64 nvidia/cuda:${CUDA_VERSION}-base-ubuntu22.04
# COPY environment.yaml /tmp/environment.yaml

RUN apt-get update && apt-get install -y wget cuda-nvcc-$(echo $CUDA_VERSION | cut -d'.' -f1,2 | tr '.' '-') --no-install-recommends --no-install-suggests && rm -rf /var/lib/apt/lists/* && \
    wget -qnc https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh && \
    bash Mambaforge-Linux-x86_64.sh -bfp /usr/local && \
    rm -f Mambaforge-Linux-x86_64.sh && \
    CONDA_OVERRIDE_CUDA=$(echo $CUDA_VERSION | cut -d'.' -f1,2) mamba create -y -n colabfold -c conda-forge -c bioconda ipykernel ipywidgets notebook mmseqs2 jax[cuda12] git colabfold=$COLABFOLD_VERSION jaxlib==*=cuda* && \
    mamba clean -afy

ENV PATH=/usr/local/envs/colabfold/bin:$PATH
ENV MPLBACKEND=Agg
ENV ENABLE_PJRT_COMPATIBILITY=true

VOLUME cache
ENV MPLCONFIGDIR=/cache
ENV XDG_CACHE_HOME=/cache

COPY AlphaFold2.ipynb /
# RUN mamba install -c conda-forge -n colabfold ipykernel
# RUN mamba install -c conda-forge -n colabfold notebook
RUN mamba run -n colabfold python -m ipykernel install --user --name=colabfold
# RUN $PATH/python -m ipykernel install --prefix=/path/to/jupyter/env --name 'python-my-env
# RUN apt-get update
# RUN apt-get upgrade -y
# RUN apt-get install -y git
# RUN mamba install -c conda-forge -y biopython
#RUN source activate colabfold
#RUN mamba install ipykernel
#RUN python -m ipykernel install --user --name myenv --display-name "Python (myenv)"

EXPOSE 8888

CMD ["jupyter", "notebook", "--ip", "0.0.0.0", "--port", "8888", "--allow-root"]
