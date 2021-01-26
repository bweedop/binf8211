#!/bin/bash

### Code for first set of questions

# human gene tp53 can be seen at https://genome.ucsc.edu/cgi-bin/hgTracks?db=hg38&lastVirtModeType=default&lastVirtModeExtraState=&virtModeType=default&virtMode=0&nonVirtPosition=&position=chr17%3A7668402%2D7687538&hgsid=1010008785_xs4IuOdToWxRQj6ByZmnb7703a5q

# You can download the necessary files after going to the link above and using
# the table browser provided by UCSC

# RefSeq (curated subset) file 
refSeq=tp53Hg38RefSeqCurated
# GENCODEv32 file
gencode=tp53Hg38Gencodev32

if [ ! -f "$refSeq" ]; then
  echo "You need to download TP53 transcripts reported by NCBI RefSeq genes (curated subset) from UCSC"
  return
fi

if [ ! -f "$gencode" ]; then
  echo "You need to download TP53 transcripts reported by GENCODEv32 from UCSC"
  return
fi

# How many transcripts are reported by each annotation database of the NCBI RefSeq genes (curated subset) and the GENCODE V32? 

# You can do this visually by counting the lines on the genome browser for each 
# database

# How many transcripts agree between the two databases?

# Get columns I need to check for agreement
cat $gencode | grep -v "#" | cut -f2-10 > gencodeColumnsNeeded
cat $refSeq | grep -v "#" | cut -f3-11 > refSeqColumnsNeeded

gencodeSubset=gencodeColumnsNeeded
refSeqSubset=refSeqColumnsNeeded

# Sort the two files that we just created
sort $gencodeSubset > gencodeColumnsNeeded.sorted
sort $refSeqSubset > refSeqColumnsNeeded.sorted

# Compare the two files, filter out unique lines and count lines
echo "Amount of transcripts that agree between RefSeq and GENCODEv32:"
comm -12 gencodeColumnsNeeded.sorted refSeqColumnsNeeded.sorted | wc -l
echo ""

# Choose a transcript from the NCBI RefSeq gene annotation: indicate the transcript ID and answer the following question about this transcript: How many exons are UTR and how many exons are coding?

# Chosen transcript
transcriptID=NM_001276698.2
echo "Transcript ID: "
echo $transcriptID

# Get the exon start coordinates
cdsStart=$(cat tp53Hg38RefSeqCurated | grep "NM_001276698.2" | cut -f7)
cdsEnd=$(cat tp53Hg38RefSeqCurated | grep "NM_001276698.2" | cut -f8)
exonsStart=$(cat tp53Hg38RefSeqCurated | grep "NM_001276698.2" | cut -f10)
utrExons=0
utrCoords=()
cdsExons=0
cdsCoords=()

for i in $(echo $exonsStart | sed "s/,/ /g")
do
    if [ $i -lt $cdsStart ]; then
      utrExons=$((utrExons+1))
      utrCoords+=($i)
    elif [ $i -ge $cdsStart ] && [ $i -lt $cdsEnd ]; then
      cdsExons=$((cdsExons+1))
      cdsCoords+=($i)
    else
      echo "check $i"
    fi
done

echo "Number of UTR exons: "
echo "$utrExons (${utrCoords[*]})"
echo "Number of coding exons: "
echo "$cdsExons (${cdsCoords[*]})"

echo ""
### Code for the second set of questions
echo "Answers for second set of questions:"
echo ""
humanGeneAnnotation=Homo_sapiens.GRCh38.102.chr.gtf

# Download file if I don't have it
if [ ! -f "$humanGeneAnnotation" ]; then
  wget ftp://ftp.ensembl.org/pub/release-102/gtf/homo_sapiens/Homo_sapiens.GRCh38.102.chr.gtf.gz
  gunzip Homo_sapiens.GRCh38.102.chr.gtf.gz
fi

# How many genes and transcripts in total are in this GTF file?
nGene=$(cat Homo_sapiens.GRCh38.102.chr.gtf | cut -f3 | grep -v "#" | grep -c "gene")
nTranscript=$(cat Homo_sapiens.GRCh38.102.chr.gtf | cut -f3 | grep -v "#" | grep -c "transcript")
nGenesAndTranscripts=$(expr $nGene + $nTranscript)
echo "Total number of genes and transcripts in $humanGeneAnnotation:"
echo $nGenesAndTranscripts

# How many genes and transcripts are protein-coding?
nProteinCodingGene=$(cat Homo_sapiens.GRCh38.102.chr.gtf | grep "protein_coding" | cut -f3 | grep -c "gene")
nProteinCodingTranscript=$(cat Homo_sapiens.GRCh38.102.chr.gtf | grep "protein_coding" | cut -f3 | grep -c "transcript")
echo "Number of genes and transcripts that are protein coding: "
echo $(expr $nProteinCodingGene + $nProteinCodingTranscript)
