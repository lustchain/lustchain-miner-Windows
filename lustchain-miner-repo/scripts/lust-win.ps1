<# Lustchain Miner (Windows + Docker + Geth) - Multi-bootnode + Persistent DAG
 - NetworkID: 6923 (Ethash / PoW)
 - P2P: 30304 TCP/UDP
 - Local RPC: http://localhost:18545 (container 8545)
 - Works on any Windows machine with Docker Desktop
#>

$ErrorActionPreference = "Stop"

# ---------------- 0) Variables ----------------
$GEN_URL    = "http://138.197.125.190/genesis.json"
$NETWORKID  = 6923
$DATADIR    = Join-Path $env:USERPROFILE "lustdata"
$ETHASHDIR  = Join-Path $env:LOCALAPPDATA "Ethash"

# Multi bootnodes (from your network)
$BOOTNODES = @(
  "enode://11b60fbe545ce54d6d9a9d5b961db124d4cf79fe25b8a6d0536ad43b6120ab5e5c372b9f23008ab139e3cf78c1f91077323ec6a083565f5a6558a9c7ecd89ddc@104.248.175.223:30303",
  "enode://98eed382ee2ada3ba7f42054a0cf614af9e1ad909871e987f35c5d85f7aa5e508f7dc3556a32e4da6770461cc78f94f6dea255430e531ee881551daf9ee88b0a@170.64.145.190:30303",
  "enode://f3adbb4d1a28790f823d8886c9553012ac996e2cea2d164c3ac12b46483e2e0194b63f49b8209a15298c842d37d7abe859a6ab0d6cc8ee1e2398c986963fe0d6@138.197.125.190:30303"
) -join ","

# ---------------- 1) Pre-flight checks ----------------
try { docker --version | Out-Null } catch {
  Write-Host "!! Install Docker Desktop first: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
  exit 1
}

# Open P2P firewall (idempotent)
netsh advfirewall firewall add rule name="Lustchain P2P TCP 30304" dir=in action=allow protocol=TCP localport=30304 2>$null | Out-Null
netsh advfirewall firewall add rule name="Lustchain P2P UDP 30304" dir=in action=allow protocol=UDP localport=30304 2>$null | Out-Null

# ---------------- 2) User inputs ----------------
$addr = Read-Host "Rewards Address (0x...)"
if ($addr -notmatch '^0x[0-9a-fA-F]{40}$') { Write-Host "Invalid address." -ForegroundColor Red; exit 1 }

$cpu = [Environment]::ProcessorCount
$defaultThreads = [Math]::Max(1, $cpu - 1)
$threads = Read-Host "How many mining threads? (ENTER = $defaultThreads)"
if ([string]::IsNullOrWhiteSpace($threads)) { $threads = $defaultThreads }

# ---------------- 3) Prepare data dirs & genesis ----------------
New-Item -ItemType Directory -Force -Path $DATADIR   | Out-Null
New-Item -ItemType Directory -Force -Path $ETHASHDIR | Out-Null

$genFile = Join-Path $DATADIR "genesis.json"
Invoke-WebRequest -Uri $GEN_URL -OutFile $genFile -UseBasicParsing

# Initialize chaindata (idempotent; ignore old locks)
docker rm -f lust-geth 2>$null | Out-Null
Remove-Item "$DATADIR\geth\LOCK" -Force -ErrorAction SilentlyContinue
docker run --rm `
  -v "${DATADIR}:/root/.ethereum" `
  -v "${genFile}:/genesis.json" `
  ethereum/client-go:v1.10.26 init /genesis.json

# ---------------- 4) Run miner container ----------------
$containerId = docker run -d --name lust-geth --restart unless-stopped `
  -p 127.0.0.1:18545:8545 `
  -p 30304:30304/tcp -p 30304:30304/udp `
  -v "${DATADIR}:/root/.ethereum" `
  -v "${ETHASHDIR}:/root/.ethash" `
  ethereum/client-go:v1.10.26 `
  --datadir /root/.ethereum `
  --networkid $NETWORKID `
  --bootnodes "$BOOTNODES" `
  --port 30304 `
  --syncmode full `
  --cache 2048 `
  --maxpeers 50 `
  --ethash.dagdir /root/.ethash `
  --ethash.cachedir /root/.ethash `
  --http --http.addr 0.0.0.0 --http.port 8545 `
  --http.api eth,net,web3,txpool `
  --http.vhosts "localhost,127.0.0.1" `
  --http.corsdomain "*" `
  --miner.etherbase "$addr" `
  --mine --miner.threads $threads `
  --miner.extradata "lust-miner-win"

""
"Node started: $containerId"
"Logs (follow): docker logs -f lust-geth"
""

# ---------------- 5) Quick RPC checks ----------------
$RPC = "http://localhost:18545"
function Rpc($m,$p=@()){
  $b = @{jsonrpc="2.0";id=1;method=$m;params=$p}|ConvertTo-Json -Compress
  try{ Invoke-RestMethod -Method Post -Uri $RPC -ContentType "application/json" -Body $b -TimeoutSec 8 }catch{ $null }
}

Start-Sleep -Seconds 4
$r1 = Rpc "web3_clientVersion"; "client       : {0}" -f ($r1.result)
$r2 = Rpc "eth_chainId";       "chainId      : {0}" -f ($r2.result)
$r3 = Rpc "net_peerCount";     "peerCount    : {0}" -f ($r3.result)
$r4 = Rpc "eth_blockNumber";   "blockNumber  : {0}" -f ($r4.result)
$r5 = Rpc "eth_mining";        "mining       : {0}" -f ($r5.result)
$r6 = Rpc "eth_hashrate";      "hashrate     : {0}" -f ($r6.result)

# ---------------- 6) Helper commands (optional) ----------------
# Stop:   docker stop lust-geth
# Start:  docker start lust-geth
# Logs:   docker logs -f lust-geth
# Shell:  docker exec -it lust-geth sh
# Attach: docker exec -it lust-geth geth attach /root/.ethereum/geth.ipc
