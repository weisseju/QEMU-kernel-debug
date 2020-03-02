02.03.2020

Motivation: praktisches Beispiel für Kernel debugging eines Kernels, der unter QEMU läuft.

        1. Startpunkt: mein Kernel „home/jw/ananas/kernel/goldfish“ 4.4 kernel
        2. Kapitel „Booting QEMU with a minimal kernel“ mit Skript „/home/jw/ananas/kernel/goldfish/qemu-minimal“
        3. mountet root filesystem via 9P
ACHTUNG: mount_tag=/dev/root
        4. QEMU-Monitor in a separate root shell
socat UNIX:/tmp/vm-name-console.pipe –
        5. im QEMU-Monitor
q

beendet VM und QEMU-Monitor

        6. Jetzt 3.6 Kernel
        7. cd /home/jw/ananas/kernel
        8. git clone git://git.kernel.org/pub/scm/linux/kernel/git/netdev/net-next.git
        9. mittels „git-cola“ auf Tag „v3.6“ auschecken
        10. enable CONFIG_OVERLAYFS_FS in .config
        11. modify 
a) Makefile: 

# JW 28.02.2020
# https://lists.ubuntu.com/archives/kernel-team/2016-May/077178.html
# disable -pie when gcc has it enabled by default

# force no-pie for distro compilers that enable pie by default
KBUILD_CFLAGS += $(call cc-option, -fno-pie)
KBUILD_CFLAGS += $(call cc-option, -no-pie)
KBUILD_AFLAGS += $(call cc-option, -fno-pie)
KBUILD_CPPFLAGS += $(call cc-option, -fno-pie)

b) kernel/timeconst.pl

--- a/kernel/timeconst.pl
+++ b/kernel/timeconst.pl

@@ -370,7 +370,7 @@ if ($hz eq '--can') {

 	}

 

 	@val = @{$canned_values{$hz}};

-	if (!defined(@val)) {

+	if (!@val) {

 		@val = compute_values($hz);
c) lib/decompress_unlzo.c

STATIC inline int INIT parse_header(
static inline int INIT parse_header(

d) added include/linux/compiler-gcc7.h

        12. kernel make
        13. on top of this build 3.6 kernel patch the following

cd /home/jw/ananas/kernel/goldfish
./scripts/kconfig/merge_config.sh .config .config-fragment
make
overlayfs
jw@eh3:~/ananas/kernel$ git clone git://git.kernel.org/pub/scm/linux/kernel/git/netdev/net-next.git


git remote add torvalds git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
git fetch torvalds
git remote add overlayfs git://git.kernel.org/pub/scm/linux/kernel/git/mszeredi/vfs.git
git fetch overlayfs
git merge-base overlayfs/overlayfs.v15 v3.6
4cbe5a555fa58a79b6ecbb6c531b8bab0650778d
git checkout -b net-next+overlayfs
git cherry-pick 4cbe5a555fa58a79b6ecbb6c531b8bab0650778d..overlayfs/overlayfs.v15

        14. rebuild kernel (make clean && make)

        15. screen 

unter

/home/jw/ananas/kernel/net-next/run

linux (das “bzImage” des eben gebauten kernels)
./setup (das shell script, mit dem das lab gestartet wird)

anlegen
        16. WICHTIG: patch im „setup“

# Run our lab in screen
setup_screen() {
#    [ x"$TERM" = x"screen" ] || \
# JW: damit erscheinen anwaehlbare screen-Instanzen r1, r2, ...
    [ x"$TERM" = x"screen.xterm-256color" ] || \
        17. kernel mit „9P“ und „VIRTIO“-support bauen
        18. /home/jw/ananas/kernel/net-next/run/setup
        19. in 3. normal user shell
/home/jw/ananas/net-next/gdb vmlinux

>win
>target remote | socat UNIX:/tmp/tmp.W36qWnrCEj/vm-r1-gdb.pipe -
