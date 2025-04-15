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
        property var symbol
        property var coinNameAbbreviation
    }

    property alias cfg_coinName: cryptoValue.coinName
    property alias cfg_currency: cryptoValue.currency
    property alias cfg_symbol: cryptoValue.symbol
    property alias cfg_fontSize: fontsizedefault.value
    property alias cfg_textBold: boldTextCkeck.checked
    property alias cfg_coinNameAbbreviation: cryptoValue.coinNameAbbreviation

    ColumnLayout {
        Layout.preferredWidth: parent.width - Kirigami.Units.largeSpacing *2
        Layout.minimumWidth: preferredWidth
        Layout.maximumWidth: preferredWidth
        spacing: units.smallSpacing * 3
        GridLayout{
            Layout.preferredWidth: parent.width
            Layout.minimumWidth: preferredWidth
            Layout.maximumWidth: preferredWidth
            columns: 2

            Label {
                id: refrestitle
                Layout.minimumWidth: root.width/2
                text: i18n("Font Size:")
                horizontalAlignment: Label.AlignRight
            }
            SpinBox {
                from: 5
                id: fontsizedefault
                to: 40
            }
            Label {
            }
            Label {
            }
            Label {
                Layout.minimumWidth: root.width/2
                text: i18n("Bold:")
                horizontalAlignment: Label.AlignRight
            }

            CheckBox{
                id: boldTextCkeck
                text: i18n("")
            }
            Label {
            }
            Label {
            }
            Label {
                Layout.minimumWidth: root.width/2
                text: i18n("From Crypto:")
                horizontalAlignment: Label.AlignRight
            }
            ComboBox {
                textRole: "name"
                valueRole: "name"
                id: nameFromCrypto
                model: coinModel
                onActivated: {
                    cryptoValue.coinName = currentValue
                    cryptoValue.coinNameAbbreviation = model.get(currentIndex).abbreviation
                }
                Component.onCompleted: currentIndex = indexOfValue(cryptoValue.coinName)
            }
            Label {
                Layout.minimumWidth: root.width/2
                text: i18n("From Crypto:")
                horizontalAlignment: Label.AlignRight
            }
            ComboBox {
                textRole: "name"
                valueRole: "abbreviation"
                id: nameToCurrency
                model: currencyModel
                onActivated: {
                    cryptoValue.currency = currentValue
                    cryptoValue.symbol = currencyModel.get(currentIndex).symbol
                }
                Component.onCompleted: currentIndex = indexOfValue(cryptoValue.currency)
            }


        }
    }

}
