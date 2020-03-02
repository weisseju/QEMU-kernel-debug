set -x

screen -t r1 \
        start-stop-daemon --make-pidfile --pidfile "/tmp/vm-r1.pid" \
        --start --startas /usr/bin/kvm -- \
        -nodefconfig -no-user-config -nodefaults \
        -m 256m \
        -display none \
        \
        -chardev stdio,id=charserial0,signal=off \
        -device isa-serial,chardev=charserial0,id=serial0 \
        -chardev socket,id=charserial1,path=/tmp/vm-r1-serial.pipe,server,nowait \
        -device isa-serial,chardev=charserial1,id=serial1 \
        \
        -chardev socket,id=con0,path=/tmp/vm-r1-console.pipe,server,nowait \
        -mon chardev=con0,mode=readline,default \
        \
        -fsdev local,security_model=passthrough,id=fsdev-root,path=/,readonly \
        -device virtio-9p-pci,id=fs-root,fsdev=fsdev-root,mount_tag=/dev/root \
        -fsdev local,security_model=none,id=fsdev-home,path=/home/jw \
        -device virtio-9p-pci,id=fs-home,fsdev=fsdev-home,mount_tag=homeshare \
        -fsdev local,security_model=none,id=fsdev-lab,path=/home/jw \
        -device virtio-9p-pci,id=fs-lab,fsdev=fsdev-lab,mount_tag=labshare \
        \
        -gdb unix:/tmp/vm-r1-gdb.pipe,server,nowait \
        -kernel /home/jw/ananas/kernel/net-next/run/linux \
        -append "init=/sbin/init console=ttyS0 uts=r1 root=/dev/root rootflags=trans=virtio,version=9p2000.u ro rootfstype=9p" \
        $netargs \
        "$@"
