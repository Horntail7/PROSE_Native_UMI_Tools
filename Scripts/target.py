import argparse
from Bio import SeqIO
from Bio.Seq import Seq
parser = argparse.ArgumentParser()

parser.add_argument('--inp', '--input_file', type=str, default='Target.fasta',
                    help='Full path to the input file (Target.fasta)')
parser.add_argument('--out', '--output_file', type=str, default='umi_tools.sh',
                    help='Full path to the output file (umi_tools.sh)')
args = parser.parse_args()
outfile = open(args.out, "w")
print("input=$1","Foutput=$2","Routput=$3", sep="\n", file=outfile)

fwd_code = SeqIO.read(args.inp, "fasta")
fwd = fwd_code.seq
rev = fwd.reverse_complement()

umi_len = []
for i in range (len(fwd)-1):
    if fwd[i]=='N' and fwd[i-1]!='N':
        umi_len.append([i])
    elif fwd[i]=='N' and fwd[i+1]!='N':
        umi_len[-1].append(i+1)
print('umi_tools extract --extract-method=regex --bc-pattern=".*', end="", file=outfile)


for i in range (len(umi_len)):
    pair = umi_len[i]
    previous = umi_len[i-1]
    distance = pair[0]-previous[1]
    length = pair[1]-pair[0]
    if i == 0:
        print("(?P<umi_"+str(i)+">.{"+str(length)+"})", end="", file=outfile)
    elif distance<=8:
        print(fwd[previous[1]:pair[0]], end="", file=outfile)
        print("(?P<umi_"+str(i)+">.{"+str(length)+"})", end="", file=outfile)
        try:
            if umi_len[i+1][0]-pair[1]>8 and distance<8:
                print(fwd[pair[1]:(pair[1]+(8-distance))], end="", file=outfile)
        except:
            continue
    elif distance>8:
        print("(?P<discard_"+str(i)+">.+)", end="", file=outfile)
        print(fwd[pair[0]-4:pair[0]], end="", file=outfile)
        print("(?P<umi_"+str(i)+">.{"+str(length)+"})", end="", file=outfile)
        try: 
            if i==5 or umi_len[i+1][0]-pair[1]>8:
                print(fwd[pair[1]:pair[1]+4], end="", file=outfile)
        except:
            continue
print('.*" -I $input -S $Foutput', file=outfile)
print("ACAGTCTGTAAAGTTGGTCTCAGTTCGGATTGAGGGCTGCAATTCGCNNNNCCTCATGANNNNAGTCGGAATCACTAGTAATCGCGAATCAGNNNNCCATGNNNNTCGCGGTGAATACGTTCTCGGGTCTTGNNNCACCGCCCGTCAAACTATGAGAGCTGGTANNNNNNNTCACGTACTGCGCGTAGATC", file=outfile)



