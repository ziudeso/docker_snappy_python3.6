FROM python:3.6-stretch

LABEL maintainer="Fra"

# upgrade pip
RUN pip3 install --upgrade pip

# download and install ESA SNAP 7.0
RUN wget http://step.esa.int/downloads/7.0/installers/esa-snap_sentinel_unix_7_0.sh \
      #change file execution rights for snap installer
      && chmod +x esa-snap_sentinel_unix_7_0.sh \ 
      # install snap with gpt
      && ./esa-snap_sentinel_unix_7_0.sh -q \
      # link gpt so it can be used systemwide
      && ln -s /usr/local/snap/bin/gpt /usr/bin/gpt \
      # set gpt max memory to 4GB
      && sed -i -e 's/-Xmx1G/-Xmx4G/g' /usr/local/snap/bin/gpt.vmoptions \
      # install snappy the SNAP python module
      && /usr/local/snap/bin/snappy-conf /usr/local/bin/python \
      && cd /root/.snap/snap-python/snappy/ \
      && python setup.py install \
      && ln -s /root/.snap/snap-python/snappy /usr/local/lib/python3.6/site-packages/snappy \
      # Clean up
      && rm /esa-snap_sentinel_unix_7_0.sh \
      && rm -rf /var/lib/apt/lists/*

ADD requirements.txt /app/requirements.txt
RUN pip install --default-timeout=100 -r /app/requirements.txt
RUN python -m pip install jupyter -U 
RUN python -m pip install jupyterlab

WORKDIR /workdir

EXPOSE 8888

ENTRYPOINT ["jupyter", "lab","--ip=0.0.0.0","--allow-root"]