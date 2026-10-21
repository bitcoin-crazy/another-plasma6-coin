/*
 * SPDX-FileCopyrightText: Copyright 2025 zayronxio
 * SPDX-FileCopyrightText: Copyright 2025 bitcoin-crazy
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-SnippetComment: Another Plasma6 Coin was initially based on Plasma Coin 1.0.2, from zayronxio.
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import "components" as Components

ColumnLayout {
    id: wrapper

    property int pixelFontVar: Plasmoid.configuration.fontSize
    property int pixelFontVar2: pixelFontVar * 0.7
    property int heightroot: 20

    // Function for thousands separator and decimal mark.
    // The thousands separator is applied to the integer part only; applying it
    // to the whole string would also split the decimals (1,234.5,678).
    function formatPrice(price) {
        // Ensure price is always a number
        let numPrice = parseFloat(price);

        // Check if it's a valid number
        if (isNaN(numPrice)) {
            return price; // Return original value if not a valid number
        }

        const parts = numPrice.toFixed(Plasmoid.configuration.decimalPlaces).split(".");
        let intPart = parts[0];
        const decPart = parts.length > 1 ? parts[1] : "";

        // swapCommasDots: dot as decimal mark and comma as thousands separator are swapped
        const swap = Plasmoid.configuration.swapCommasDots;

        if (Plasmoid.configuration.useThousandsSeparator) {
            intPart = intPart.replace(/\B(?=(\d{3})+(?!\d))/g, swap ? "." : ",");
        }

        return decPart !== "" ? intPart + (swap ? "," : ".") + decPart : intPart;
    }

    // Single line: "BTC 100000" or "BTC/USDT 100000", instead of stacked lines
    readonly property bool horizontal: Plasmoid.configuration.horizontalLayout

    Layout.minimumWidth: (horizontal ? priceText.implicitWidth : coinNameText.implicitWidth) + pixelFontVar * 4
    Layout.minimumHeight: heightroot

    Components.GetAPI {
        id: getApi
        provider: Plasmoid.configuration.priceProvider
        coinName: Plasmoid.configuration.coinName
        currencyAbbreviation: Plasmoid.configuration.currency
        refreshRate: Plasmoid.configuration.timeRefresh || 3 // Integrating the refresh rate configuration
        active: Plasmoid.configuration.enabled
        visible: false // Not a visual item: keep it out of the layout

        onAutoUpdateTriggered: {
            if (Plasmoid.configuration.blinkRefresh) {
                fadeAnimation.start();
            }
        }
    }

    // Any error (invalid pair, network, timeout, server) shows "Err".
    // No old price is ever displayed after a failure.
    readonly property bool showErr: getApi.inErrorState

    // One place to decide the color of all texts
    readonly property color currentTextColor: {
        if (showErr) {
            return Plasmoid.configuration.errorColor || Kirigami.Theme.negativeTextColor;
        }
        return Plasmoid.configuration.textColor || Kirigami.Theme.textColor;
    }

    // Coin name or pair shown before the price in horizontal layout (may be empty)
    readonly property string horizontalLabel: {
        if (Plasmoid.configuration.showCoinName) {
            return coinNameText.text;
        }
        if (Plasmoid.configuration.showPair) {
            return coinPairText.text;
        }
        return "";
    }

    // Determine which price text should be shown with multiplier applied
    property string displayedPrice: {
        if (!Plasmoid.configuration.enabled) {
            return "X";
        }
        if (showErr) {
            return "Err";
        }
        if (getApi.price !== null && !isNaN(getApi.price)) {
            // Apply price multiplier from configuration
            var multiplier = parseFloat(Plasmoid.configuration.priceMultiplier);
            if (isNaN(multiplier)) {
                multiplier = 1; // Empty or invalid multiplier: ignore it
            }
            return formatPrice(getApi.price * multiplier);
        }
        return "?";
    }

    Text {
        id: disabledText
        visible: !Plasmoid.configuration.enabled
        width: wrapper.width
        font.pixelSize: pixelFontVar
        font.bold: true
        color: Plasmoid.configuration.textColor || Kirigami.Theme.textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: "X"
    }

    Text {
        id: coinNameText
        visible: Plasmoid.configuration.showCoinName && Plasmoid.configuration.enabled && !horizontal
        width: wrapper.width
        font.pixelSize: pixelFontVar2
        color: currentTextColor
        font.bold: Plasmoid.configuration.textBold
        font.capitalization: Font.AllUppercase
        text: Plasmoid.configuration.coinName + (Plasmoid.configuration.priceMultiplier !== "1" && Plasmoid.configuration.priceMultiplier !== "" ? "*" : "")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
    }

    Text {
        id: coinPairText
        visible: Plasmoid.configuration.showPair && Plasmoid.configuration.enabled && !horizontal
        width: wrapper.width
        font.pixelSize: pixelFontVar2
        color: currentTextColor
        font.bold: Plasmoid.configuration.textBold
        font.capitalization: Font.AllUppercase
        text: Plasmoid.configuration.coinName + "/" + Plasmoid.configuration.currency.toUpperCase() + (Plasmoid.configuration.priceMultiplier !== "1" && Plasmoid.configuration.priceMultiplier !== "" ? "*" : "")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
    }

    Text {
        id: priceText
        visible: Plasmoid.configuration.enabled
        width: wrapper.width
        font.pixelSize: pixelFontVar
        color: currentTextColor
        font.bold: Plasmoid.configuration.textBold
        font.capitalization: Font.AllUppercase
        text: (horizontal && horizontalLabel !== "" && Plasmoid.configuration.enabled ? horizontalLabel + " " : "") + displayedPrice
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
        wrapMode: horizontal ? Text.NoWrap : Text.WordWrap
        height: 30
        opacity: 1.0

        Behavior on opacity {
            NumberAnimation {
                duration: 1000
            }
        }
    }

    MouseArea {
        anchors.fill: priceText
        enabled: Plasmoid.configuration.enabled
        onClicked: {
            getApi.updatePrice(); // Update price when clicking
            fadeAnimation.start();
        }
    }

    SequentialAnimation {
        id: fadeAnimation
        running: false
        PropertyAnimation { target: priceText; property: "opacity"; to: 0.0; duration: 500 }
        PropertyAnimation { target: priceText; property: "opacity"; to: 1.0; duration: 500 }
    }

    spacing: 0
}
