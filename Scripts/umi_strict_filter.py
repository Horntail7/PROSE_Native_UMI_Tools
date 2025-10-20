import argparse
import Levenshtein
parser = argparse.ArgumentParser()

parser.add_argument('--inp', '--input_file', type=str, default='umis.tsv',
                    help='Full path to the input file (umis.tsv)')
parser.add_argument('--out1', '--out1_file', type=str, default='daughters.tsv',
                    help='Full path to the daughter file (daughters.tsv)')
parser.add_argument('--out2', '--out2_file', type=str, default='mistakes.tsv',
                    help='Full path to the mistakes file (mistakes.tsv)')

args = parser.parse_args()

mothers = {}
daughter_file = open(args.out1, "w")
mistake_file = open(args.out2, "w")

counter=0
with open(args.inp, "r") as file:
    for line in file:
        row = line.split("\t")
        mistake = row[2].rstrip('\n')
        if row[0] not in mothers.keys():
            mothers[row[0]] = ([row[1]],[mistake])
        else:
            flag = 0
            for daughter in mothers[row[0]][0]:
                if Levenshtein.distance(daughter, row[1])<=2:
                    flag = 1
                    break
            if flag == 0:
                mothers[row[0]][0].append(row[1])
                mothers[row[0]][1].append(mistake)
        counter+=1
        if (counter%100000) == 0:
            print(counter)

sortmothers = dict(sorted(mothers.items(), key=lambda item:len(item[1][0]), reverse=True))
for key in sortmothers:
    print(key, "\t", '  '.join(mothers[key][0]), file=daughter_file)
    print(key, "\t",'  '.join(mothers[key][1]), file=mistake_file)
