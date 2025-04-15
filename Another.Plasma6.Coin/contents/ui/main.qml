/*
SPDX-FileCopyrightText: zayronxio
SPDX-License-Identifier: GPL-3.0-or-later
*/
import QtQuick 2.12
import org.kde.plasma.plasmoid

PlasmoidItem {
    width: wrapper.width

    preferredRepresentation: fullRepresentation

    fullRepresentation: CompactRepresentation {
        heightroot: root.height
    }
}
