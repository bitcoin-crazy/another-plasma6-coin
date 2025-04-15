import QtQuick

Item {
    property string coinName: ""
    property string currencyAbbreviation: ""

    property string combinedValues: coinName+currencyAbbreviation
    property int refreshRate: 15 // Tasa de actualización en minutos
    property int price: -1
    property bool isFirstConsultation: true
    property string link: "https://api.coingecko.com/api/v3/simple/price?ids=" + coinName + "&vs_currencies=" + currencyAbbreviation

    // Detecta cambios en el precio
    onPriceChanged: {
        if (price !== -1 && price !== "") {
            update()
        }
    }
    onCombinedValuesChanged: {
        price = (-1)
        updateNow()
    }

    function updateNow() {
        link = "https://api.coingecko.com/api/v3/simple/price?ids=" + coinName + "&vs_currencies=" + currencyAbbreviation
        updatePrice(function(result) {
            if (result) {
                price = parseInt(result);
                isFirstConsultation = false;
            } else {
                retry.start();
            }
        });
    }

    // Función para actualizar el precio desde la API de CoinGecko
    function updatePrice(callback) {
        let url = link;

        let req = new XMLHttpRequest();
        req.open("GET", url, true);

        req.onreadystatechange = function () {
            if (req.readyState === 4) {
                if (req.status === 200) {
                    let datos = JSON.parse(req.responseText);
                    let coin = datos[coinName];
                    let priceInCurrency = coin[currencyAbbreviation];

                    callback(priceInCurrency);
                    console.log(coin)
                } else {
                    console.error(`Error en la solicitud: ${req.status}`);
                    callback(null); // En caso de error, devuelve null al callback
                }
            }
        };

        req.send();
    }

    // Temporizador para reintentar solicitudes fallidas
    Timer {
        id: retry
        interval: 5000 // Reintenta cada 5 segundos
        repeat: false
        running: false
        onTriggered: {
            updateNow()
        }
    }

    // Temporizador para actualizaciones periódicas
    Timer {
        id: update
        interval: refreshRate * 60000 // Convierte minutos a milisegundos
        repeat: true
        running: true
        onTriggered: {
            updateNow()
        }
    }

    // Primera consulta al completar el componente
    Component.onCompleted: {
        updateNow()
    }
}
