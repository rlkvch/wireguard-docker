FROM ubuntu:focal

# Install wireguard packges
RUN apt-get update && \
    apt-get install -y --no-install-recommends wireguard-tools mawk grep qrencode iptables iproute2 nano net-tools procps openresolv && \
 apt-get clean

# Add main work dir to PATH
WORKDIR /scripts
ENV PATH="/scripts:${PATH}"

# Use iptables masquerade NAT rule
ENV IPTABLES_MASQ=1

# Copy scripts to containers
COPY run /scripts
COPY genkeys /scripts
# COPY easy-wg-quick /scripts
RUN chmod 755 /scripts/*

# Wirguard interface configs go in /etc/wireguard
VOLUME /etc/wireguard

# Normal behavior is just to run wireguard with existing configs
CMD ["run"]
