import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.DCommon.Widgets

Rectangle {
    id: root

    property var appData: null
    signal clicked()

    readonly property string appName: appData?.name || ""
    readonly property int appIconSize: Math.min(width - Theme.spacingL * 2, Theme.iconSizeLarge * 2)

    radius: Theme.cornerRadiusL
    color: mouseArea.pressed ? Theme.withAlpha(Theme.primary, Theme.stateLayerPressed) : mouseArea.containsMouse ? Theme.withAlpha(Theme.primary, Theme.stateLayerHover) : "transparent"
    Accessible.role: Accessible.Button
    Accessible.name: appName
    Accessible.onPressAction: root.clicked()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingM
        spacing: Theme.spacingS

        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: root.appIconSize
            Layout.preferredHeight: root.appIconSize

            Rectangle {
                anchors.fill: parent
                radius: Theme.cornerRadius
                color: Theme.primaryContainer

                StyledText {
                    anchors.centerIn: parent
                    text: root.appName ? root.appName.charAt(0).toUpperCase() : "?"
                    color: Theme.onPrimaryContainer
                    font.pixelSize: parent.width * 0.4
                    font.weight: Font.Medium
                }
            }

            AppIconRenderer {
                anchors.fill: parent
                iconValue: root.appData?.icon || ""
                iconSize: root.appIconSize
                fallbackText: root.appName.charAt(0).toUpperCase() || "?"
                fallbackBackgroundColor: Theme.primaryContainer
                fallbackTextColor: Theme.onPrimaryContainer
                iconColor: Theme.onSurface
            }
        }

        StyledText {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.fontSizeSmall * 2
            text: root.appName
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Theme.fontWeightMedium
            color: Theme.onSurface
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onClicked: root.clicked()
    }
}
