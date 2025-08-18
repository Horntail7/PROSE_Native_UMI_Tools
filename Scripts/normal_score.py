import math
import numpy as np
import argparse
import os.path
from Bio import SeqIO
from Bio.Align import PairwiseAligner
from Bio.Align import substitution_matrices
import random

MATCH_SCORE = 2
MISMATCH_SCORE = -1
GAP_OPEN_SCORE = -1
GAP_EXTEND_SCORE = -1
DEGENERATE_MATCH_SCORE = 0

def create_substitution_matrix():
    matrix = substitution_matrices.load("NUC.4.4")
    for base in "ATCG":
        matrix[base, base] = MATCH_SCORE
        for other_base in "ATCG":
            if base != other_base:
                matrix[base, other_base] = MISMATCH_SCORE
        matrix[base, "N"] = DEGENERATE_MATCH_SCORE
        matrix["N", base] = DEGENERATE_MATCH_SCORE
    matrix["N", "N"] = DEGENERATE_MATCH_SCORE
    return matrix

def score(seq, template, matrix):
    max_possible_score = len(template) * MATCH_SCORE

    aligner = PairwiseAligner()
    aligner.mode = 'global'
    aligner.substitution_matrix = matrix
    aligner.open_gap_score = GAP_OPEN_SCORE
    aligner.extend_gap_score = GAP_EXTEND_SCORE
    
    alignments = aligner.align(seq, template)
    best_alignment = alignments[0]

    return best_alignment.score/max_possible_score


def main():
    
    parser = argparse.ArgumentParser()
    
    parser.add_argument('--inp', '--input_file', type=str, default='inserts.out',
                        help='Full path to the input file (inserts.out)')
    parser.add_argument('--ncol', '--ncolums', type=int, default='3',
                        help='No. of columns in input (3)')
    parser.add_argument('--icol', '--icolums', type=int, default='1',
                        help='Insert column number (1)')

    
    args = parser.parse_args()
    
    infile=open(args.inp, "r") 
    lines=infile.readlines()

    insert_templates=['TTGTACA','TTGAACA','TTGGACA','TTGCACA']
#    insert_templates=['TTGTACA','TTGAACA','TTGGACA','TTGCACA','TTGACA']
#    insert_templates=['TTGTACA',  'TTGAACA', 'TTACACA', 'TACACA', 'TTCTACA', 'TTGCACA', 'TCTTACA']
    sub_matrix=create_substitution_matrix()

    nmols=1000

    mean={}
    std_dev={}
    for temp in insert_templates:
        mean[temp]=0.0
        std_dev[temp]=0.0
    mean['rest']=0.0
    std_dev['rest']=0.0
        
    outfile=open("scores_pseudobulk.csv","w")
    inserts=[]
    
    for line in lines:
        words=line.split()
        if len(words) == args.ncol:
            if len(words[args.icol-1]) < 10:
                inserts.append(words[args.icol-1])
            
    scores={}
    if len(inserts) >= nmols*100:
        count=0
        while count < nmols:
            random_group = inserts[count*100:(count+1)*100]
#            random_group = random.sample(inserts, 100)
            for temp in insert_templates:
                scores[temp]=0
#            scores['rest']=0
            for ins in random_group:
                flag=0
                for temp in insert_templates:
                    temp_score=score(ins,temp,sub_matrix)
                    if temp_score > 0.99:
                        scores[temp]+=1
                        flag=1
                        break
#                if flag == 0:
#                    scores['rest']+=1

#            scores['TTGCACA']+=scores['TTACACA']
#            del scores['TTACACA']
#            scores['TTGCACA']+=scores['TACACA']
#            del scores['TACACA']
#            scores['TTGTACA']+=scores['TTCTACA']
#            del scores['TTCTACA']
#            scores['TTGTACA']+=scores['TCTTACA']
#            del scores['TCTTACA']
#            for key in scores.keys():
#                scores[key]/=100
                    
            outfile.write("%d,"%count)
            for temp in scores.keys():
                outfile.write("%d,"%scores[temp])
            outfile.write("\n")
#            outfile.write("%d\n"%scores['rest'])
            count+=1

"""            for temp in insert_templates:
                mean[temp]+=scores[temp]
                std_dev[temp]+=scores[temp]*scores[temp]
            mean['rest']+=scores['rest']
            std_dev['rest']+=scores['rest']*scores['rest']

        for temp in insert_templates:
            mean[temp]/=nmols
            std_dev[temp]/=nmols
            std_dev[temp]=math.sqrt(std_dev[temp]-mean[temp]*mean[temp])
            
        mean['rest']/=nmols
        std_dev['rest']/=nmols
        std_dev['rest']=math.sqrt(std_dev['rest']-mean['rest']*mean['rest'])

        plist=[]
        for key in mean.keys():
            plist.append(mean[key]*100)
        for key in std_dev.keys():
            plist.append(std_dev[key]*100)

        print(", ".join([f"{f:.2f}" for f in plist]))"""
            
if __name__ == "__main__":
    main()

    
