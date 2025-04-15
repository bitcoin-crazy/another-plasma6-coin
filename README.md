# Another Plasma6 Coin

<br>![Example of tool bar](screenshots/toolbar.png)<br><br>

Another Plasma Coin is an Plasma 6 (KDE) applet to show the price of Bitcoin and other cryptocurrencies in tool bar.

This program was initially based in Plasma Coin, written by [zayronXIO](https://store.kde.org/u/zayronXIO).

I am an anonymous programmer and I developed this applet for my personal utilization. Feel free to send pull requests.


## How to install

### Automatic install
 
The best way to install this applet is via widget manager from KDE.

1. Right-Click over the tool bar and select Add or Manage Wiggets.
2. Select Get New, Download New Plasma Widgets and choose Another Plasma6 Coin.
3. Click over Install buttom.
4. Right-Click again over the tool bar and select Add or Manage Wiggets.
5. Select Another Plasma6 Coin and drag it to tool bar.
6. Right-Click over the applet in tool bar and select Configure Another Plasma6 Coin.

### Manual install

Other way to install Another Plasma6 Coin is to make it manually.

1. Copy the directory Another.Plasma6.Coin to ~/.local/share/plasma/plasmoids/
2. Run `$ kquitapp6 plasmashell && kstart plasmashell` or restart KDE.
3. Right-Click over the tool bar and select Add or Manage Wiggets.
4. Select Another Plasma6 Coin and drag it to tool bar.
5. Right-Click over the applet in tool bar and select Configure Another Plasma6 Coin.

## Options (configuration)

<br>![Configuration Window](screenshots/configuration.png)<br><br>

There are some options in Configuration window.

* The Font Size for Price will determine the size of the price. The name of the coin will be shown sbove the price and size of this will be 70% of the price size.
* Bold is for price and coin name.
* From Crypto will select the cryptocurrency and To Crypto/Currency will select the pair to be utilized.
* Show Coin Name and Show Pair: only one of these can be selected, but both can be unselected.
* Decimal Places is for fracional numbers.
* The price will be updated every 3 minutes.

## Hacking the source code

### New coins and currencies

Another Plasma6 Coin arrives with a limited number of coins and currencies. Is possible to add new itens.

IMPORTANT: All prices are taken from [CoinGecko](https://www.coingecko.com) via API.

* For coins, edit `~/.local/share/plasma/plasmoids/Another.Plasma6.Coin/contents/ui/CoinModel.qml` and add a new line. You must to use the same `name` provided by CoinGecko via API. There is a list [here](https://www.coingecko.com/en/all-cryptocurrencies). Click cursor over a coin name and observe its name at the end of URL. E.g.: for Ethereum Classic, we have `https://www.coingecko.com/en/coins/ethereum-classic`, so ethereum-classic must be used if needed.
* For currencies, edit `~/.local/share/plasma/plasmoids/Another.Plasma6.Coin/contents/ui/CurrencyModel.qml` and add a new block. Thare is a list of currencies [here](https://docs.coingecko.com/reference/simple-supported-currencies).

TIP: It is possible to make tests against the CoinGecko API using the `curl` command. See an example for BTC/USD:

```
$ curl 'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd'
```

### Crypto/Currency names size

The size of the Crypto/Currency names is 70% (0.7) of the price size. This can be changed at `~/.local/share/plasma/plasmoids/Another.Plasma6.Coin/contents/ui/CompactRepresentation.qml`. Search for `0.7`.

### Time refresh

The time refresh for prices is 3 minutes. This can be changed at `~/.local/share/plasma/plasmoids/Another.Plasma6.Coin/contents/ui/components/GetAPI.qml`. Search for `refreshRate: 3`.

IMPORTANT: avoid to use less than 3 minutes because CoinGecko can dislike this.

## Limitations

CoinGecko discards intensive calls. I recommend do not use more than 5 widgets at the same time to avoid lose prices or to be blocked.
