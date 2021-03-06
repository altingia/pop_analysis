#!/bin/sh
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --mem-per-cpu=2G
#SBATCH --time=100:00:00
#SBATCH --output=Multiple_sample_GATK_HC.sh.%A_%a.stdout
#SBATCH -p intel
#SBATCH --workdir=./


#https://software.broadinstitute.org/gatk/documentation/tooldocs/3.8-0/org_broadinstitute_gatk_tools_walkers_haplotypecaller_HaplotypeCaller.php
#https://gatkforums.broadinstitute.org/gatk/discussion/5987/is-indel-realignment-necessary-when-haplotypecaller-re-assembles-all-reads-in-a-region
GATK=/opt/linux/centos/7.x/x86_64/pkgs/gatk/3.4-46/GenomeAnalysisTK.jar
Picard=/opt/linux/centos/7.x/x86_64/pkgs/picard/2.6.0/bin/picard
JAVA=/opt/linux/centos/7.x/x86_64/pkgs/java/jdk1.7.0_17/bin/java
samtools=/opt/linux/centos/7.x/x86_64/pkgs/samtools/0.1.19/bin/samtools
genome=~/BigData/00.RD/Assembly/Pacbio/Reference/Fairchild/Fairchild_v1.fasta


CPU=$SLURM_NTASKS
if [ ! $CPU ]; then
   CPU=2
fi

N=$SLURM_ARRAY_TASK_ID
if [ ! $N ]; then
    N=1
fi

echo "CPU: $CPU"
echo "N: $N"

FILE=`ls *.bam | head -n $N | tail -n 1`
SAMPLE=${FILE%.bam}
echo "File: $FILE"
echo "Sample: $SAMPLE"

echo "Multi-sample SNP calling from illumina: Step 1. generate individual gvcf"

#snp call
if [ ! -e $SAMPLE\.gatk.raw.g.vcf ]; then
$JAVA -Xmx40g -jar $GATK \
      -T HaplotypeCaller \
      -R $genome \
      -I $FILE \
      -o $SAMPLE\.gatk.raw.g.vcf \
      -nct $CPU \
      -allowPotentiallyMisencodedQuals \
      --allow_potentially_misencoded_quality_scores \
      --genotyping_mode DISCOVERY \
      --emitRefConfidence GVCF \
      -mmq 20 \
      -mbq 30 \
      -variant_index_type LINEAR \
      -variant_index_parameter 128000
fi

echo "Done!"
