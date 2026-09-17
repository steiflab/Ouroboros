FROM python:3.6-slim

WORKDIR /app
COPY . /app

# Install system dependencies: PROJ, GEOS, compiler, and Git
RUN apt-get update && apt-get install -y \
    proj-bin \
    libproj-dev \
    libgeos-dev \
    gcc \
    g++ \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip

RUN pip install cartopy
RUN pip install .
RUN pip install git+https://github.com/klarman-cell-observatory/scPhere.git
RUN pip install pytest
CMD ["ouroboros"]
