import QtQuick

Item {
    property string coinName: ""
    property string currencyAbbreviation: ""
    property int decimalPlaces: 2
    property int refreshRate: 3 // Refresh rate in minutes
    property var price: -1
    property bool inErrorState: false

    onCoinNameChanged: updatePrice()
    onCurrencyAbbreviationChanged: updatePrice()

    function updatePrice() {
        if (coinName === "" || currencyAbbreviation === "")
            return;

        const url = "https://api.binance.com/api/v3/ticker/price?symbol=" + coinName + currencyAbbreviation;

        updateAPI(url, function(result) {
            if (result === "E" || result === null) {
                price = "E";
                inErrorState = true;
                retry.start();
            } else {
                price = parseFloat(result);
                inErrorState = false;
            }
        });
    }

    function updateAPI(url, callback) {
        const req = new XMLHttpRequest();
        req.open("GET", url, true);

        req.onreadystatechange = function () {
            if (req.readyState !== 4) return;

            if (req.status === 200) {
                const data = JSON.parse(req.responseText);
                callback(data.price);
            } else if (req.status === 400) {
                console.log("AP6C: Error 400");
                callback("E");
            } else {
                console.error(`AP6C: Query error: ${req.status}`);
                callback(null);
            }
        };

        req.send();
    }

    Timer {
        id: retry
        interval: 60000 // Retry after 60 seconds
        repeat: false
        running: false
        onTriggered: updatePrice()
    }

    Timer {
        id: updateTimer
        interval: refreshRate * 60000 // Convert from minutes to milliseconds
        repeat: true
        running: true
        onTriggered: updatePrice()
    }

    Component.onCompleted: updatePrice()
}
