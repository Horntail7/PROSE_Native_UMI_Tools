import argparse
import gzip
from Bio import SeqIO
from Bio.Seq import Seq
parser = argparse.ArgumentParser()

parser.add_argument('--inp1', '--input_file1', type=str, default='umi_Fwd.fastq.gz',
                    help='Full path to the input file (umi_Fwd.fastq.gz)')
parser.add_argument('--inp2', '--input_file2', type=str, default='umi_Rev.fastq.gz',
                    help='Full path to the input file (umi_Rev.fastq.gz)')
parser.add_argument('--out', '--output_file', type=str, default='umis.tsv',
                    help='Full path to the output file (umis.tsv)')

args = parser.parse_args()

outfile = open(args.out, "w")
with gzip.open(args.inp1, "rt") as Fwdfile:
    for record in SeqIO.parse(Fwdfile, "fastq"):
        seq = record.id.split("_")[-1]
        print(seq[:16], seq[-7:], seq[16:-7], sep="\t", file=outfile)
with gzip.open(args.inp2, "rt") as Revfile:
    for record in SeqIO.parse(Revfile, "fastq"):
        rev_seq = Seq((record.id.split("_")[-1]))
        fwd = rev_seq.reverse_complement()
        print(fwd[:16], fwd[-7:], fwd[16:-7], sep = "\t", file=outfile)

