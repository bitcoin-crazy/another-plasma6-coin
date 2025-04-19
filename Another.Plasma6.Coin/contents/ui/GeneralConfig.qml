/*
 * SPDX-FileCopyrightText: Copyright 2025 zayronxio
 * SPDX-FileCopyrightText: Copyright 2025 bitcoin-crazy
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-SnippetComment: Another Plasma6 Coin was initially based on Plasma Coin 1.0.2, from zayronxio.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.11
import org.kde.kirigami as Kirigami

Item {
    id: configRoot

    signal configurationChanged

    CoinModel {
        id: coinModel
    }

    CurrencyModel {
        id: currencyModel
    }

    QtObject {
        id: cryptoValue
        property var currency
        property var coinName
        property var coinNameAbbreviation
        property var showPair
    }

    property alias cfg_coinName: cryptoValue.coinName
    property alias cfg_currency: cryptoValue.currency
    property alias cfg_fontSize: fontsizedefault.value
    property alias cfg_textBold: boldTextCkeck.checked
    property alias cfg_showCoinName: showCoinNameCheckBox.checked
    property alias cfg_showPair: showPairCheckBox.checked
    property alias cfg_decimalPlaces: decimalPlacesSpinBox.value
    property alias cfg_textColor: textColorField.text

    ColumnLayout {
        Layout.preferredWidth: parent.width - Kirigami.Units.largeSpacing * 2
        Layout.minimumWidth: preferredWidth
        Layout.maximumWidth: preferredWidth
        spacing: Kirigami.Units.smallSpacing * 3

        GridLayout {
            Layout.preferredWidth: parent.width
            Layout.minimumWidth: preferredWidth
            Layout.maximumWidth: preferredWidth
            columns: 2

            // Font size
            Label {
                Layout.minimumWidth: root.width / 2
                text: i18n("Font Size for Price:")
                horizontalAlignment: Label.AlignRight
            }
            SpinBox {
                from: 5
                id: fontsizedefault
                to: 40
            }

            // Bold text
            Label {
                Layout.minimumWidth: root.width / 2
                text: i18n("Bold:")
                horizontalAlignment: Label.AlignRight
            }
            CheckBox {
                id: boldTextCkeck
                text: i18n("")
            }

            // From Crypto with tooltip
            Item {
                Layout.minimumWidth: root.width / 2
                Layout.fillWidth: true
                Layout.fillHeight: true
                RowLayout {
                    anchors.fill: parent
                    spacing: 2

                    Label {
                        text: i18n("From Crypto:")
                        horizontalAlignment: Label.AlignRight
                        verticalAlignment: Label.AlignVCenter
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        Layout.fillWidth: true
                    }
                    ToolButton {
                        icon.name: "help-about"
                        implicitWidth: Kirigami.Units.iconSizes.small
                        implicitHeight: Kirigami.Units.iconSizes.small
                        ToolTip.visible: hovered
                        ToolTip.text: i18n("More coins? See the README at https://github.com/bitcoin-crazy/another-plasma6-coin")
                        hoverEnabled: true
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }
            ComboBox {
                textRole: "name"
                valueRole: "name"
                id: nameFromCrypto
                model: coinModel
                onActivated: {
                    cryptoValue.coinName = currentValue
                }
                Component.onCompleted: currentIndex = indexOfValue(cryptoValue.coinName)
            }

            // To Crypto with tooltip
            Item {
                Layout.minimumWidth: root.width / 2
                Layout.fillWidth: true
                Layout.fillHeight: true
                RowLayout {
                    anchors.fill: parent
                    spacing: 2

                    Label {
                        text: i18n("To Crypto/Currency:")
                        horizontalAlignment: Label.AlignRight
                        verticalAlignment: Label.AlignVCenter
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        Layout.fillWidth: true
                    }
                    ToolButton {
                        icon.name: "help-about"
                        implicitWidth: Kirigami.Units.iconSizes.small
                        implicitHeight: Kirigami.Units.iconSizes.small
                        ToolTip.visible: hovered
                        ToolTip.text: i18n("More currencies? See the README at https://github.com/bitcoin-crazy/another-plasma6-coin")
                        hoverEnabled: true
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }
            ComboBox {
                textRole: "name"
                valueRole: "abbreviation"
                id: nameToCurrency
                model: currencyModel
                onActivated: {
                    cryptoValue.currency = currentValue
                }
                Component.onCompleted: currentIndex = indexOfValue(cryptoValue.currency)
            }

            // Show Coin Name
            Label {
                Layout.minimumWidth: root.width / 2
                text: i18n("Show Coin Name (ex: BTC):")
                horizontalAlignment: Label.AlignRight
            }
            CheckBox {
                id: showCoinNameCheckBox
                text: i18n("")
                checked: true
                onCheckedChanged: {
                    configurationChanged()
                    if (checked) {
                        showPairCheckBox.checked = false
                    }
                }
            }

            // Show Pair
            Label {
                Layout.minimumWidth: root.width / 2
                text: i18n("Show Pair (ex: BTC/USD):")
                horizontalAlignment: Label.AlignRight
            }
            CheckBox {
                id: showPairCheckBox
                text: i18n("")
                checked: false
                onCheckedChanged: {
                    configurationChanged()
                    if (checked) {
                        showCoinNameCheckBox.checked = false
                    }
                }
            }

            // Decimal Places
            Label {
                Layout.minimumWidth: root.width / 2
                text: i18n("Decimal Places:")
                horizontalAlignment: Label.AlignRight
            }
            SpinBox {
                id: decimalPlacesSpinBox
                from: 0
                to: 10
                value: 2
                stepSize: 1
                onValueChanged: configurationChanged()
            }

            // Choose color
            Item {
                Layout.minimumWidth: root.width / 2
                Layout.fillWidth: true
                Layout.fillHeight: true
                RowLayout {
                    anchors.fill: parent
                    spacing: 2

                    Label {
                        text: i18n("Text Color (empty=default):")
                        horizontalAlignment: Label.AlignRight
                        verticalAlignment: Label.AlignVCenter
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        Layout.fillWidth: true
                    }
                    ToolButton {
                        icon.name: "help-about"
                        implicitWidth: Kirigami.Units.iconSizes.small
                        implicitHeight: Kirigami.Units.iconSizes.small
                        ToolTip.visible: hovered
                        ToolTip.text: i18n("Use color names (red, yellowgreen) or HEX code (#ffff00 for yellow). Leave empty to use the theme's default color.")
                        hoverEnabled: true
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }
            TextField {
                id: textColorField
                text: Plasmoid.configuration.textColor || ""
                placeholderText: i18n("Name color or HEX (#RRGGBB)")
                onTextChanged: configRoot.configurationChanged()
            }
        }
    }
}
