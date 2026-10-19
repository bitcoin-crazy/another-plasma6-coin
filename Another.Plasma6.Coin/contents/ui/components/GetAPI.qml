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
    property int refreshRate: 3 // Refresh rate in minutes, set by the parent from the config
    property bool active: true  // When false, no automatic requests are made

    // Last price received (a number), or null when there is none.
    // It is never kept after a failure: an old price must not be mistaken for the current one.
    property var price: null
    // True when the last request failed (network, timeout, HTTP error, bad data).
    property bool inErrorState: false
    // True when Binance rejected the pair itself (HTTP 400, e.g. SOL/CZK does not exist).
    property bool invalidPair: false

    // Emitted by the automatic refresh timer only (not by clicks or retries),
    // so the parent can blink the price when "Blink Refresh" is enabled.
    signal autoUpdateTriggered()

    // Used to ignore answers that arrive after a newer request was sent.
    property int requestSeq: 0

    // A change of coin or currency invalidates the price shown so far.
    onCoinNameChanged: pairChanged()
    onCurrencyAbbreviationChanged: pairChanged()
    onActiveChanged: {
        if (active)
            refreshSoon.restart();
        else
            retry.stop();
    }

    function pairChanged() {
        price = null;
        inErrorState = false;
        invalidPair = false;
        refreshSoon.restart(); // Debounced: coin and currency usually change together
    }

    function updatePrice() {
        if (!active || coinName === "" || currencyAbbreviation === "")
            return;

        const url = "https://api.binance.com/api/v3/ticker/price?symbol=" + coinName + currencyAbbreviation;
        updateAPI(url);
    }

    function updateAPI(url) {
        const seq = ++requestSeq;
        const req = new XMLHttpRequest();
        let finished = false;

        // Called once per request, by whichever event comes first.
        function finish(newPrice, transientError, pairRejected) {
            if (finished)
                return;
            finished = true;

            if (seq !== requestSeq)
                return; // A newer request exists: this answer is stale

            requestTimeoutWatchdog.stop();

            if (pairRejected) {
                console.error("AP6C: Binance rejected the pair " + coinName + currencyAbbreviation);
                price = null;
                inErrorState = true;
                invalidPair = true;
                retry.stop();
            } else if (transientError) {
                // Temporary failure: drop the old price and try again later.
                price = null;
                inErrorState = true;
                invalidPair = false;
                retry.start();
            } else {
                price = newPrice;
                inErrorState = false;
                invalidPair = false;
                retry.stop();
            }
        }

        req.open("GET", url, true);
        req.timeout = 20000; // Timeout after 20 seconds

        req.onreadystatechange = function () {
            if (req.readyState !== 4)
                return;

            if (req.status === 200) {
                try {
                    const data = JSON.parse(req.responseText);
                    const p = parseFloat(data.price);
                    if (isNaN(p))
                        throw new Error("no numeric price in response");
                    finish(p, false, false);
                } catch (e) {
                    console.error("AP6C: Error parsing API response:", e);
                    finish(null, true, false);
                }
            } else if (req.status === 400) {
                finish(null, false, true);
            } else {
                console.error(`AP6C: Query failed with status: ${req.status}`);
                finish(null, true, false);
            }
        };

        req.ontimeout = function () {
            console.error("AP6C: Request timed out");
            finish(null, true, false);
        };

        req.send();
        requestTimeoutWatchdog.restart(); // Fallback in case the request fails silently
    }

    // Retry after a transient failure
    Timer {
        id: retry
        interval: 60000 // Retry after 60 seconds
        repeat: false
        running: false
        onTriggered: updatePrice()
    }

    // Regular refresh
    Timer {
        id: updateTimer
        interval: Math.max(1, refreshRate) * 60000 // Convert from minutes to milliseconds
        repeat: true
        running: active
        onTriggered: {
            autoUpdateTriggered();
            updatePrice();
        }
    }

    // Groups the several triggers at startup (and on pair change) into one request
    Timer {
        id: refreshSoon
        interval: 200
        repeat: false
        running: false
        onTriggered: updatePrice()
    }

    Timer {
        id: requestTimeoutWatchdog
        interval: 21000 // Slightly above req.timeout, so the normal timeout path wins
        repeat: false
        running: false
        onTriggered: {
            console.error("AP6C: Watchdog triggered — request likely failed silently");
            requestSeq++; // Anything still pending for the old request is now stale
            price = null;
            inErrorState = true;
            invalidPair = false;
            retry.start();
        }
    }

    Component.onCompleted: refreshSoon.restart()
}
