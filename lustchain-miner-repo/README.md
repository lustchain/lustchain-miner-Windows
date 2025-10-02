# Lustchain Miner (Windows + Docker + Geth)

One-command miner for PoW (Ethash) network **ID 6923**. Initializes from hosted genesis, connects to multiple bootnodes, persists Ethash DAG, opens P2P **30304**, exposes local RPC at **http://localhost:18545**, and runs quick health checks. Includes wallet setup for MetaMask / Coinbase / Trust Wallet via **https://rpc.lustchain.org**.

## Quick start
```powershell
# 1) Install Docker Desktop: https://www.docker.com/products/docker-desktop
# 2) Run the miner (PowerShell):
scripts/lust-win.ps1
```

## Files
- `scripts/lust-win.ps1` — main installer & miner
- `scripts/reset-win.ps1` — wipe local data (keep your address safe)
- `wallets/ADD_WALLETS.md` — add Lustchain to wallets
- `LICENSE` — MIT

## Network
- RPC: https://rpc.lustchain.org
- Chain ID: 6923 (0x1b0b)
- Symbol: LUST
