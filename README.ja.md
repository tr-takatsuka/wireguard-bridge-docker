# WireGuard-based VPN between Docker containers

[English](/README.md)

## Description

- 2拠点の Docker 環境を VPN で接続し、コンテナ間を仮想LANでつなぎます。
- VPN には WireGuard を使用しています。
- 遠隔地のコンテナ同士による物理的に離れた、あるいはクラウドサービスを跨いだ DBレプリケーションやバックアップなどの用途を想定しています。
- VPN(WireGuard)の鍵は自動生成されソース管理対象外のファイルに分離します。(秘匿性を考慮)
- サーバー側、クライアント側ともに docker-compose で構成されています。  
  サンプルとして、疎通確認用の汎用 ubuntu コンテナを記述しています。
- Docker の -net=host は使っていないためホストへの影響は最小限です。

## Starting docker

### 事前準備
- WireGuard はサーバー側に **UDP ポート51820(default)** を必要とします。
- `.\wgserver\compose.yaml` の `SERVERURL` にサーバーのURLを記載してください。

### サーバー側
- docker compose
  ```
  > cd wgserver
  > docker compose up -d
  ```

  初回起動すると `.\wgserver\wg\config` に  
  `.env_client`  
  `.env_server`  
  が生成されますので `.env_client` をクライアント側の `.\wgclient\wg\config` に配置します。  
    - `.\wgserver\wg\config\` には `.env_server` を残し、`.env_client` は削除してください

### クライアント側
- docker compose
  ```
  > cd wgclient
  > docker compose up -d
  ```

## 疎通確認(例)

- サーバー側
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

- クライアント側
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

## 制限事項
- 通信するコンテナ側には VPN 越しのネットワークへのルートを追加する必要があります。  
  例：
  ```
  > ip route add 172.20.2.0/24 via 172.20.1.101
  ```
  Docker のネットワーク構成では特定コンテナ（WireGuard）をデフォルトゲートウェイとして設定できないため、各コンテナごとに手動でルートを追加します。  
  よりスマートな方法をご存じの方は、ぜひ issue または PR にてご教示ください。

## Licence
[LICENSE](/LICENSE)

## Contact
- 問題の報告、改善案や御助言など何かありましたら御一報頂けますと幸いです。よろしくお願いします。