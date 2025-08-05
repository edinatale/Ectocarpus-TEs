import sys
exchange={}
addanyway=set()
mappingfile=sys.argv[1] # mapping which to exchange
fasta1=sys.argv[2] # thing that should get iterated and replaced
fasta2=sys.argv[3] # big fasta with the replacements
fastaout=sys.argv[4]# ountmane file
def parsefasta(file):
    sequences = {}
    cname = None
    cseq = ''
    with open(file) as f:
        for line in f:
            if line[0] == '>' and not cname is None:
                sequences[cname] = cseq
                cseq = ''
            if line[0] == '>':
                cname = line.strip()[1:]
            else:
                cseq += line.strip()
        sequences[cname] = cseq
    return sequences
 
with open(mappingfile) as f:
    for line in f:
        spt=line.split()
        if len(spt)==2:
            exchange[spt[0]]=spt[1]
        else:
            addanyway.add(spt[0])
 
dict1=parsefasta(fasta2)
dict2=parsefasta(fasta1)
with open(fastaout,'w') as f:
    for k in dict2:
        if k in exchange:
            print('exchanging',k,exchange[k],exchange[k] in dict1)
            f.write(f'>{exchange[k]}\n')
            seq=dict1[exchange[k]]
            f.write('\n'.join([seq[i:i+60] for i in range(0, len(seq), 60)]) + '\n')
        else:
            f.write(f'>{k}\n')
            seq=dict2[k]
            f.write('\n'.join([seq[i:i+60] for i in range(0, len(seq), 60)]) + '\n')
 
    for id in addanyway:
        f.write(f'>{id}\n')
        seq = dict1[id]
        f.write('\n'.join([seq[i:i + 60] for i in range(0, len(seq), 60)]) + '\n')
