FROM python:3.10.11-slim-bullseye

RUN apt-get update && \
    apt-get upgrade --yes

RUN useradd --create-home sbassim
USER sbassim
WORKDIR /home/sbassim

ENV VIRTUALENV=/home/sbassim/venv
RUN python3 -m venv $VIRTUALENV
ENV PATH="$VIRTUALENV/bin:$PATH"

COPY --chown=sbassim pyproject.toml constraints.txt ./
RUN python -m pip install --upgrade pip setuptools && \
    python -m pip install --no-cache-dir -c constraints.txt ".[dev]"
