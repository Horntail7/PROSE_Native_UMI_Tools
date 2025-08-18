import argparse
import random
parser = argparse.ArgumentParser()

parser.add_argument('--inp', '--input_file', type=str, default='mistakes.tsv',
                    help='Full path to the input file (mistakes.tsv)')
args = parser.parse_args()
top = ['TTGTACA', 'TTGCACA', 'TTGAACA', 'TTGGACA', 'TTGACA']

allmistakes = []
outfile = open("pseudo_single_mol.csv", "w")
with open(args.inp, "r") as file:
    for line in file:
        section = line.rstrip("\n")
        row = section.split("\t")
        mistakes = row[1].split("  ")
        for mistake in mistakes:
            allmistakes.append(mistake.strip())
random.shuffle(allmistakes)

hund_mistakes = {}
for i in range (100):
    hund_mistakes[i]=allmistakes[(100*i):(100*(i+1))]

for key in hund_mistakes:
    percents = []
    for value in top:
        percents.append(hund_mistakes[key].count(value))
    percents.append(100-sum(percents))
    str_percents = list(map(str, percents))
    print(str(key)+","+",".join(str_percents), file=outfile)



