# Add Lustchain to Wallets

**Parameters**

- **Network name:** Lustchain
- **RPC URL:** https://rpc.lustchain.org
- **Chain ID:** 6923 (`0x1b0b`)
- **Currency symbol:** LUST
- **Block explorer URL (optional):** *(none)*

## MetaMask (Browser / Mobile)
1. Open MetaMask → **Settings** → **Networks** → **Add network** → **Add a network manually**.
2. Fill the fields above and **Save**.
3. Or use code in a dApp console:
```js
await window.ethereum.request({
  method: 'wallet_addEthereumChain',
  params: [{
    chainId: '0x1b0b',
    chainName: 'Lustchain',
    nativeCurrency: { name: 'Lust', symbol: 'LUST', decimals: 18 },
    rpcUrls: ['https://rpc.lustchain.org'],
    blockExplorerUrls: []
  }]
});
```

## Coinbase Wallet (App)
1. Open the app → **Settings** → **Developer Settings** → **Networks** → **Add Custom Network**.
2. Enter the same parameters and save.

## Trust Wallet (App)
1. **Settings** → **Networks** → **Add Custom Network** → choose **EVM**.
2. Enter the parameters above and save.

## JSON (for tooling)
```json
{
  "chainId": 6923,
  "chainIdHex": "0x1b0b",
  "chainName": "Lustchain",
  "nativeCurrency": {
    "name": "Lust",
    "symbol": "LUST",
    "decimals": 18
  },
  "rpcUrls": [
    "https://rpc.lustchain.org"
  ],
  "blockExplorerUrls": []
}
```
