import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#161616"

    property color cBg:     "#161616"
    property color cBg1:    "#1e1e1e"
    property color cBg2:    "#262626"
    property color cFg:     "#d4d4d4"
    property color cMuted:  "#6a6a6a"
    property color cAccent: "#8fa1b3"

    TextConstants { id: textConstants }

    Connections {
        target: sddm
        function onLoginSucceeded() { }
        function onLoginFailed() {
            errorMsg.text = "login failed — try again"
            password.text = ""
        }
    }

    // gradient backdrop
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#1a1a1a" }
            GradientStop { position: 1.0; color: "#0e0e0e" }
        }
    }

    // clock
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 130
        spacing: 6

        Text {
            id: clockText
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cFg
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 92
            font.bold: true
            Timer {
                interval: 1000; running: true; repeat: true
                onTriggered: clockText.text = Qt.formatDateTime(new Date(), "HH:mm")
            }
            Component.onCompleted: clockText.text = Qt.formatDateTime(new Date(), "HH:mm")
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cMuted
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 22
            text: Qt.formatDateTime(new Date(), "dddd, dd MMMM")
        }
    }

    // login card
    Rectangle {
        anchors.centerIn: parent
        width: 440
        height: 300
        radius: 22
        color: root.cBg1
        border.color: root.cAccent
        border.width: 2

        Column {
            anchors.centerIn: parent
            width: parent.width - 64
            spacing: 16

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: root.cFg
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 20
                font.bold: true
                text: "welcome back"
            }

            // username field (plain TextInput in a styled box)
            Rectangle {
                width: parent.width
                height: 46
                radius: 10
                color: root.cBg2
                border.color: root.cAccent
                border.width: 1

                TextInput {
                    id: username
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    verticalAlignment: TextInput.AlignVCenter
                    color: root.cFg
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 15
                    text: userModel.lastUser
                    clip: true
                    KeyNavigation.tab: password
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        color: root.cMuted
                        font: username.font
                        text: "username"
                        visible: username.text.length === 0
                    }
                }
            }

            // password field
            Rectangle {
                width: parent.width
                height: 46
                radius: 10
                color: root.cBg
                border.color: password.activeFocus ? root.cAccent : root.cBg2
                border.width: 1

                TextInput {
                    id: password
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    verticalAlignment: TextInput.AlignVCenter
                    color: root.cFg
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 15
                    echoMode: TextInput.Password
                    focus: true
                    clip: true
                    onAccepted: sddm.login(username.text, password.text, sessionModel.lastIndex)
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        color: root.cMuted
                        font: password.font
                        text: "password"
                        visible: password.text.length === 0
                    }
                }
            }

            // login button
            Rectangle {
                width: parent.width
                height: 46
                radius: 10
                color: loginArea.pressed ? Qt.darker(root.cAccent, 1.2) : root.cAccent

                Text {
                    anchors.centerIn: parent
                    color: root.cBg
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 15
                    font.bold: true
                    text: "login"
                }
                MouseArea {
                    id: loginArea
                    anchors.fill: parent
                    onClicked: sddm.login(username.text, password.text, sessionModel.lastIndex)
                }
            }
        }
    }

    Text {
        id: errorMsg
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.verticalCenter
        anchors.topMargin: 180
        color: "#bf8b8b"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 14
        text: ""
    }

    Component.onCompleted: password.forceActiveFocus()
}
