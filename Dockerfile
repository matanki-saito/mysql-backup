# mysql backup image
FROM debian:stable-slim

RUN apt update

#tools
RUN apt install -y sudo wget curl bash python3 openssl coreutils python3-pip tcpdump iputils-ping net-tools

#samba
RUN apt install -y samba-client 

#maria-db
RUN wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup && chmod +x mariadb_repo_setup && ./mariadb_repo_setup --mariadb-server-version="mariadb-10.6"
RUN apt install -y mariadb-client libmariadb3 libmariadb-dev

RUN rm -rf /var/cache/apt/* && \
    touch /etc/samba/smb.conf && \
    pip3 install awscli

# set us up to run as non-root user
RUN groupadd -g 1005 appuser && \
    useradd -r -u 1005 -g appuser appuser
# ensure smb stuff works correctly
RUN mkdir -p /var/cache/samba && chmod 0755 /var/cache/samba && chown appuser /var/cache/samba
#USER appuser

# install the entrypoint
COPY functions.sh /
COPY entrypoint /entrypoint

# start
ENTRYPOINT ["/entrypoint"]
