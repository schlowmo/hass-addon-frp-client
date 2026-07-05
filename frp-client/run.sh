#!/usr/bin/env bashio
WAIT_PIDS=()
CONFIG_PATH='/share/frpc.toml'
DEFAULT_CONFIG_PATH='/frpc.toml'

function stop_frpc() {
    bashio::log.info "Shutdown frpc client"
    kill -15 "${WAIT_PIDS[@]}"
}

bashio::log.info "Copying configuration."
cp $DEFAULT_CONFIG_PATH $CONFIG_PATH
sed -i "s/serverAddr = \"your_server_addr\"/serverAddr = \"$(bashio::config 'serverAddr')\"/" $CONFIG_PATH
sed -i "s/serverPort = 7000/serverPort = $(bashio::config 'serverPort')/" $CONFIG_PATH
sed -i "s/auth.token = \"123456789\"/auth.token = \"$(bashio::config 'authToken')\"/" $CONFIG_PATH
sed -i "s/name = \"http_proxy_name\"/name = \"$(bashio::config 'httpProxyName')\"/" $CONFIG_PATH
sed -i "s/localPort = 80/localPort = $(bashio::config 'httpLocalPort')/" $CONFIG_PATH
sed -i "s/remotePort = 80/remotePort = $(bashio::config 'httpRemotePort')/" $CONFIG_PATH
sed -i "s/name = \"https_proxy_name\"/name = \"$(bashio::config 'httpsProxyName')\"/" $CONFIG_PATH
sed -i "s/localPort = 443/localPort = $(bashio::config 'httpsLocalPort')/" $CONFIG_PATH
sed -i "s/remotePort = 443/remotePort = $(bashio::config 'httpsRemotePort')/" $CONFIG_PATH


bashio::log.info "Starting frp client"

cat $CONFIG_PATH

cd /usr/src
./frpc -c $CONFIG_PATH & WAIT_PIDS+=($!)

tail -f /share/frpc.log &

trap "stop_frpc" SIGTERM SIGHUP
wait "${WAIT_PIDS[@]}"
