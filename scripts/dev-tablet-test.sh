#!/usr/bin/env bash

set -Eeuo pipefail

script_path="$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/$(basename -- "${BASH_SOURCE[0]}")"
repo_root="$(CDPATH='' cd -- "$(dirname -- "$script_path")/.." && pwd -P)"

log_error() {
    printf 'test-tablet: %s\n' "$*" >&2
}

quote_sh() {
    local value=${1//\'/\'\\\'\'}
    printf "'%s'" "$value"
}

write_status() {
    local status_file=$1
    local status=$2
    local temporary_file="${status_file}.tmp.$$"
    printf '%s\n' "$status" >"$temporary_file"
    mv -f -- "$temporary_file" "$status_file"
}

session_child() {
    local expected_runtime=${DMS_TABLET_TEST_RUNTIME_DIR:-}
    local project_root=${DMS_TABLET_TEST_REPO_ROOT:-}
    local pid_file=${DMS_TABLET_TEST_CHILD_PID_FILE:-}
    local status_file=${DMS_TABLET_TEST_CHILD_STATUS_FILE:-}
    local log_file=${DMS_TABLET_TEST_CHILD_LOG:-}
    local display_socket
    local child_status

    if [[ -z "$expected_runtime" || -z "$project_root" || -z "$pid_file" || -z "$status_file" || -z "$log_file" ]]; then
        log_error "internal session configuration is incomplete"
        return 2
    fi
    : >>"$log_file"
    exec 2>>"$log_file"

    if [[ "${XDG_RUNTIME_DIR:-}" != "$expected_runtime" || -z "${WAYLAND_DISPLAY:-}" ]]; then
        log_error "nested Sway did not provide its runtime directory and Wayland display"
        write_status "$status_file" 1
        return 1
    fi

    if [[ "$WAYLAND_DISPLAY" = /* ]]; then
        display_socket=$WAYLAND_DISPLAY
    else
        display_socket="$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
    fi

    case "$display_socket" in
    "$expected_runtime"/*) ;;
    *)
        log_error "refusing to launch DMS outside the nested Wayland display"
        write_status "$status_file" 1
        return 1
        ;;
    esac

    if [[ ! -S "$display_socket" || -z "${SWAYSOCK:-}" || ! -S "$SWAYSOCK" ]]; then
        log_error "nested Wayland or Sway IPC socket is unavailable"
        write_status "$status_file" 1
        return 1
    fi
    case "$SWAYSOCK" in
    "$expected_runtime"/*) ;;
    *)
        log_error "refusing to use a Sway IPC socket outside the nested session"
        write_status "$status_file" 1
        return 1
        ;;
    esac

    unset DMS_TABLET_TEST_CHILD
    if setsid --wait bash -c '
        pid_file=$1
        status_file=$2
        log_file=$3
        project_root=$4
        printf "%s\n" "$$" >"$pid_file"
        make -C "$project_root" run >"$log_file" 2>&1
        status=$?
        status_tmp="${status_file}.tmp.$$"
        printf "%s\n" "$status" >"$status_tmp"
        mv -f -- "$status_tmp" "$status_file"
        exit "$status"
    ' dms-tablet-session "$pid_file" "$status_file" "$log_file" "$project_root"; then
        child_status=0
    else
        child_status=$?
    fi

    if [[ ! -s "$status_file" ]]; then
        write_status "$status_file" "$child_status"
    fi
    child_status=$(<"$status_file")

    if [[ "$child_status" != 0 ]]; then
        log_error "DMS exited with status $child_status"
        [[ ! -f "$log_file" ]] || cat -- "$log_file" >&2
    fi
    return "$child_status"
}

if [[ "${1:-}" == "--session-child" ]]; then
    if [[ "${DMS_TABLET_TEST_CHILD:-}" != 1 ]]; then
        log_error "--session-child is reserved for the nested session"
        exit 2
    fi
    session_child
    exit $?
fi

if (($# > 0)); then
    log_error "usage: $0"
    exit 2
fi

orientation=${TABLET_TEST_ORIENTATION:-landscape}
case "$orientation" in
landscape) initial_transform=normal ;;
portrait) initial_transform=90 ;;
*)
    log_error "invalid TABLET_TEST_ORIENTATION '$orientation' (expected landscape or portrait)"
    exit 2
    ;;
esac

host_runtime_dir=${XDG_RUNTIME_DIR:-}
host_wayland_display=${WAYLAND_DISPLAY:-}
host_data_home=${XDG_DATA_HOME:-"${HOME:-}/.local/share"}
host_data_dirs=${XDG_DATA_DIRS:-/usr/local/share:/usr/share}
host_config_dirs=${XDG_CONFIG_DIRS:-/etc/xdg}

if [[ -z "$host_runtime_dir" || ! -d "$host_runtime_dir" ]]; then
    log_error "XDG_RUNTIME_DIR is unavailable; start this from a Wayland desktop session"
    exit 1
fi
if [[ -z "$host_wayland_display" ]]; then
    log_error "WAYLAND_DISPLAY is not set; start this from a Wayland desktop session"
    exit 1
fi

if [[ "$host_wayland_display" = /* ]]; then
    host_wayland_socket=$host_wayland_display
else
    host_wayland_socket="$host_runtime_dir/$host_wayland_display"
fi
if [[ ! -S "$host_wayland_socket" ]]; then
    log_error "host Wayland socket is unavailable: $host_wayland_socket"
    exit 1
fi

for required_command in make go sway swaymsg setsid mktemp tail; do
    if ! command -v "$required_command" >/dev/null 2>&1; then
        case "$required_command" in
        sway|swaymsg) log_error "required command '$required_command' is missing; enter nix develop or install Sway with its Wayland backend" ;;
        *) log_error "required command '$required_command' is missing; enter the project development environment" ;;
        esac
        exit 1
    fi
done
if [[ ! -f "$repo_root/quickshell/shell.qml" ]]; then
    log_error "could not find quickshell/shell.qml under $repo_root"
    exit 1
fi

run_root=""
sway_pid=""
sway_socket=""
child_pid_file=""
log_tail_pid=""
cleanup_started=0

stop_process_group() {
    local process_group=$1
    local leader_pid=${2:-}
    local attempt

    [[ "$process_group" =~ ^[0-9]+$ ]] || return 0
    kill -TERM -- "-$process_group" 2>/dev/null || true
    for ((attempt = 0; attempt < 20; attempt++)); do
        kill -0 -- "-$process_group" 2>/dev/null || break
        sleep 0.1
    done
    kill -KILL -- "-$process_group" 2>/dev/null || true
    [[ ! "$leader_pid" =~ ^[0-9]+$ ]] || wait "$leader_pid" 2>/dev/null || true
}

cleanup() {
    local exit_status=$?
    local child_process_group=""

    ((cleanup_started)) && return
    cleanup_started=1
    trap - EXIT INT TERM HUP

    if [[ -n "$run_root" ]]; then
        if [[ "$log_tail_pid" =~ ^[0-9]+$ ]]; then
            kill -TERM "$log_tail_pid" 2>/dev/null || true
            wait "$log_tail_pid" 2>/dev/null || true
        fi
        if [[ -n "$sway_socket" && -S "$sway_socket" ]]; then
            swaymsg -s "$sway_socket" exit >/dev/null 2>&1 || true
        fi
        if [[ -n "$child_pid_file" && -f "$child_pid_file" ]]; then
            child_process_group=$(<"$child_pid_file")
            stop_process_group "$child_process_group"
        fi
        if [[ -n "$sway_pid" ]]; then
            stop_process_group "$sway_pid" "$sway_pid"
        fi
        case "$run_root" in
        "$host_runtime_dir"/dms-tablet-test.*) rm -rf -- "$run_root" ;;
        *) log_error "refusing to remove unexpected temporary path: $run_root" ;;
        esac
    fi
    exit "$exit_status"
}

trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'exit 129' HUP

umask 077
run_root=$(mktemp -d "$host_runtime_dir/dms-tablet-test.XXXXXXXX") || {
    log_error "could not create a temporary test directory under $host_runtime_dir"
    exit 1
}
chmod 700 "$run_root"

runtime_dir="$run_root/runtime"
mkdir -m 700 -p "$runtime_dir" "$run_root/config" "$run_root/state" "$run_root/cache" "$run_root/data"
sway_config="$run_root/sway.conf"
sway_log="$run_root/sway.log"
dms_log="$run_root/dms.log"
dms_pid_file="$run_root/dms.pid"
dms_status_file="$run_root/dms.status"
child_pid_file=$dms_pid_file

cat >"$sway_config" <<EOF
output * mode 800x600
output * transform $initial_transform
xwayland enable
bindsym F8 output * transform normal
bindsym F9 output * transform 90
bindsym F10 exit
EOF

export XDG_RUNTIME_DIR="$runtime_dir"
export XDG_CONFIG_HOME="$run_root/config"
export XDG_STATE_HOME="$run_root/state"
export XDG_CACHE_HOME="$run_root/cache"
export XDG_DATA_HOME="$run_root/data"
export XDG_DATA_DIRS="$host_data_home:$host_data_dirs"
export XDG_CONFIG_DIRS="$host_config_dirs"
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=sway
export XDG_CURRENT_DESKTOP=sway
export DMS_TABLET_TEST_ROOT="$run_root"
export DMS_TABLET_TEST_RUNTIME_DIR="$runtime_dir"
export DMS_TABLET_TEST_REPO_ROOT="$repo_root"
export DMS_TABLET_TEST_SCRIPT="$script_path"
export DMS_TABLET_TEST_CHILD_PID_FILE="$dms_pid_file"
export DMS_TABLET_TEST_CHILD_STATUS_FILE="$dms_status_file"
export DMS_TABLET_TEST_CHILD_LOG="$dms_log"

unset DMS_SOCKET SWAYSOCK I3SOCK HYPRLAND_INSTANCE_SIGNATURE NIRI_SOCKET \
    MANGO_INSTANCE_SIGNATURE MIRACLESOCK LABWC_PID

setsid env WAYLAND_DISPLAY="$host_wayland_socket" WLR_BACKENDS=wayland \
    sway --config "$sway_config" >"$sway_log" 2>&1 &
sway_pid=$!

wayland_socket=""
sway_socket=""
for ((attempt = 0; attempt < 100; attempt++)); do
    kill -0 "$sway_pid" 2>/dev/null || break
    for candidate in "$runtime_dir"/wayland-*; do
        [[ ! -S "$candidate" ]] || wayland_socket=$candidate
    done
    for candidate in "$runtime_dir"/sway-ipc."$(id -u)".*.sock; do
        [[ ! -S "$candidate" ]] || sway_socket=$candidate
    done
    [[ -z "$wayland_socket" || -z "$sway_socket" ]] || break
    sleep 0.1
done

if [[ -z "$wayland_socket" || -z "$sway_socket" ]]; then
    log_error "nested Sway did not create its Wayland and IPC sockets"
    [[ ! -f "$sway_log" ]] || cat -- "$sway_log" >&2
    exit 1
fi
if ! swaymsg -s "$sway_socket" -t get_outputs >/dev/null 2>&1; then
    log_error "nested Sway started but its IPC socket is not responding"
    [[ ! -f "$sway_log" ]] || cat -- "$sway_log" >&2
    exit 1
fi

session_command="env DMS_TABLET_TEST_CHILD=1 XDG_RUNTIME_DIR=$(quote_sh "$runtime_dir") WAYLAND_DISPLAY=$(quote_sh "$(basename -- "$wayland_socket")") SWAYSOCK=$(quote_sh "$sway_socket") I3SOCK=$(quote_sh "$sway_socket") $(quote_sh "$script_path") --session-child"
if ! swaymsg -s "$sway_socket" exec "$session_command" >/dev/null 2>&1; then
    log_error "could not start DMS inside nested Sway"
    exit 1
fi

child_started=0
for ((attempt = 0; attempt < 100; attempt++)); do
    if [[ -s "$dms_pid_file" || -s "$dms_status_file" ]]; then
        child_started=1
        break
    fi
    kill -0 "$sway_pid" 2>/dev/null || break
    sleep 0.1
done
if ((child_started == 0)); then
    log_error "DMS did not start inside nested Sway; inspect $sway_log"
    [[ ! -f "$sway_log" ]] || cat -- "$sway_log" >&2
    exit 1
fi

tail -n +1 -F "$dms_log" &
log_tail_pid=$!
printf 'test-tablet: running %s profile in nested Sway; F8 landscape, F9 portrait, F10 exit\n' "$orientation"
session_status=0
while kill -0 "$sway_pid" 2>/dev/null; do
    if [[ -s "$dms_status_file" ]]; then
        session_status=$(<"$dms_status_file")
        break
    fi
    sleep 0.2
done
if [[ -s "$dms_status_file" ]]; then
    session_status=$(<"$dms_status_file")
fi
if [[ "$session_status" != 0 ]]; then
    log_error "nested DMS session exited with status $session_status"
fi
exit "$session_status"
