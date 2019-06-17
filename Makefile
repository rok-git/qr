#CFLAGS	= -g
CFLAGS	= 
#CC	= cc -framework Cocoa -framework CoreImage -fobjc-arc
LDFLAGS	= -framework Cocoa -framework CoreImage
CC	= cc -fobjc-arc
PROGS	= qr qrr

.PHONY:	clean all

all:	$(PROGS)

clean:
	rm -f $(PROGS)

