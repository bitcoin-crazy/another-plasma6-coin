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
import org.kde.plasma.plasma5support as P5Support

Item {
    id: configRoot

    signal configurationChanged

    CoinModel {
        id: coinModel
    }

    // The user's own coins, from an optional file with the same format as CoinModel.qml.
    // They are added at the end of the list. See README.md, "Your own coins".
    readonly property int userCoinsMaxBytes: 65536
    readonly property int userCoinsMaxCount: 500

    // Pure function: returns the new coin names found in 'text', in file order.
    // 'knownNames' is an array of names that must not be repeated.
    // Only 'ListElement { name: "..." }' is read; // and /* */ comments are ignored.
    // Names must be letters and numbers only, so they are always safe to use in the API URL.
    function parseUserCoins(text, knownNames, maxCount) {
        const seen = {};
        for (let i = 0; i < knownNames.length; i++) {
            seen[String(knownNames[i]).toUpperCase()] = true;
        }
        const clean = String(text).replace(/\/\*[\s\S]*?\*\//g, "").replace(/\/\/.*$/gm, "");
        const re = /ListElement\s*\{\s*name\s*:\s*"([^"]*)"\s*\}/g;
        const result = [];
        let m;
        while ((m = re.exec(clean)) !== null && result.length < maxCount) {
            const name = m[1].trim().toUpperCase();
            if (!/^[A-Z0-9]{1,20}$/.test(name) || seen[name]) {
                continue;
            }
            seen[name] = true;
            result.push(name);
        }
        return result;
    }

    function addUserCoins(text) {
        const known = [];
        for (let i = 0; i < coinModel.count; i++) {
            known.push(coinModel.get(i).name);
        }
        const names = parseUserCoins(text, known, userCoinsMaxCount);
        for (let i = 0; i < names.length; i++) {
            coinModel.append({ name: names[i] });
        }
        // The saved coin may be one of the user's coins, which was not in the list yet
        if (names.length > 0) {
            const index = nameFromCrypto.indexOfValue(cryptoValue.coinName);
            if (index >= 0) {
                nameFromCrypto.currentIndex = index;
            }
        }
    }

    // Reads ~/.ap6c.CoinModel, if it exists.
    // If the file is missing or this fails, nothing happens: the built-in list is used.
    P5Support.DataSource {
        id: userCoinsReader
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            disconnectSource(sourceName);
            if (data["exit code"] === 0) {
                addUserCoins(data["stdout"]);
            }
        }
        Component.onCompleted: connectSource("head -c " + userCoinsMaxBytes + " \"$HOME/.ap6c.CoinModel\"")
    }

    CurrencyModel {
        id: currencyModel
    }

    // Where the prices come from. 'value' is saved in the configuration (priceProvider).
    ListModel {
        id: providerModel
        ListElement { name: "Binance"; value: "binance" }
        ListElement { name: "Coinbase"; value: "coinbase" }
    }

    QtObject {
        id: cryptoValue
        property var currency
        property var priceProvider
        property var coinName
        property var coinNameAbbreviation
        property var showPair
    }

    property alias cfg_enabled: enabledCheckBox.checked
    property alias cfg_fontSize: fontsizedefault.value
    property alias cfg_textBold: boldTextCkeck.checked
    property alias cfg_coinName: cryptoValue.coinName
    property alias cfg_currency: cryptoValue.currency
    property alias cfg_priceProvider: cryptoValue.priceProvider
    property alias cfg_showCoinName: showCoinNameCheckBox.checked
    property alias cfg_showPair: showPairCheckBox.checked
    property alias cfg_decimalPlaces: decimalPlacesSpinBox.value
    property alias cfg_horizontalLayout: horizontalLayoutCheckBox.checked
    property alias cfg_priceMultiplier: priceMultiplierField.text
    property alias cfg_useThousandsSeparator: thousandsSeparatorCheckBox.checked
    property alias cfg_swapCommasDots: swapCommasDotsCheckBox.checked
    property alias cfg_textColor: textColorField.text
    property alias cfg_errorColor: errorColorField.text
    property alias cfg_timeRefresh: timeRefreshSpinBox.value
    property alias cfg_blinkRefresh: blinkRefreshCheckBox.checked

    ScrollView {
        width: parent.width
        height: parent.height

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

                // Enabled
                Label {
                    Layout.minimumWidth: root.width / 2
                    text: i18n("Enabled:")
                    horizontalAlignment: Label.AlignRight
                }
                CheckBox {
                    id: enabledCheckBox
                    text: i18n("")
                    onCheckedChanged: { configurationChanged() }
                    ToolTip.visible: hovered
                    ToolTip.text: i18n("Enable or disable the applet. If disabled, a \"X\" will be displayed.")
                }

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

                // Price Provider
                Label {
                    Layout.minimumWidth: root.width / 2
                    text: i18n("Price Provider:")
                    horizontalAlignment: Label.AlignRight
                }
                ComboBox {
                    textRole: "name"
                    valueRole: "value"
                    id: priceProviderComboBox
                    model: providerModel
                    onActivated: {
                        cryptoValue.priceProvider = currentValue
                    }
                    Component.onCompleted: currentIndex = Math.max(0, indexOfValue(cryptoValue.priceProvider))
                    ToolTip.visible: hovered
                    ToolTip.text: i18n("Where the prices come from. Binance is faster and recommended. Use Coinbase if Binance is blocked in your country. Coinbase has fewer coins and no USDT/USDC pairs for some coins: an unavailable pair shows Err.")
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
                    ToolTip.visible: hovered
                    ToolTip.text: i18n("More coins? See the README at https://github.com/bitcoin-crazy/another-plasma6-coin (section Your own coins)")
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
                    ToolTip.visible: hovered
                    ToolTip.text: i18n("More currencies? See the README at https://github.com/bitcoin-crazy/another-plasma6-coin")
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
                    text: i18n("Show Pair (ex: BTC/USDT):")
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

                // Horizontal Layout
                Label {
                    Layout.minimumWidth: root.width / 2
                    text: i18n("Horizontal Layout:")
                    horizontalAlignment: Label.AlignRight
                }
                CheckBox {
                    id: horizontalLayoutCheckBox
                    text: i18n("")
                    checked: false
                    onCheckedChanged: configurationChanged()
                    ToolTip.visible: hovered
                    ToolTip.text: i18n("Show the coin name (or pair) and the price in a single line (e.g., BTC/USDT 100,000). Useful for small panels.")
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
                    value: 0
                    stepSize: 1
                    onValueChanged: configurationChanged()
                }

                // Price Multiplier with tooltip
                Item {
                    Layout.minimumWidth: root.width / 2
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        anchors.fill: parent
                        spacing: 2

                        Label {
                            text: i18n("Price Multiplier:")
                            horizontalAlignment: Label.AlignRight
                            verticalAlignment: Label.AlignVCenter
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                            Layout.fillWidth: true
                        }
                    }
                }

                TextField {
                    id: priceMultiplierField
                    text: "1"
                    onTextChanged: {
                        // Check for 4 decimal places
                        var regex = /^[0-9]*\.?[0-9]{0,8}$/;
                        if (!regex.test(priceMultiplierField.text)) {
                            priceMultiplierField.text = priceMultiplierField.text.slice(0, -1);
                        }
                        configurationChanged()
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: i18n("Multiply price by this value. Use only numbers (example: 1.3812). Max 8 decimal places. Default: 1. An asterisk will be placed near of the coin/pair name to symbolize the use of this feature. See the README at https://github.com/bitcoin-crazy/another-plasma6-coin for details.")
                }

                // Thousands Separator
                Label {
                    Layout.minimumWidth: root.width / 2
                    text: i18n("Thousands Separator:")
                    horizontalAlignment: Label.AlignRight
                }
                CheckBox {
                    id: thousandsSeparatorCheckBox
                    text: i18n("")
                    checked: false
                    onCheckedChanged: configurationChanged()
                    ToolTip.visible: hovered
                    ToolTip.text: i18n("Format numbers with a thousands separator (e.g., 1,000.23).")
                }

                // Swap commas-dots
                Label {
                    Layout.minimumWidth: root.width / 2
                    text: i18n("Swap commas-dots:")
                    horizontalAlignment: Label.AlignRight
                }
                CheckBox {
                    id: swapCommasDotsCheckBox
                    text: i18n("")
                    onCheckedChanged: configurationChanged()
                    ToolTip.visible: hovered
                    ToolTip.text: i18n("Swap commas for dots and vice-versa to match usage in each country.")
                }

                // Text Color
                Label {
                    Layout.minimumWidth: root.width / 2
                    text: i18n("Text Color:")
                    horizontalAlignment: Label.AlignRight
                }
                TextField {
                    id: textColorField
                    text: ""
                    onTextChanged: configurationChanged()
                    ToolTip.visible: hovered
                    ToolTip.text: i18n("Use color names (red, yellowgreen) or HEX code (#ffff00 for yellow). Leave empty to use the theme's default color. Tips in README at https://github.com/bitcoin-crazy/another-plasma6-coin")
                }

                // Error Color
                Label {
                    Layout.minimumWidth: root.width / 2
                    text: i18n("Error Color:")
                    horizontalAlignment: Label.AlignRight
                }
                TextField {
                    id: errorColorField
                    text: ""
                    onTextChanged: configurationChanged()
                    ToolTip.visible: hovered
                    ToolTip.text: i18n("Color of the text when an error occurs (Err). Use color names (red, orange) or HEX code (#ff0000). Leave empty to use the theme's default error color.")
                }

                // Time Refresh
                Label {
                    Layout.minimumWidth: root.width / 2
                    text: i18n("Time Refresh (minutes):")
                    horizontalAlignment: Label.AlignRight
                }
                SpinBox {
                    id: timeRefreshSpinBox
                    from: 1
                    to: 60
                    value: 3
                    stepSize: 1
                    onValueChanged: configurationChanged()
                    ToolTip.visible: hovered
                    ToolTip.text: i18n("Minutes to refresh the coin value. Valid range: 1–60.")
                }

                // Blink Refresh
                Label {
                    Layout.minimumWidth: root.width / 2
                    text: i18n("Blink Refresh:")
                    horizontalAlignment: Label.AlignRight
                }
                CheckBox {
                    id: blinkRefreshCheckBox
                    text: i18n("")
                    checked: true
                    onCheckedChanged: configurationChanged()
                    ToolTip.visible: hovered
                    ToolTip.text: i18n("Blink the price when it refreshes.")
                }

                // Applet version
                Label {
                    Layout.minimumWidth: root.width / 2
                    text: i18n("AP6 Coin, version:")
                    horizontalAlignment: Label.AlignRight
                }

                Label {
                    Layout.minimumWidth: root.width / 2
                    text: i18n("2.5    (2026-10-15)")
                }

                // Website
                Label {
                    Layout.minimumWidth: root.width / 2
                    text: i18n("AP6 Coin, website:")
                    horizontalAlignment: Label.AlignRight
                }

                Label {
                    Layout.minimumWidth: root.width / 2
                    text: "https://github.com/bitcoin-crazy/"
                }

            }  // Closing GridLayout
        }      // Closing ColumnLayout
    }          // Closing ScrollView
}              // Closing Item
