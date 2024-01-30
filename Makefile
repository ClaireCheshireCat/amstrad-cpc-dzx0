CPL=sjasmplus
CPLPARMS=-Wall -Wno-out0 -Wno-rdlow -Wno-luamc -Wno-fwdref --inc=./src/
COMPRESS=zx0

all: ./dist/dzx0.dsk

./dist/dzx0.dsk: ./src/*.asm ./src/std/*.asm ./assets/*
	@echo "--> Compiling"
	$(CPL) ./src/main.asm $(CPLPARMS)
	iDSK ./dist/dzx0.dsk -i ./assets/shinobi.zx0 -c 4086 -t 1
	iDSK ./dist/dzx0.dsk -i ./assets/shinobi.bas

clean:
	 rm ./generated/*
	 rm ./dist/*
