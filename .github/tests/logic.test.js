// SPDX-License-Identifier: GPL-3.0-or-later
//
// Tests of the pure JavaScript functions of the applet.
//
// The functions are extracted from the QML files, so the tests run the real code
// (not a copy). To be found, each function must start with exactly 4 spaces
// ("    function name(") and end with a line that has only 4 spaces and "}".
//
// Run from the repository root:  node --test .github/tests/logic.test.js

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const UI = path.resolve(__dirname, '..', '..', 'Another.Plasma6.Coin', 'contents', 'ui');

function extractFunction(file, name) {
  const src = fs.readFileSync(path.join(UI, file), 'utf8').replace(/\r\n/g, '\n');
  const start = src.indexOf(`    function ${name}(`);
  assert.ok(start >= 0, `function ${name}() not found in ${file}`);
  const end = src.indexOf('\n    }\n', start);
  assert.ok(end >= 0, `end of function ${name}() not found in ${file}`);
  return src.slice(start, end + 6).trim();
}

// formatPrice() reads Plasmoid.configuration, so a fake Plasmoid is given to it.
const formatPriceCode = extractFunction('CompactRepresentation.qml', 'formatPrice');
function makeFormatPrice(configuration) {
  return new Function('Plasmoid', `return ${formatPriceCode};`)({ configuration });
}

const parseUserCoins = new Function(
  `return ${extractFunction('GeneralConfig.qml', 'parseUserCoins')};`
)();

// ---------------------------------------------------------------- formatPrice

const cfg = (decimalPlaces, thousands, swap) => ({
  decimalPlaces,
  useThousandsSeparator: thousands,
  swapCommasDots: swap,
});

test('formatPrice: expected results', () => {
  const cases = [
    // [price, decimalPlaces, thousands, swap, expected]
    [1234.5678, 4, true, false, '1,234.5678'],
    [1234.5678, 4, true, true, '1.234,5678'],
    [123456789.123, 0, true, false, '123,456,789'],
    [123456789.123, 2, true, false, '123,456,789.12'],
    [123456789.123, 3, true, true, '123.456.789,123'],
    [123456789.123, 4, true, false, '123,456,789.1230'],
    [1234.5678, 2, false, false, '1234.57'],
    [1234.5678, 2, false, true, '1234,57'],
    [0.00001234, 8, true, false, '0.00001234'],
    [999, 0, true, false, '999'],
    [1000, 0, true, false, '1,000'],
    [67890.4, 0, true, true, '67.890'],
  ];
  for (const [price, decimals, thousands, swap, expected] of cases) {
    const got = makeFormatPrice(cfg(decimals, thousands, swap))(price);
    assert.equal(got, expected, `price=${price} decimals=${decimals} thousands=${thousands} swap=${swap}`);
  }
});

test('formatPrice: a value that is not a number is returned as it is', () => {
  const format = makeFormatPrice(cfg(2, true, false));
  assert.equal(format('abc'), 'abc');
  assert.equal(format(undefined), undefined);
});

test('formatPrice: separators never appear in the decimal places (4 or more places)', () => {
  // Regression: 1,234.5,678 when the separator was applied to the whole text.
  const prices = [0, 0.5, 7, 999, 1234, 12345.6789, 67890.12345678, 1234567.891, 0.00001234];
  for (const swap of [false, true]) {
    for (let decimals = 4; decimals <= 10; decimals++) {
      const format = makeFormatPrice(cfg(decimals, true, swap));
      for (const price of prices) {
        const decimalPart = format(price).split(swap ? ',' : '.').pop();
        assert.match(decimalPart, /^\d+$/, `price=${price} decimals=${decimals} swap=${swap}`);
      }
    }
  }
});

test('formatPrice: the digits are never changed, only the separators are added', () => {
  const prices = [0, 0.5, 7, 999, 1234, 12345.6789, 67890.12345678, 1234567.891, 123456789.123];
  for (const swap of [false, true]) {
    for (const thousands of [false, true]) {
      for (let decimals = 0; decimals <= 10; decimals++) {
        const format = makeFormatPrice(cfg(decimals, thousands, swap));
        for (const price of prices) {
          assert.equal(
            format(price).replace(/[.,]/g, ''),
            price.toFixed(decimals).replace('.', ''),
            `price=${price} decimals=${decimals} thousands=${thousands} swap=${swap}`
          );
        }
      }
    }
  }
});

// -------------------------------------------------------------- parseUserCoins

const known = ['BTC', 'ETH', 'SOL'];
const parse = (text, max = 500) => parseUserCoins(text, known, max);

test('parseUserCoins: coins are returned in the order of the file', () => {
  assert.deepEqual(parse('ListElement { name: "XRP2" }\nListElement { name: "PEPE" }\n'), ['XRP2', 'PEPE']);
});

test('parseUserCoins: a complete file in the format of CoinModel.qml', () => {
  const file = 'import QtQuick\n\nListModel {\n    ListElement { name: "DOGE" }\n    ListElement { name: "SHIB" }\n}\n';
  assert.deepEqual(parse(file), ['DOGE', 'SHIB']);
});

test('parseUserCoins: names are converted to uppercase', () => {
  assert.deepEqual(parse('ListElement { name: "doge" }'), ['DOGE']);
});

test('parseUserCoins: coins that are already known or repeated are ignored', () => {
  assert.deepEqual(parse('ListElement { name: "BTC" }\nListElement { name: "sol" }\nListElement { name: "NEW" }'), ['NEW']);
  assert.deepEqual(parse('ListElement { name: "NEW" }\nListElement { name: "new" }'), ['NEW']);
});

test('parseUserCoins: comments are ignored', () => {
  assert.deepEqual(parse('// ListElement { name: "OFF" }\nListElement { name: "ON" } // ListElement { name: "OFF2" }'), ['ON']);
  assert.deepEqual(parse('/* ListElement { name: "OFF" }\nListElement { name: "OFF2" } */\nListElement { name: "ON" }'), ['ON']);
});

test('parseUserCoins: spaces, tabs and Windows line endings', () => {
  assert.deepEqual(parse('ListElement{name:"A1"}\n\tListElement   {   name   :   " b2 "   }'), ['A1', 'B2']);
  assert.deepEqual(parse('ListElement { name: "AAA" }\r\nListElement { name: "BBB" }\r\n'), ['AAA', 'BBB']);
});

test('parseUserCoins: invalid names are ignored', () => {
  const file = [
    'ListElement { name: "A-B" }',
    'ListElement { name: "A B" }',
    'ListElement { name: "" }',
    `ListElement { name: "${'X'.repeat(21)}" }`,
    'ListElement { name: "OK" }',
  ].join('\n');
  assert.deepEqual(parse(file), ['OK']);
});

test('parseUserCoins: names that could change the API URL are rejected', () => {
  assert.deepEqual(parse('ListElement { name: "BTC&x=1" }\nListElement { name: "../a" }\nListElement { name: "A?B" }'), []);
});

test('parseUserCoins: only the format ListElement { name: "..." } is accepted', () => {
  assert.deepEqual(parse('ListElement { name: "AAA"; abbreviation: "X" }'), []);
  assert.deepEqual(parse('qualquer coisa\n{{{ }}}\nListElement { name: "OK1" }\nListElement { nome: "X" }'), ['OK1']);
});

test('parseUserCoins: empty or missing text, and the limit of coins', () => {
  assert.deepEqual(parse(''), []);
  assert.deepEqual(parse(undefined), []);
  const many = Array.from({ length: 10 }, (_, i) => `ListElement { name: "C${i}" }`).join('\n');
  assert.deepEqual(parse(many, 3), ['C0', 'C1', 'C2']);
});
