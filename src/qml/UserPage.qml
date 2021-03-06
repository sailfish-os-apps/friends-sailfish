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
import harbour.friends.social 1.0
import harbour.friends.social.extra 1.0
import "UiConstants.js" as Ui

Page {
    id: container
    property string identifier
    function load() {
        if (user.status == SocialNetwork.Idle || user.status == SocialNetwork.Error) {
            user.load()
        }
        if (model.status == SocialNetwork.Idle || model.status == SocialNetwork.Error) {
            model.load()
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Active) {
            pageStack.pushAttached(menuPage)
        }
    }

    StateIndicator {
        model: model
        item: user
    }

    FacebookUser {
        id: user
        socialNetwork: facebook
        filter: FacebookItemFilter {
            identifier: container.identifier
            fields: "name,first_name,cover"
        }
    }

    SilicaListView {
        id: view
        anchors.fill: parent
        visible: (model.status == SocialNetwork.Idle) || model.count > 0
        header: Item {
            width: view.width
            height: childrenRect.height
            Item {
                anchors.left: parent.left; anchors.right: parent.right
                height: 2 * Theme.itemSizeExtraLarge + Theme.itemSizeSmall + 0.5 * Theme.paddingSmall

                CoverImage {
                    id: coverImage
                    anchors.left: parent.left; anchors.right: parent.right
                    height: 2 * Theme.itemSizeExtraLarge
                    coverUrl: user.cover.source

                    Label {
                        id: nameText
                        anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.paddingMedium + Theme.itemSizeSmall * 2
                        anchors.bottom: parent.bottom; anchors.bottomMargin: Theme.paddingMedium
                        opacity: 0
                        wrapMode: Text.WordWrap
                        font.pixelSize: Theme.fontSizeLarge
                        states: [
                            State {
                                name: "visible"; when: user.name != ""
                                PropertyChanges {
                                    target: nameText
                                    opacity: 1
                                    text: user.name
                                }
                            }
                        ]
                        Behavior on opacity {
                            NumberAnimation {duration: Ui.ANIMATION_DURATION_NORMAL}
                        }
                    }
                }

                Rectangle {
                    id: pictureContainer
                    opacity: 0
                    anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
                    anchors.verticalCenter: coverImage.bottom
                    color: Theme.primaryColor
                    width: Theme.itemSizeSmall * 2 + Theme.paddingSmall
                    height: Theme.itemSizeSmall * 2 + Theme.paddingSmall

                    states: [
                        State {
                            name: "visible"; when: picture.status == Image.Ready
                            PropertyChanges {
                                target: pictureContainer
                                opacity: 1
                            }
                        }
                    ]
                    Behavior on opacity {
                        NumberAnimation {duration: Ui.ANIMATION_DURATION_NORMAL}
                    }

                    FacebookPicture {
                        id: picture
                        identifier: container.identifier
                        anchors.centerIn: parent
                        pictureWidth: Theme.itemSizeSmall * 2
                        pictureHeight: Theme.itemSizeSmall * 2
                    }
                }
            }
        }

        model: SocialNetworkModel {
            id: model
            socialNetwork: facebook
            filter: NewsFeedFilter {
                type: NewsFeedFilter.Feed
                identifier: container.identifier
            }
        }

        delegate: PostDelegate {
            post: model.contentItem
            to: model.contentItem.to.length > 0 ? model.contentItem.to[0] : null
            fancy: false
        }

        onAtYEndChanged: {
            if (atYEnd && model.hasNext) {
                if (model.status == SocialNetwork.Idle || model.status == SocialNetwork.Error) {
                    model.loadNext()
                }
            }
        }

        VerticalScrollDecorator {}

        ViewPlaceholder {
            enabled: model.status == SocialNetwork.Idle && model.count == 0
            //: Text shown on the placeholder, where there is no posts from an user, a group or a page to be displayed
            //% "No posts"
            text: qsTrId("friends_no_posts")
        }

        PullDownMenu {
            z: 1000
            busy: model.status == SocialNetwork.Busy

            MenuItem {
                //: Action that shows the user's photos
                //% "Photos"
                text: qsTrId("friends_user_action_photos")
                onClicked: {
                    var page = pageStack.push(Qt.resolvedUrl("PhotosPage.qml"),
                                              {"identifier": user.identifier,
                                               "name": qsTrId("friends_photos_of_someone").arg(user.firstName),
                                               "isUserPhotos": true})
                    page.load()
                }
            }

            MenuItem {
                //: Action that shows the user's albums
                //% "Albums"
                text: qsTrId("friends_user_action_albums")
                onClicked: {
                    var page = pageStack.push(Qt.resolvedUrl("AlbumsPage.qml"),
                                              {"identifier": user.identifier})
                    page.load()
                }
            }

            MenuItem {
                //: Action that shows the current user's personnal informations
                //% "Personal information"
                text: user.identifier == me.identifier ? qsTrId("friends_user_action_about_me")
                 //: Action that shows the personnal informations of a given user. %1 contains the name of the user.
                 //% "About %1"
                                                       : qsTrId("friends_user_action_about").arg(user.firstName)
                onClicked: {
                    var page = pageStack.push(Qt.resolvedUrl("UserInfoPage.qml"),
                                              {"identifier": user.identifier})
                    page.load()
                }
            }

            MenuItem {
                text: qsTrId("friends_action_refresh")
                onClicked: model.loadPrevious()
            }
        }
    }
}
