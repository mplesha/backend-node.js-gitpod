FROM ubuntu:latest

USER root

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y git curl sudo locales zip unzip \
    && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get install -y nodejs \
    && curl -sL https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* \
    && npm install npm@latest -g \
    && npm install @angular/cli @angular-devkit/core @angular-devkit/schematics @angular-eslint/schematics -g \
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
