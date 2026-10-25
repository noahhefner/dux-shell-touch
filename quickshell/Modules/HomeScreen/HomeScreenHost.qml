import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.DCommon.Widgets
import qs.Services

Item {
    id: host

    property bool homeVisible: true

    function launchApp(app) {
        if (!app)
            return;

        const appId = app.id || app.execString || app.exec || "";
        const entry = (appId && DesktopEntries.heuristicLookup(appId)) || app;
        if (!entry.command || entry.command.length === 0) {
            ToastService.showError(I18n.tr("Failed to launch application"), I18n.tr("No launch command is available for %1", "home screen app launch error").arg(app.name || appId));
            return;
        }

        try {
            SessionService.launchDesktopEntry(entry);
            homeVisible = false;
        } catch (error) {
            ToastService.showError(I18n.tr("Failed to launch application"), String(error));
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: homeWindow
            required property var modelData
            screen: modelData
            visible: true
            color: "transparent"

            WlrLayershell.namespace: "dms:home-screen"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.exclusiveZone: -1
            WlrLayershell.keyboardFocus: host.homeVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            mask: Region {
                item: host.homeVisible ? homeSurface : homeIndicator
            }

            Item {
                id: homeSurface
                anchors.fill: parent
                visible: host.homeVisible

                Rectangle {
                    anchors.fill: parent
                    color: Theme.surface
                }

                HomeScreen {
                    anchors.fill: parent
                    onAppClicked: app => host.launchApp(app)
                    onRequestDismiss: host.homeVisible = false
                }
            }

            DIconButton {
                id: homeIndicator
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.spacingM
                width: Math.max(48, implicitWidth)
                height: Math.max(48, implicitHeight)
                visible: !host.homeVisible
                size: "m"
                iconName: "home"
                iconColor: Theme.surfaceVariantText
                backgroundColor: Theme.surfaceVariant
                tooltipText: I18n.tr("Home", "return to home screen")
                onClicked: host.homeVisible = true
            }
        }
    }
}
