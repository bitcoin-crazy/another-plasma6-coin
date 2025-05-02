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

    // Function for thousands separator
    function formatPrice(price) {
        // Ensure price is always a number
        let numPrice = parseFloat(price);

        // Check if it's a valid number
        if (isNaN(numPrice)) {
            return price; // Return original value if not a valid number
        }

        // Apply thousand separator if needed
        let formattedPrice = numPrice.toFixed(Plasmoid.configuration.decimalPlaces);

        // If swapCommasDots is enabled, swap commas and dots
        if (Plasmoid.configuration.swapCommasDots) {
            // Swap the dot in the decimal place to a comma
            formattedPrice = formattedPrice.replace('.', ',');

            // Apply thousands separator using a dot (if thousands separator is enabled)
            if (Plasmoid.configuration.useThousandsSeparator) {
                formattedPrice = formattedPrice.replace(/\B(?=(\d{3})+(?!\d))/g, '.');
            }
        } else {
            // If swapCommasDots is not enabled, apply thousands separator with dot
            if (Plasmoid.configuration.useThousandsSeparator) {
                formattedPrice = formattedPrice.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
            }
        }

        // Return the formatted price
        return formattedPrice;
    }

    Layout.minimumWidth: coinNameText.implicitWidth + pixelFontVar * 4
    Layout.minimumHeight: heightroot

    Components.GetAPI {
        id: getApi
        coinName: Plasmoid.configuration.coinName
        currencyAbbreviation: Plasmoid.configuration.currency
        refreshRate: Plasmoid.configuration.timeRefresh || 3 // Integrating the refresh rate configuration
    }

    // Determine which price text should be shown with multiplier applied
    property string displayedPrice: {
        if (getApi.price === "E") {
            return "Err";
        }
        if (getApi.price !== null && !isNaN(getApi.price)) {
            // Apply price multiplier from configuration
            var price = parseFloat(getApi.price);
            var multiplier = Plasmoid.configuration.priceMultiplier || 1; // Default to 1 if multiplier is not set
            return formatPrice((price * multiplier).toFixed(Plasmoid.configuration.decimalPlaces));
        }
        return "?";
    }

    Text {
        id: coinNameText
        visible: Plasmoid.configuration.showCoinName
        width: wrapper.width
        font.pixelSize: pixelFontVar2
        color: {
            if (displayedPrice === "Err") {
                return Plasmoid.configuration.errorColor || Kirigami.Theme.negativeTextColor;
            }
            return Plasmoid.configuration.textColor || Kirigami.Theme.textColor;
        }
        font.bold: Plasmoid.configuration.textBold
        font.capitalization: Font.AllUppercase
        text: Plasmoid.configuration.coinName + (Plasmoid.configuration.priceMultiplier !== "1" && Plasmoid.configuration.priceMultiplier !== "" ? "*" : "")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
    }

    Text {
        id: coinPairText
        visible: Plasmoid.configuration.showPair
        width: wrapper.width
        font.pixelSize: pixelFontVar2
        color: {
            if (displayedPrice === "Err") {
                return Plasmoid.configuration.errorColor || Kirigami.Theme.negativeTextColor;
            }
            return Plasmoid.configuration.textColor || Kirigami.Theme.textColor;
        }
        font.bold: Plasmoid.configuration.textBold
        font.capitalization: Font.AllUppercase
        text: Plasmoid.configuration.coinName + "/" + Plasmoid.configuration.currency.toUpperCase() + (Plasmoid.configuration.priceMultiplier !== "1" && Plasmoid.configuration.priceMultiplier !== "" ? "*" : "")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
    }

    Text {
        id: priceText
        width: wrapper.width
        font.pixelSize: pixelFontVar
        color: {
            if (displayedPrice === "Err") {
                return Plasmoid.configuration.errorColor || Kirigami.Theme.negativeTextColor;
            }
            return Plasmoid.configuration.textColor || Kirigami.Theme.textColor;
        }
        font.bold: Plasmoid.configuration.textBold
        font.capitalization: Font.AllUppercase
        text: displayedPrice
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
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
        onClicked: {
            getApi.updatePrice(); // Update price when clicking
            fadeAnimation.start();
        }
    }

    // Simple color animation for visual feedback
    ColorAnimation {
        id: priceFlash
        target: priceText
        property: "color"
        from: Kirigami.Theme.highlightColor
        to: {
            if (displayedPrice === "Err") {
                return Plasmoid.configuration.errorColor || Kirigami.Theme.negativeTextColor;
            }
            return Plasmoid.configuration.textColor || Kirigami.Theme.textColor;
        }
        duration: 1000
    }

    SequentialAnimation {
        id: fadeAnimation
        running: false
        PropertyAnimation { target: priceText; property: "opacity"; to: 0.0; duration: 500 }
        PropertyAnimation { target: priceText; property: "opacity"; to: 1.0; duration: 500 }
    }

    Timer {
        id: autoUpdateTimer
        interval: Plasmoid.configuration.timeRefresh * 60000 // Convert from minutes to milliseconds
        repeat: true
        running: true
        onTriggered: {
            getApi.updatePrice(); // Trigger price update based on configured interval
            if (Plasmoid.configuration.blinkRefresh) {
                fadeAnimation.start();
            }
        }
    }

    spacing: 0
}
