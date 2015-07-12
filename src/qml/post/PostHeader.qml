/*
 * Copyright (C) 2013 Lucien XU <sfietkonstantin@free.fr>
 *
 * You may use this file under the terms of the BSD license as follows:
 *
 * "Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *   * The names of its contributors may not be used to endorse or promote
 *     products derived from this software without specific prior written
 *     permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import ".."

Item {
    id: container
    property QtObject helper
    anchors.left: parent.left; anchors.right: parent.right
    height: childrenRect.height
    FacebookImage {
        id: picture
        visible: container.helper.fullHeader
        width: container.helper.fullHeader ? Theme.iconSizeMedium : 0
        height: container.helper.fullHeader ? Theme.iconSizeMedium : 0
        url: container.helper.profilePicture
    }

    Column {
        anchors.left: picture.right
        anchors.leftMargin: container.helper.fullHeader ? Theme.paddingMedium : 0
        anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
        spacing: Theme.paddingSmall

        Label {
            id: header
            anchors.left: parent.left; anchors.right: parent.right
            textFormat: Text.RichText
            text: container.helper.header
            font.pixelSize: Theme.fontSizeSmall
            wrapMode: Text.WordWrap
            // onLinkActivated:
        }

        Label {
            anchors.left: parent.left; anchors.right: parent.right
            visible: container.helper.fullHeader
            text: Format.formatDate(container.helper.timestamp, Formatter.DurationElapsed)
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.secondaryHighlightColor
        }
    }
}
