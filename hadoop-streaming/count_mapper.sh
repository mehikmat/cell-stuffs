#!/bin/sh
# 's_\^\*~_\n_g' is the line delimiter in input file replace with yours
sed 's_\\s_\n_g'| wc -l