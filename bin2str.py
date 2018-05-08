#!/usr/bin/python

import binascii
import sys

hex_dump = "bindump.txt"
bin_dump = "bindump.bin"

if sys.argv[1] == "str":
	f = open(sys.argv[2])
	a = f.read()
	b = binascii.b2a_hex(a.strip())
	f2 = open(hex_dump, "w")
	f2.write(b)
	f2.close()
elif sys.argv[1] == "bin":
	f1 = open(hex_dump, "r")
	a = f1.read()
	b = binascii.a2b_hex(a.strip())
	f2 = open(sys.argv[2] + "-new", "w")
	f2.write(b)
	f2.close()
