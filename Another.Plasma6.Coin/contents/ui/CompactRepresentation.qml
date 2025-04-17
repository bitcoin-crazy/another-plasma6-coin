/*
 * SPDX-FileCopyrightText: Copyright 2025 zayronxio
 * SPDX-FileCopyrightText: Copyright 2025 bitcoin-crazy
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-SnippetComment: Another Plasma6 Coin was initially based on Plasma Coin 1.0.2, from zayronxio.
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import "components" as Components

ColumnLayout {
    id: wrapper
    property int pixelFontVar: Plasmoid.configuration.fontSize
    property int pixelFontVar2: pixelFontVar * 0.7
    Layout.minimumWidth: coinNameText.implicitWidth + pixelFontVar * 4
    Layout.minimumHeight: heightroot

    property int heightroot: 20
    property string coinName: Plasmoid.configuration.coinName
    property string price: {
        let formattedPrice = getApi.price !== (-1) && !isNaN(getApi.price) ? getApi.price : -1;
        if (formattedPrice !== -1) {
            return formattedPrice.toFixed(Plasmoid.configuration.decimalPlaces);
        }
        return "?";
    }

    Components.GetAPI {
        id: getApi
        coinName: Plasmoid.configuration.coinName
        currencyAbbreviation: Plasmoid.configuration.currency
    }

    Text {
        id: coinNameText
        visible: Plasmoid.configuration.showCoinName
        width: wrapper.width
        font.pixelSize: pixelFontVar2
        color: Kirigami.Theme.textColor
        font.bold: Plasmoid.configuration.textBold
        font.capitalization: Font.AllUppercase
        text: coinName
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
        color: Kirigami.Theme.textColor
        font.bold: Plasmoid.configuration.textBold
        font.capitalization: Font.AllUppercase
        text: price
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
        height: 30
    }

    spacing: 0
}
