# WireGuard-based VPN between Docker containers

[日本語](/README.ja.md)

## Description

- Connects two Docker environments via VPN, creating a virtual LAN between containers.
- Uses WireGuard as the VPN.
- Designed for use cases such as database replication or backups between physically separated containers or across different cloud services.
- WireGuard keys are automatically generated and stored in files excluded from source control for security and confidentiality.
- Both the server and client sides are configured with docker-compose.
  Includes a sample Ubuntu container for connectivity testing.
- Does not use Docker’s --net=host, minimizing impact on the host system.

## Starting docker

### Prerequisites
- The WireGuard server requires **UDP port 51820** (default) to be open.  
- Set the server's URL in `./wgserver/compose.yaml` under the `SERVERURL` variable.
 
### Server Side
- docker compose
  ```
  > cd wgserver
  > docker compose up -d
  ```

  On first startup, two files will be generated in `./wgserver/wg/config`  
  `.env_client`  
  `.env_server`  
  Copy .env_client to the client side at `./wgclient/wg/config`, and remove it from the server after copying (keep `.env_server` on the server).

### Client Side
- docker compose
  ```
  > cd wgclient
  > docker compose up -d
  ```

## Connectivity Test (Example)

- Server Side
  ```
  > docker exec -it wgserver-wg wg show all
  
  interface: wg0
    public key: **********
    private key: (hidden)
    listening port: 51820
  peer: **********
    preshared key: (hidden)
    endpoint: 172.20.1.1:56457
    allowed ips: 10.13.13.2/32, 172.20.2.0/24
    latest handshake: 14 seconds ago
    transfer: 180 B received, 92 B sent
  ```

  ```
  > docker exec -it wgserver-sampleubuntu ping -c 3 172.20.2.102
  
  PING 172.20.2.102 (172.20.2.102) 56(84) bytes of data.
  64 bytes from 172.20.2.102: icmp_seq=1 ttl=62 time=9.29 ms
  64 bytes from 172.20.2.102: icmp_seq=2 ttl=62 time=12.5 ms
  64 bytes from 172.20.2.102: icmp_seq=3 ttl=62 time=11.0 ms
  ```

- Client Side
  ```
  > docker exec -it wgclient-wg wg show all
  
  interface: wg0
    public key: **********
    private key: (hidden)
    listening port: 48457
  peer: **********
    preshared key: (hidden)
    endpoint: **********:51820
    allowed ips: 10.13.13.1/32, 172.20.1.0/24
    latest handshake: 31 seconds ago
    transfer: 92 B received, 212 B sent
    persistent keepalive: every 25 seconds
  ```

  ```
  > docker exec -it wgclient-sampleubuntu ping -c 3 172.20.1.102
  
  PING 172.20.1.102 (172.20.1.102) 56(84) bytes of data.
  64 bytes from 172.20.1.102: icmp_seq=1 ttl=62 time=9.18 ms
  64 bytes from 172.20.1.102: icmp_seq=2 ttl=62 time=9.52 ms
  64 bytes from 172.20.1.102: icmp_seq=3 ttl=62 time=11.5 ms
  ```

## Limitations
- Each communicating container must manually add a route to reach the remote VPN network.  
  Example:
  ```
  > ip route add 172.20.2.0/24 via 172.20.1.101
  ```
  Because Docker networks do not allow setting a specific container (WireGuard) as the default gateway, routes must be added individually inside each container.  
  If you know of a smarter or more automated way to achieve this,
please share it via an Issue or Pull Request!

## Licence
[LICENSE](/LICENSE)

## Contact
- If you find any issues or have ideas for improvements, please let me know. Thank you and best regards.
