#!/usr/bin/python3
import os

with open("/export/home/tmccombs/new_cadcam_file") as file:
    for line in file:
        line = line.strip()
        try:
            f = open(line)
            f.close()
        except FileNotFoundError:
            print(line, ' File does not exist', file=open("/export/home/gsanders/not_found.out", "a"))
