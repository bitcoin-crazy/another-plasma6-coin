import QtQuick

Item {
    property string coinName: ""
    property string currencyAbbreviation: ""
    property int decimalPlaces: 2
    property string combinedValues: coinName + currencyAbbreviation
    property int refreshRate: 3 // Refresh rate in minutes
    property real price: -1
    property bool isFirstConsultation: true
    property string link: "https://api.coingecko.com/api/v3/simple/price?ids=" + coinName + "&vs_currencies=" + currencyAbbreviation

    // Detect price changes
    onPriceChanged: {
        if (price !== -1 && price !== "") {
            updatePrice()
        }
    }

    onCombinedValuesChanged: {
        price = -1
        updatePrice()
    }

    function updatePrice() {
        link = "https://api.coingecko.com/api/v3/simple/price?ids=" + coinName + "&vs_currencies=" + currencyAbbreviation
        updateAPI(function(result) {
            if (result !== null) {
                // DEBUG only: console.log("Value from API:", result);

                // Storing numeric value
                price = parseFloat(result);

                // DEBUG only: console.log("Price catched:", price);
                isFirstConsultation = false;
            } else {
                retry.start();
            }
        });
    }

    // Update price from CoinGecko API
    function updateAPI(callback) {
        let url = link;
        let req = new XMLHttpRequest();
        req.open("GET", url, true);

        req.onreadystatechange = function () {
            if (req.readyState === 4) {
                if (req.status === 200) {
                    let datos = JSON.parse(req.responseText);
                    let coin = datos[coinName];

                    if (coin && coin[currencyAbbreviation]) {
                        let priceInCurrency = coin[currencyAbbreviation];
                        // DEBUG only: console.log("Full reply from API:", JSON.stringify(datos, null, 2));
                        // DEBUG only: console.log("Coin price:", priceInCurrency);
                        callback(priceInCurrency);
                    } else {
                        // DEBUG only: console.error("Error: no data for the desired coin.");
                        callback(null);
                    }
                } else {
                    // DEBUG only: console.error(`Query error: ${req.status}`);
                    callback(null);
                }
            }
        };

        req.send();
    }

    Timer {
        id: retry
        interval: 15000 // Retry after 15 seconds
        repeat: false
        running: false
        onTriggered: {
            updatePrice()
        }
    }

    Timer {
        id: updateTimer
        interval: refreshRate * 60000 // Convert from minutes to milliseconds
        repeat: true
        running: true
        onTriggered: {
            updatePrice()
        }
    }

    Component.onCompleted: {
        updatePrice()
    }
}
