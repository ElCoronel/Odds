#!/usr/bin/python
from passlib.hash import sha512_crypt
import sys

pword = sha512_crypt.hash(sys.argv[1])
print pword

print sha512_crypt.verify(sys.argv[1], pword)
