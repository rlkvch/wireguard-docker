![Build and publish Docker Image_](https://github.com/rlkvch/docker-wireguard/workflows/Build%20and%20publish%20Docker%20Image/badge.svg)

## Run
### First Run
If the wireguard kernel module is not already installed on the __host__ system, use this first run command to install it:
```
docker run -it --rm --cap-add sys_module -v /lib/modules:/lib/modules rlkvch/wireguard:latest install-module
```

### Normal Run
```
docker run --cap-add net_admin --cap-add sys_module -v <config volume or host dir>:/etc/wireguard -p <externalport>:<dockerport>/udp rlkvch/wireguard:latest
```
Example:
```
docker run --cap-add net_admin --cap-add sys_module -v wireguard_conf:/etc/wireguard -p 5555:5555/udp rlkvch/wireguard:latest
```
### Generate Keys
This shortcut can be used to generate and display public/private key pairs to use for the server or clients
```
docker run -it --rm rlkvch/wireguard:latest genkeys
```

## Configuration
Sample server configuration to go in /etc/wireguard:
```
[Interface]
Address = 192.168.20.1/24
PrivateKey = <server_private_key>
ListenPort = 5555

[Peer]
PublicKey = <client_public_key>
AllowedIPs = 192.168.20.2
```
Sample client configuration:
```
[Interface]
Address = 192.168.20.2/24
PrivateKey = <client_private_key>
ListenPort = 0 #needed for some clients to accept the config

[Peer]
PublicKey = <server_public_key>
Endpoint = <server_public_ip>:5555
AllowedIPs = 0.0.0.0/0,::/0 #makes sure ALL traffic routed through VPN
PersistentKeepalive = 25
```
## Other Notes
- This Docker image also has a iptables NAT (MASQUERADE) rule already configured to make traffic through the VPN to the Internet work. This can be disabled by setting the environment varialbe IPTABLES_MASQ to 0.
- For some clients (a GL.inet router in my case) you may have trouble with HTTPS (SSL/TLS) due to the MTU on the VPN. Ping and HTTP work fine but HTTPS does not for some sites. This can be fixed with [MSS Clamping](https://www.tldp.org/HOWTO/Adv-Routing-HOWTO/lartc.cookbook.mtu-mss.html). This is simply a checkbox in the OpenWRT Firewall settings interface.
- This image can be used as a client as well. If you want to forward all traffic through the VPN (`AllowedIPs = 0.0.0.0/0`), you need to use the `--privileged` flag when running the container

## docker-compose
Sample docker-compose.yml
```
version: "2.2"
services:
  wireguard:
    image: rlkvch/wireguard
    container_name: wireguard
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Minsk
    volumes:
      - /home/rlkvch/hnetwork/wireguard/data:/etc/wireguard
    networks:
      - mynetwork
    ports:
      - 51820:51820/udp
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
    restart: unless-stopped

networks:
    mynetwork:
       external:
          name: mynetwork
```
