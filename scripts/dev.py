#!/usr/bin/env python3
"""Run the Flutter app in debug mode and hot reload when Dart files are saved."""

import os
import pty
import select
import signal
import struct
import subprocess
import sys
import termios
import threading
import tty

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
APP = os.path.join(ROOT, "flutter_app")
LIB = os.path.join(APP, "lib")
RUN = os.path.join(APP, ".run")
PIPE = os.path.join(RUN, "input")


def device_from_adb():
    result = subprocess.run(["adb", "devices"], check=False, capture_output=True, text=True)
    for line in result.stdout.splitlines()[1:]:
        parts = line.split()
        if len(parts) >= 2 and parts[1] == "device":
            return parts[0]
    return ""


def copy_winsize(src, dst):
    if not os.isatty(src):
        return
    packed = struct.pack("HHHH", 0, 0, 0, 0)
    import fcntl

    size = fcntl.ioctl(src, termios.TIOCGWINSZ, packed)
    fcntl.ioctl(dst, termios.TIOCSWINSZ, size)


def main():
    device = sys.argv[1] if len(sys.argv) > 1 and sys.argv[1] else device_from_adb()
    if not device:
        print("没有连接安卓设备。插上手机并允许 USB 调试后再运行。", file=sys.stderr)
        return 1

    os.makedirs(RUN, exist_ok=True)
    if os.path.exists(PIPE):
        os.remove(PIPE)
    os.mkfifo(PIPE)

    master, slave = pty.openpty()
    copy_winsize(sys.stdin.fileno(), slave)
    env = os.environ.copy()
    env.setdefault("TERM", "xterm-256color")
    process = subprocess.Popen(
        ["flutter", "run", "-d", device, "--debug"],
        stdin=slave,
        stdout=slave,
        stderr=slave,
        cwd=APP,
        env=env,
        start_new_session=True,
    )
    os.close(slave)
    ready = threading.Event()
    stopped = threading.Event()

    def send(data):
        if stopped.is_set():
            return
        try:
            os.write(master, data)
        except OSError:
            stopped.set()

    def watch_pipe():
        while not stopped.is_set():
            try:
                with open(PIPE, "r", encoding="utf-8") as handle:
                    for line in handle:
                        command = line.strip()
                        if command:
                            send(command.encode())
            except OSError:
                return

    def watch_files():
        watcher = subprocess.Popen(
            ["inotifywait", "-m", "-r", "-e", "close_write,moved_to", "--format", "%f", LIB],
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
        )
        try:
            while not stopped.is_set():
                line = watcher.stdout.readline() if watcher.stdout is not None else ""
                if not line:
                    return
                if not line.strip().endswith(".dart") or not ready.wait(timeout=0.1):
                    continue
                if stopped.wait(0.4):
                    return
                if ready.is_set():
                    send(b"r")
        finally:
            watcher.terminate()

    threads = [
        threading.Thread(target=watch_pipe, daemon=True),
        threading.Thread(target=watch_files, daemon=True),
    ]
    for thread in threads:
        thread.start()

    old = termios.tcgetattr(sys.stdin) if os.isatty(sys.stdin.fileno()) else None
    if old is not None:
        tty.setraw(sys.stdin.fileno())

    def stop(*_):
        stopped.set()
        try:
            os.killpg(process.pid, signal.SIGTERM)
        except OSError:
            process.terminate()

    signal.signal(signal.SIGINT, stop)
    signal.signal(signal.SIGTERM, stop)

    try:
        watch_stdin = os.isatty(sys.stdin.fileno())
        while not stopped.is_set() and process.poll() is None:
            sources = [master, sys.stdin] if watch_stdin else [master]
            readable, _, _ = select.select(sources, [], [], 0.3)
            if master in readable:
                try:
                    data = os.read(master, 4096)
                except OSError:
                    break
                if not data:
                    break
                os.write(sys.stdout.fileno(), data)
                sys.stdout.flush()
                if b"Hot reload" in data or b"Flutter run key commands" in data:
                    ready.set()
            if sys.stdin in readable:
                key = os.read(sys.stdin.fileno(), 32)
                if not key:
                    break
                send(key)
    finally:
        stopped.set()
        if old is not None:
            termios.tcsetattr(sys.stdin, termios.TCSADRAIN, old)
        if process.poll() is None:
            stop()
            try:
                process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                process.kill()
        try:
            os.close(master)
        except OSError:
            pass
        if os.path.exists(PIPE):
            os.remove(PIPE)
    return process.returncode or 0


if __name__ == "__main__":
    sys.exit(main())
