FROM reg.choncholas.com/research/dex/akridex-mpc:latest

#RUN apt-get update && apt-get install -y \
#   build-essential \
#   --no-install-recommends \
#   && rm -rf /var/lib/apt/lists/*

WORKDIR /akridex-discovery

#ENV NVM_DIR ~/.nvm
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION "v14.1.0"

RUN mkdir -p $NVM_DIR && \
    wget -q -O - https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.1/install.sh | bash - && \
    source $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default

ENV NODE_PATH $NVM_DIR/$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/$NODE_VERSION/bin:$PATH

COPY ./env.js .
COPY ./alice_dht.js .
COPY ./bob_seed_dht.js .
COPY ./bootstrap_dht.js .
COPY ./passive_dht.js .
COPY ./package-lock.json .
COPY ./package.json .

RUN npm install && \
    mkdir mpcbin && \
    mkdir results && \
    cp /akridex-mpc/build/bin/plain_singleatt_* /akridex-discovery/mpcbin/ && \
    cp /akridex-mpc/build/bin/agmpc_singleatt_* /akridex-discovery/mpcbin/

#ENTRYPOINT ["./sh2pc_auction_benchmark"]
#CMD ["node", "app.js"]

