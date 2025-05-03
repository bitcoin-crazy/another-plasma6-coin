#!/bin/bash

# SPDX-FileCopyrightText: Copyright 2025 bitcoin-crazy
# SPDX-License-Identifier: GPL-3.0-or-later

# check-top-100.sh - shows a list of top 100 coins not present in A.P6.C

[ -e ChangeLog ] || { echo "Wrong directory. Exiting."; exit 1; }

[ -d top100 ] || mkdir top100

# coinranking is free for top 100 coins only
curl -s https://api.coinranking.com/v2/coins?limit=100 | tr ',' '\n' | grep symbol | cut -d: -f2 | tr -d '"' > top100/list.coinranking.com
[ -s top100/list.coinranking.com ] || { echo "API ERROR (coinranking)"; exit 1; }

curl -s https://api.binance.com/api/v3/ticker/price | tr '{' '\n' | egrep '[A-Z]USDT' | cut -d'"' -f 4 | sed 's/USDT//g' > top100/list.binance
[ -s top100/list.binance ] || { echo "API ERROR (binance)"; exit 1; }

cat Another.Plasma6.Coin/contents/ui/CoinModel.qml | grep ListElement | cut -d: -f2 | tr -d '[ "}]' > top100/list.ap6c
[ -s top100/list.ap6c ] || { echo "Local list ERROR"; exit 1; }

# Coins available in one side only (or on coinranking, or on ap6c)
cat top100/list.coinranking.com top100/list.ap6c | sort | uniq -u > top100/list.diff.tmp

# Excluding coins not available on Binance
> top100/list.diff
for i in $(cat top100/list.diff.tmp);
do
    cat top100/list.binance | egrep ^$i$ >> top100/list.diff
done

# Final lists
echo -e "\nOnly on coinranking:\n"

    for i in $(cat top100/list.diff)
    do
        cat top100/list.coinranking.com | grep $i
    done

echo -e "\nOnly on A.P6.C (including some coins out of range of the TOP 100 coins):\n"

    for i in $(cat top100/list.diff)
    do
        cat top100/list.ap6c | grep $i
    done
