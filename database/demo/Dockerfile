FROM mysql:5.7

ADD script/add-server-id.sh /usr/local/bin/add-server-id.sh
RUN chmod +x /usr/local/bin/add-server-id.sh

RUN apt-get update \
    && apt-get install -y locales \
    && locale-gen ja_JP.UTF-8
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL=ja_JP.UTF-8
RUN localedef -f UTF-8 -i ja_JP ja_JP.utf8
