FROM gitpod/workspace-mongodb:latest

USER root

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y git curl sudo locales zip unzip \
    && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* \
    && npm install npm@latest -g \
    && locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8

RUN useradd -l -u 33333 -G sudo -md /home/gitpod -s /bin/bash -p gitpod gitpod \
    # passwordless sudo for users in the 'sudo' group
    && sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers

USER gitpod

ENV HOME=/home/gitpod
WORKDIR $HOME

# custom Bash prompt
RUN echo ' \n\
parse_git_branch() { \n\
  branch=$(git branch 2> /dev/null | sed -e '\''/^[^*]/d'\'' -e '\''s/* \(.*\)/(\\1)/'\'') \n\
  if [ ${#branch} -gt 8 ] \n\
  then \n\
    branch=$(echo $branch | cut -c 1-7) \n\
    echo "${branch}...)" \n\
  else \n\
    echo "${branch}" \n\
  fi \n\
} \n\
\n\
PS1='\''\[\\e[01;34m\]\w \[\\e[91m\]$(parse_git_branch)\[\\e[00m\]\$ '\''\n'>> .bashrc
