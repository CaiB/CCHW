#!/usr/bin/env python3

import math
import sys

VALUE = 0.5
DECIMAL_BITS = 10

def fixedPointEstimate(value, depth):

    best = ""
    best_v = 0
    bits = ""
    bits_v = 0

    for bit in range(0, depth):
    
        one = bits_v + math.pow(2, -1*(bit+1))

        if(sqr_err(value, one) < sqr_err(value, best_v)):
            best = bits + "1"
            best_v = one
        else:
            best = best + "0"

        if (one < value):
            bits += "1"
            bits_v = one
        else:
            bits += "0"
    
    return best, best_v

def sqr_err(value, estimate):
    return math.pow(value-estimate, 2)

def binaryValue(binary):
    value = 0
    length = len(binary)

    for i in range(0, length):
        if (binary[length - i - 1] == '1'):
            value += math.pow(2, i)
    
    return int(value)



n = len(sys.argv)

if (n != 3):
    value = 0
    bitLength = 0
else :
    value = float(sys.argv[1])
    bitLength = int(sys.argv[2])

bits, value = fixedPointEstimate(value, bitLength)



sys.stdout.write(bits+","+str(value)+","+str(binaryValue(bits)))
sys.stdout.flush()
sys.exit(0)