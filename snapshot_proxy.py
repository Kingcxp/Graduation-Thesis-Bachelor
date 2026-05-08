import socket
import json
import time
import argparse


QMP_SOCKET = "/tmp/qmp-socket"
TRIGGER_CHANNEL = "/tmp/guest-trigger-channel"


def hmp(cmdline):
    """执行 HMP 命令，并强制等待完成"""
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.connect(QMP_SOCKET)

    # 握手
    sock.recv(8192)
    sock.sendall(b'{"execute":"qmp_capabilities"}\n')
    sock.recv(8192)

    # 发送 HMP 命令（关键：会阻塞直到完成）
    cmd = {
        "execute": "human-monitor-command",
        "arguments": {"command-line": cmdline}
    }
    sock.sendall(json.dumps(cmd).encode() + b"\n")

    # 必须一直读，直到返回完整 JSON（保证等待完成）
    resp = b""
    while True:
        chunk = sock.recv(8192)
        if not chunk:
            break
        resp += chunk
        try:
            json.loads(resp.decode())
            break
        except:
            continue

    sock.close()
    return json.loads(resp.decode())


def connect_vm():
    while True:
        try:
            s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            s.connect(TRIGGER_CHANNEL)
            print("✅ Connected to QEMU trigger channel")
            return s
        except:
            time.sleep(0.5)


def main():
    parser = argparse.ArgumentParser(description="QEMU Snapshot Proxy")
    parser.add_argument(
        "--stage", 
        type=str, 
        default="fuzzing", 
        choices=["fuzzing", "snapshot"],
        help="Default stage for check_snapshot: 'fuzzing' (default) or 'snapshot'"
    )
    args = parser.parse_args()

    # 根据参数设置默认状态
    if args.stage == "fuzzing":
        default_stage = "FUZZING_STAGE"
    else:
        default_stage = "SNAPSHOT_STAGE"

    print(f"🚀 Starting proxy with stage: {default_stage}")

    while True:
        client = connect_vm()
        try:
            while True:
                data = client.recv(1024).decode().strip()
                if not data:
                    break

                if data == "take_snapshot":
                    print("\n🚀 START SNAPSHOT (WAIT FOR FULL COMPLETION)...")
                    tag = "moneta"

                    # ==============================
                    # 🔥 核心：同步三步，必须全部完成
                    # ==============================
                    hmp("stop")            # 暂停虚拟机
                    hmp(f"savevm {tag}")   # 拍摄快照（阻塞等完成）
                    hmp("cont")            # 恢复虚拟机

                    print(f"✅ SNAPSHOT FINISHED: {tag}")
                    client.sendall(b"SNAPSHOT_DONE\n")
                elif data == "check_snapshot":
                    print(f"🔍 Received check_snapshot: Responding {default_stage}")
                    client.sendall(f"{default_stage}\n".encode())

        except Exception as e:
            print(f"⚠️ Error: {e}")
            client.close()
            time.sleep(1)


if __name__ == "__main__":
    main()
