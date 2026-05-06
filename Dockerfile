FROM python:3.11-slim

ENV USER=app \
    APP_DIR=/home/app \
    PIP_NO_CACHE_DIR=0 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN useradd -ms /bin/bash ${USER}

# System dependencies
RUN apt-get -y update \
  && apt-get install -y --no-install-recommends \
    build-essential \
    libffi-dev \
    libpq-dev \
    tini \
  && rm -rf /var/lib/apt/lists/*

WORKDIR ${APP_DIR}

# Python build tooling
RUN pip3 install --upgrade pip setuptools wheel

# App source. Copying the whole tree keeps docker builds runnable even when
# optional distribution files such as README.rst, setup.cfg, or MANIFEST.in are
# not present in a token-pruned checkout.
COPY . ${APP_DIR}/

# App dependencies
RUN pip3 install -e .[release,test]

RUN chown -R ${USER}: ${APP_DIR}
USER ${USER}

ENTRYPOINT ["tini", "--"]
CMD ["line_item_manager", "--help"]
