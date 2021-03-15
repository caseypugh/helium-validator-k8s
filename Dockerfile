FROM quay.io/team-helium/validator:latest-val-amd64
RUN miner start
# FROM docker:dind
# RUN apt update 
# RUN apt-get install -y git nano curl wget
# RUN add-apt-repository ppa:longsleep/golang-backports

# Install Docker
# RUN apt install -y docker.io
# RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
# RUN echo \
#   "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
#   $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# RUN apt-get update -y
# RUN apt-get install -y docker-ce docker-ce-cli containerd.io

# Setup scripts
# RUN mkdir /data
# RUN mkdir /data/validator
# ADD /app /data/validator
# WORKDIR /data/validator

# RUN git clone -b pevm/validators https://github.com/helium/miner.git
# RUN wget https://packages.erlang-solutions.com/erlang/debian/pool/esl-erlang_22.3.1-1~ubuntu~bionic_amd64.deb
# RUN wget http://mirrors.kernel.org/ubuntu/pool/universe/w/wxwidgets3.0/libwxgtk3.0-0v5_3.0.4+dfsg-3_amd64.deb
# RUN
# RUN ls -al
# RUN go build -o main .
# CMD ["./setup.sh"]