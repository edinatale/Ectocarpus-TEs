#!/bin/bash
 
input_file="../consensi/EsilTE1.fa"  # Specify the input FASTA file
output_file="../Modified_EsilTE1.fa"  # Specify the output file for modified sequences

# Use sed to modify the headers and save sequences to the output file
sed -e 's/EsGypsy/LTR\/Gypsy/g' -e 's/EsCopia/LTR\/Copia/g' -e 's/Es_LARD/LTR\/LARD/g' -e 's/Es_Harb/DNA\/Harbinger/g' -e 's/Es_TIGGERJerky/DNA\/TIGGER/g' -e 's/EsPiggyBac/DNA\/PiggyBac/g' -e 's/EsMuDR/DNA\/MuDR/g' -e 's/Es_POGO/DNA\/POGO/g' -e 's/EsPOGO/DNA\/POGO/g' -e 's/EsMariner/DNA\/Mariner/g' -e 's/Es_Helitron/Helitron/g' -e 's/EsRTE/LINE\/RTE/g' -e 's/Es_NgaroDIRS/DIRS\/Ngaro/g' -e 's/EsNgaroDIRS/DIRS\/Ngaro/g' -e 's/EsTIR/DNA\/Unknown/g' -e 's/EsNoCat/Unknown/g' -e 's/^>.*:NoCat/>Unknown/g' -e 's/^>.*:LARD/>LTR\/LARD/g' -e 's/^>.*:SINE/>SINE/g' -e 's/^>.*:TIRcomp/>DNA\/Unknown/g' -e 's/^>.*:MITE/>DNA\/MITE/g' -e 's/^>.*:LINEcomp/>LINE\/Unknown/g' -e 's/^>.*:LTRcomp/>LTR\/Unknown/g' "$input_file" > "$output_file"

echo "Modified sequences with headers saved to $output_file"
