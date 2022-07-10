KERNELRELEASE ?= $(shell uname -r)
KERNEL_DIR  ?= /usr/src/kernels/$(KERNELRELEASE)
CFLAGS = -I`pwd`

obj-m += uwurandom.o

install:
	make -C $(KERNEL_DIR) M=`pwd` modules_install

all:
	make -C $(KERNEL_DIR) M=`pwd` modules

clean:
	make -C $(KERNEL_DIR) M=`pwd` clean
