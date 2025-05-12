/*
 * SPDX-FileCopyrightText: Copyright 2025 zayronxio
 * SPDX-FileCopyrightText: Copyright 2025 bitcoin-crazy
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-SnippetComment: Another Plasma6 Coin was initially based on Plasma Coin 1.0.2, from zayronxio.
 */
import QtQuick

Item {
    property string coinName: ""
    property string currencyAbbreviation: ""
    property int decimalPlaces: 2
    property int refreshRate: Plasmoid.configuration.timeRefresh || 3 // Refresh rate in minutes, linked to config
    property var price: null // Set no initial price
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
        req.timeout = 20000; // Timeout after 20 seconds

        req.onreadystatechange = function () {
            if (req.readyState !== 4) return;

            requestTimeoutWatchdog.stop(); // Stop watchdog if request completed

            if (req.status === 200) {
                try {
                    const data = JSON.parse(req.responseText);
                    price = parseFloat(data.price); // Parse and store the price
                    inErrorState = false;
                } catch (e) {
                    console.error("AP6C: Error parsing API response:", e);
                    price = "E"; // Use 'E' to indicate error
                    inErrorState = true;
                    retry.start(); // Retry if parsing fails
                }
            } else {
                console.error(`AP6C: Query failed with status: ${req.status}`);
                price = "E"; // Use 'E' to indicate HTTP error
                inErrorState = true;
                retry.start(); // Retry on error
            }
        };

        req.ontimeout = function () {
            console.error("AP6C: Request timed out");
            requestTimeoutWatchdog.stop(); // Stop watchdog if request completed
            price = "E"; // Use 'E' to indicate timeout
            inErrorState = true;
            retry.start(); // Retry on timeout
        };

        req.send();
        requestTimeoutWatchdog.restart(); // Start the fallback watchdog
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

    Timer {
        id: requestTimeoutWatchdog
        interval: 20000 // 20 seconds fallback timeout
        repeat: false
        running: false
        onTriggered: {
            console.error("AP6C: Watchdog triggered — request likely failed silently");
            price = "E";
            inErrorState = true;
            retry.start();
        }
    }

    Component.onCompleted: updatePrice()
}
