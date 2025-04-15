/*
 * SPDX-FileCopyrightText: zayronxio
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.12
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import "components" as Components

RowLayout {
    id: wrapper
    property int pixelFontVar: Plasmoid.configuration.fontSize
    Layout.minimumWidth: fulltext.implicitWidth + pixelFontVar*4
    Layout.minimumHeight: heightroot

    property int heightroot: 20

    property string coinName: Plasmoid.configuration.coinNameAbbreviation
    property string tx: coinName + "/" + Plasmoid.configuration.currency + " " + Plasmoid.configuration.symbol + " " + (getApi.price !== (-1) ? getApi.price : "?")

    Components.GetAPI {
        id: getApi
        coinName: Plasmoid.configuration.coinName
        currencyAbbreviation: Plasmoid.configuration.currency
    }


    CoinModel {
        id: coinModel
    }

    Text {
        id: fulltext
        height: parent.height
        width: wrapper.width
        font.pixelSize: pixelFontVar
        color: Kirigami.Theme.textColor
        font.bold: Plasmoid.configuration.textBold
        font.capitalization: Font.AllUppercase
        text: tx
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
