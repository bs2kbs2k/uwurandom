KERNELRELEASE ?= $(shell uname -r)
KERNEL_DIR  ?= /usr/src/kernels/$(KERNELRELEASE)
CFLAGS = -I`pwd`

OBJ_FILE       := $(obj-m)
SRC_FILE       := $(OBJ_FILE:.o=.c)
CMD_FILE       := .$(OBJ_FILE).cmd
MODNAME        := $(OBJ_FILE:.o=)

obj-m += uwurandom.o

install:
	make -C $(KERNEL_DIR) M=`pwd` modules_install

all:
	make -C $(KERNEL_DIR) M=`pwd` modules

clean:
	make -C $(KERNEL_DIR) M=`pwd` clean
