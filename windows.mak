
## You will need to change these two settings for your own system.
CC="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\Llvm\8.0.0\bin\clang.exe"

POSTGRES="C:\Program Files\PostgreSQL\11"

## Nothing below this line should require touching.

CFLAGS=-m64 -Wall -Wextra -O3 \
	-I$(POSTGRES)\include\server\port\win32_msvc \
	-I$(POSTGRES)\include\server\port\win32 \
	-I$(POSTGRES)\include\server \
	-I$(POSTGRES)\include

LDFLAGS=-L$(POSTGRES)\lib -lpostgres

## This implicit rule takes care of common.obj, crc32.obj and md5.obj
.c.obj:
	$(CC) $(CFLAGS) -c $< -o$@

src\hashtypes.dll: src\common.obj src\crc32.obj src\md5.obj src\sha1.obj \
	src\sha224.obj src\sha256.obj src\sha384.obj src\sha512.obj
	$(CC) $(CFLAGS) -shared $** $(LDFLAGS) -o$@

src\sha1.obj: src\sha.c
	$(CC) $(CFLAGS) -c src\sha.c -o$@ -DSHA_NAME=1 -DSHA_LENGTH=20
src\sha224.obj: src\sha.c
	$(CC) $(CFLAGS) -c src\sha.c -o$@ -DSHA_NAME=224 -DSHA_LENGTH=28
src\sha256.obj: src\sha.c
	$(CC) $(CFLAGS) -c src\sha.c -o$@ -DSHA_NAME=256 -DSHA_LENGTH=32
src\sha384.obj: src\sha.c
	$(CC) $(CFLAGS) -c src\sha.c -o$@ -DSHA_NAME=384 -DSHA_LENGTH=48
src\sha512.obj: src\sha.c
	$(CC) $(CFLAGS) -c src\sha.c -o$@ -DSHA_NAME=512 -DSHA_LENGTH=64

## We only install version 0.1.5 since the earlier releases haven't
## been ported to Windows.
install: src\hashtypes.dll
    copy src\hashtypes.dll $(POSTGRES)\lib
    copy hashtypes.control $(POSTGRES)\share\extension
    copy sql\hashtypes--0.1.5.sql $(POSTGRES)\share\extension
