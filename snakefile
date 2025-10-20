import os
import random

configfile: "config.yaml"

datadir = config["location"]

if not os.path.isdir(datadir):
    sys.exit(f"\n❌ Data directory '{datadir}' not found! Please create it or check the path.\n")

# TBD
CHIP_DIRS = config["samples"]

# List all Native directories for each Chip
NATIVE_DIRS = {}
for chip in CHIP_DIRS:
    chip_dir=f"{datadir}/{chip}"
    subfolder = next(os.path.join(chip_dir, d) for d in os.listdir(chip_dir) if os.path.isdir(os.path.join(chip_dir, d)))
    fastq_dir = os.path.join(subfolder, "fastq_pass")
    NATIVE_DIRS[chip] = [
    name for name in os.listdir(fastq_dir)
    if os.path.isdir(os.path.join(fastq_dir, name))
    and 'barcode' in name
    and len(os.listdir(os.path.join(fastq_dir, name))) >= 1  # ensures the directory is not empty
    ]


# Function to list a random subset of FASTQ files for a given chip
def list_fastq_files(wildcards):
    chip_dir = f"{datadir}/{wildcards.chip}"
    subfolder = next(os.path.join(chip_dir, d) for d in os.listdir(chip_dir) if os.path.isdir(os.path.join(chip_dir, d)))
    fastq_dir = os.path.join(subfolder, "fastq_pass")
    native_dir = f"{fastq_dir}/{wildcards.native}"
    fastq_files = [f for f in os.listdir(native_dir) if f.endswith('.fastq.gz')]
    # Select NSAMPLE random files if there are more than NSAMPLE, else select all
    selected_files = random.sample(fastq_files, min(config["prep"]["nsample"], len(fastq_files)))
    return [os.path.join(native_dir, f) for f in selected_files]



chip_native_pairs = [
    (chip, native)
    for chip in CHIP_DIRS
    for native in NATIVE_DIRS[chip]
]

chips, natives = zip(*chip_native_pairs)

# Define rule all to specify final outputs for each chip
rule all:
    input:
        expand(
            "results/{chip}/{native}/merged.fastq.gz",
            zip,
            chip=chips,
            native=natives
        ),
	expand(
            "results/{chip}/{native}/aligned_Fwd.fastq.gz",
            zip,
            chip=chips,
            native=natives
        ),
	expand(
            "results/{chip}/{native}/aligned_Rev.fastq.gz",
            zip,
            chip=chips,
            native=natives
        ),
	expand(
            "results/{chip}/{native}/umis.tsv",
	    zip,
	    chip=chips,
	    native=natives
        ),
	expand(
            "results/{chip}/{native}/daughters.tsv",
	    zip,
	    chip=chips,
	    native=natives
	),
	expand(
            "results/{chip}/{native}/mistakes.tsv",
	    zip,
	    chip=chips,
	    native=natives
	),
	expand(
            "results/{chip}/Summary.csv",
	    chip=CHIP_DIRS
	)
	

# Rule to merge the FASTQ files
rule merge_fastq:
    input:
        list_fastq_files
    output:
        "results/{chip}/{native}/merged.fastq.gz"
    resources:
        mem_mb=4000
    shell:
        """
        for f in {input}; do
            cat "$f" >> {output}.temp;
        done
        mv {output}.temp {output}
        """


rule align_fwd:
    input:
        Templates=config["alignment"]["reference"],
	script=config["alignment"]["umi_tools_fwd"],
	fastq="results/{chip}/{native}/merged.fastq.gz"		
    output:
        "results/{chip}/{native}/aligned_Fwd.fastq.gz"
    resources:
        mem_mb=4000
    shell:
        """
	sh {input.script} {input.fastq} {output} 
        """


rule align_rev:
    input:
        Templates=config["alignment"]["reference"],
	script=config["alignment"]["umi_tools_rev"],
	fastq="results/{chip}/{native}/merged.fastq.gz"		
    output:
        "results/{chip}/{native}/aligned_Rev.fastq.gz"
    resources:
        mem_mb=4000
    shell:
        """
	sh {input.script} {input.fastq} {output} 
        """


rule grab_umi:
    input:
        Aligned_Fwd="results/{chip}/{native}/aligned_Fwd.fastq.gz",
	Aligned_Rev="results/{chip}/{native}/aligned_Rev.fastq.gz",
	script=config["alignment"]["grab_umi"]
    output:
        "results/{chip}/{native}/umis.tsv"
    resources:
        mem_mb=4000
    shell:
        """
	python3 {input.script} --inp1 {input.Aligned_Fwd} --inp2 {input.Aligned_Rev} --out {output}
        """

rule umi_filter:
    input:
        umis="results/{chip}/{native}/umis.tsv",
        script=config["alignment"]["umi_filter"]
    output:
        daughters="results/{chip}/{native}/daughters.tsv",
        mistakes="results/{chip}/{native}/mistakes.tsv"
    resources:
        mem_mb=4000
    shell:
        """
        python3 {input.script} --inp {input.umis} --out1 {output.daughters} --out2 {output.mistakes}
        """

def get_umis_summary_inputs(wildcards):
    chip = wildcards.chip
    return [f"results/{chip}/{native}/umis.tsv" for native in NATIVE_DIRS[chip]]

def get_mistakes_summary_inputs(wildcards):
    chip = wildcards.chip
    return [f"results/{chip}/{native}/mistakes.tsv" for native in NATIVE_DIRS[chip]]


rule summary:
    input:
        umis=get_umis_summary_inputs,
        mistakes=get_mistakes_summary_inputs
    output:
        "results/{chip}/Summary.csv"
    resources:
        mem_mb=4000
    shell:
        """
        for umi in {input.umis}; do
            native=$(echo "$umi" | cut -d'/' -f3)
            nreads=$(wc -l < "$umi")
            echo "$native,$nreads" >> {output}.temp
        done

	# Count lines in mistake file, and how many have more than 10 columns
        for mistake in {input.mistakes}; do
            nmothers=$(wc -l < "$mistake")
            n10=$(awk 'NF > 10 {{count++}} END {{print count+0}}' "$mistake")
            echo "$nmothers,$n10" >> {output}.temp2
        done
	echo "sample,n_reads,n_mothers,n>10D" > {output}
        paste -d ',' {output}.temp {output}.temp2 >> {output}
        rm -f {output}.temp {output}.temp2
        """

