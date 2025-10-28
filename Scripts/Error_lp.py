import numpy as np
import argparse
import os.path
import csv
import matplotlib.pyplot as plt

import subprocess

parser = argparse.ArgumentParser()

parser.add_argument('--inp', type=str, default='input.csv',
                    help='Full path to the input.csv (input.csv)')
parser.add_argument('--out', type=str, default='outfile',
                    help='Name of output file (outfile)')

args = parser.parse_args()

if os.path.isfile(args.inp) == False:
    print("Error: input.csv (default) does not exist")
    print("# For usage type: python3.9 Error_error.py --help")
    exit()

outname=args.out+'_errors.png'
#aas=['I','N','Q','V','R','F','L','D','H','G','E','W']
#aas=['Can','R','G','E','W','R','G','E','W']
#aas=['G','R','E','S','pS','pY','Uni']
aas=['Sulfo_Vent','Sulfo_HK','Sulfo','Therminator','Sequenase']
bars=[]
nA=[]
nG=[]
nT=[]
nC=[]
nS=[]
nR=[]
nA2=[]
nG2=[]
nT2=[]
nC2=[]
nS2=[]
nR2=[]

with open(args.inp, newline='') as csvfile:
    header=np.array(next(csvfile).split(','))
    
    csvreader = csv.reader(csvfile)

    csvlines=list(csvreader)
    count=0

    for row in csvlines:
        
        bars.append(str(row[0]))
        nA.append(float(row[1]))
        nG.append(float(row[2]))    
        nT.append(float(row[3]))
        nC.append(float(row[4]))
        nS.append(float(row[5]))
        nR.append(float(row[6]))
        nA2.append(float(row[7]))
        nG2.append(float(row[8]))
        nT2.append(float(row[9]))
        nC2.append(float(row[10]))
        nS2.append(float(row[11]))
        nR2.append(float(row[12]))

print(nA)
print(nG)
print(nT)
print(nC)
print(nS)
print(nR)
print(nA2)
print(nG2)
print(nT2)
print(nC2)
print(nS2)
print(nR2)

fig, ax = plt.subplots()
#plt.plot(bars, nG)
#plt.plot(bars, nT)
#plt.plot(bars, nC)
#ax.set_ylim([0,60])
plt.errorbar(bars, nA, yerr = nA2, label='A', color ='red')
plt.errorbar(bars, nG, yerr = nG2, label='G', color ='blue')
plt.errorbar(bars, nT, yerr = nT2, label='T', color ='orange')
plt.errorbar(bars, nC, yerr = nC2, label='C', color ='green')
plt.errorbar(bars, nS, yerr = nS2, label='Skip', color ='purple')
plt.errorbar(bars, nR, yerr = nR2, label='Rest', color ='grey')

# Add some text for labels, title and custom x-axis tick labels, etc.
ax.set_ylabel('Percentage')
ax.set_title(args.out)
ax.set_xticklabels(bars, rotation=90)
ax.legend()


plt.show()

fig.savefig(outname)

