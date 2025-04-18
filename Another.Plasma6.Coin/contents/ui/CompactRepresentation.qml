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

    Layout.minimumWidth: coinNameText.implicitWidth + pixelFontVar * 4
    Layout.minimumHeight: heightroot

    Components.GetAPI {
        id: getApi
        coinName: Plasmoid.configuration.coinName
        currencyAbbreviation: Plasmoid.configuration.currency
    }

    // Determines which price text should be shown
    property string displayedPrice: {
        if (getApi.price === "E") {
            return "Err";
        }
        if (getApi.price !== null && !isNaN(getApi.price)) {
            return getApi.price.toFixed(Plasmoid.configuration.decimalPlaces);
        }
        return "?";
    }

    Text {
        id: coinNameText
        visible: Plasmoid.configuration.showCoinName
        width: wrapper.width
        font.pixelSize: pixelFontVar2
        color: Kirigami.Theme.textColor
        font.bold: Plasmoid.configuration.textBold
        font.capitalization: Font.AllUppercase
        text: Plasmoid.configuration.coinName
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
    }

    Text {
        id: coinPairText
        visible: Plasmoid.configuration.showPair
        width: wrapper.width
        font.pixelSize: pixelFontVar2
        color: Kirigami.Theme.textColor
        font.bold: Plasmoid.configuration.textBold
        font.capitalization: Font.AllUppercase
        text: Plasmoid.configuration.coinName + "/" + Plasmoid.configuration.currency.toUpperCase()
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
    }

    Text {
        id: priceText
        width: wrapper.width
        font.pixelSize: pixelFontVar
        color: displayedPrice === "Err" ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
        font.bold: Plasmoid.configuration.textBold
        font.capitalization: Font.AllUppercase
        text: displayedPrice
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
        height: 30
    }

    MouseArea {
        anchors.fill: priceText
        onClicked: {
            getApi.updatePrice(); // Update price when clicking
            priceFlash.start();   // Trigger visual feedback
        }
    }

    // Simple color animation for visual feedback
    ColorAnimation {
        id: priceFlash
        target: priceText
        property: "color"
        from: Kirigami.Theme.highlightColor
        to: displayedPrice === "Err" ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
        duration: 250
    }

    spacing: 0
}
