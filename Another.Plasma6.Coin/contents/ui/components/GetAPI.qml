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
        updateAPI(url);
    }

    function updateAPI(url) {
        const req = new XMLHttpRequest();
        req.open("GET", url, true);

        req.onreadystatechange = function () {
            if (req.readyState !== 4) return;

            if (req.status === 200) {
                const data = JSON.parse(req.responseText);
                price = parseFloat(data.price);
                inErrorState = false;
            } else {
                console.error(`AP6C: Query error: ${req.status}`);
                price = "E";
                inErrorState = true;
            }
            retry.start(); // Retry if there's an error or after successful fetch
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
