# Binder wrapper for analogdevicesinc/arduino
#
# This image is what mybinder.org builds. It does NOT modify the upstream repo.
# At build time it clones analogdevicesinc/arduino into /home/jovyan/arduino-lib
# and installs arduino-cli so you can compile / inspect sketches inside Binder.
#
# Image choice: jupyter/minimal-notebook is small and builds fast on the free
# mybinder.org cluster. Switch to jupyter/scipy-notebook if you need numpy /
# matplotlib / pandas preinstalled.

FROM jupyter/minimal-notebook:latest

# --- 1. System packages needed to compile Arduino sketches -----------------
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
        file \
        unzip \
        xz-utils \
        avrdude \
    && rm -rf /var/lib/apt/lists/*

# --- 2. arduino-cli --------------------------------------------------------
# Install the official arduino-cli so sketches in the library can be
# syntax-checked / compiled inside Binder (no real hardware needed).
ARG ARDUINO_CLI_VERSION=1.1.1
RUN curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh \
        | BINDIR=/usr/local/bin sh -s -- "${ARDUINO_CLI_VERSION}" \
    && arduino-cli version

# Configure board manager URLs so popular 3rd-party cores (ESP32, ADuC, etc.)
# are reachable from inside the container if you want to compile for them.
RUN mkdir -p /home/jovyan/.arduino15 \
    && printf 'board_manager:\n  additional_urls:\n    - https://raw.githubusercontent.com/analogdevicesinc/arduino/master/package_analogdevices_index.json\n    - https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json\n' \
        > /home/jovyan/.arduino15/arduino-cli.yaml \
    && chown -R "${NB_UID}:users" /home/jovyan/.arduino15

# --- 3. Clone the upstream library into the container ----------------------
# Pinned to the same commit Binder originally tried (d5946b9). Bump this if
# you want a newer snapshot.
ARG ARDUINO_REPO_URL=https://github.com/analogdevicesinc/arduino
ARG ARDUINO_REPO_REF=d5946b9
RUN git clone --depth 1 "${ARDUINO_REPO_URL}" /home/jovyan/arduino-lib \
    && cd /home/jovyan/arduino-lib \
    && git fetch --depth 1 origin "${ARDUINO_REPO_REF}" \
    && git checkout "${ARDUINO_REPO_REF}" \
    && chown -R "${NB_UID}:users" /home/jovyan/arduino-lib

# --- 4. Back to the Jupyter user ------------------------------------------
USER ${NB_UID}
WORKDIR /home/jovyan

# Python deps for the sample notebook + serial examples live in requirements.txt
# repo2docker installs it automatically. We keep it here too so the file is
# the source of truth when this Dockerfile is used outside of repo2docker.
COPY --chown=${NB_UID}:users requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt
