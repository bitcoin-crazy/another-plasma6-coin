/*
 * SPDX-FileCopyrightText: Copyright 2025 zayronxio
 * SPDX-FileCopyrightText: Copyright 2025 bitcoin-crazy
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-SnippetComment: Another Plasma6 Coin was initially based on Plasma Coin 1.0.2, from zayronxio.
 */

import QtQuick 2.12
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    Component.onCompleted: {
        if (parent) {
            anchors.left = parent.left
            anchors.leftMargin = 20 // Left margin adjustment
            anchors.right = parent.right
            anchors.rightMargin = 20 // Right margin adjustment
        }
    }

    preferredRepresentation: fullRepresentation

    fullRepresentation: CompactRepresentation {
        id: compactRepresentation
        width: root.width
        height: root.height
    }
}
