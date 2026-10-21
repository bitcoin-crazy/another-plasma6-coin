#!/bin/bash

# SPDX-FileCopyrightText: Copyright 2025 bitcoin-crazy
# SPDX-License-Identifier: GPL-3.0-or-later

# check-coinmodel.sh - verify if coins exist on Binance

[ -e ChangeLog ] || { echo "Wrong directory. Exiting."; exit 1; }

[ -d top100 ] || mkdir top100

curl -s https://api.binance.com/api/v3/ticker/price | tr '{' '\n'| grep USDT | cut -d'"' -f4 > top100/all_binance_coins || { echo "Error when getting coins. Exiting."; exit 1; }

for i in $(cat Another.Plasma6.Coin/contents/ui/CoinModel.qml | grep ListElement | cut -d'"' -f2)
do
    cat top100/all_binance_coins | grep $i > /dev/null || { echo "$i not present in Binance. Exiting."; exit 1; }
done
