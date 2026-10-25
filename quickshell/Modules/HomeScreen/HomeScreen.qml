import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.DCommon.Widgets
import qs.Services
import "Components"

Item {
    id: root

    signal appClicked(var app)
    signal requestDismiss()

    readonly property var apps: {
        AppSearchService.cacheVersion;
        return AppSearchService.getVisibleApplications() || [];
    }
    readonly property real minimumCellWidth: Theme.iconSizeLarge * 2.5 + Theme.spacingXL
    readonly property int columnCount: Math.max(1, Math.floor(grid.width / minimumCellWidth))

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingL
        spacing: Theme.spacingL

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingM

            StyledText {
                Layout.fillWidth: true
                text: I18n.tr("Home", "home screen title")
                font.pixelSize: Theme.fontSizeXLarge
                font.weight: Font.Bold
                color: Theme.surfaceText
            }

            DIconButton {
                Layout.preferredWidth: Math.max(48, implicitWidth)
                Layout.preferredHeight: Math.max(48, implicitHeight)
                size: "m"
                iconName: "close"
                tooltipText: I18n.tr("Close Home", "close home screen")
                onClicked: root.requestDismiss()
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            DGridView {
                id: grid
                anchors.fill: parent
                clip: true
                model: root.apps
                cellWidth: width / root.columnCount
                cellHeight: Math.max(Theme.iconSizeLarge * 3 + Theme.spacingXL, cellWidth * 0.85)
                interactive: contentHeight > height
                showScrollBar: false
                fadeEdges: false

                delegate: AppTile {
                    width: grid.cellWidth - Theme.spacingM
                    height: grid.cellHeight - Theme.spacingM
                    appData: modelData
                    onClicked: root.appClicked(modelData)
                }
            }

            StyledText {
                anchors.centerIn: parent
                width: parent.width - Theme.spacingXL * 2
                visible: root.apps.length === 0
                text: I18n.tr("No apps found", "home screen empty state")
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.surfaceVariantText
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
        }
    }
}
