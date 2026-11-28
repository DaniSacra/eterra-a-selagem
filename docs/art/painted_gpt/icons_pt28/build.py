import sys
PAL={'CHAMA':'laranja-brasa e vermelho-fogo, fundo do miolo vermelho-escuro amarronzado',
'LUZ':'dourado-claro e branco quente, fundo do miolo azul-noite',
'GEADA':'azul-gelo pálido e branco, fundo do miolo azul-escuro',
'VIGILIA':'bronze e verde-oliva (nunca esmeralda), fundo do miolo verde-oliva escuro',
'VEU':'cinza-pérola e sépia (nunca violeta nem lilás), fundo do miolo cinza-carvão',
'MARE':'azul-mar e espuma branca, fundo do miolo azul-marinho escuro',
'MARCA':'ocre-dourado com toques vermelho-escuros, fundo do miolo marrom-escuro',
'PESTE':'verde-oliva amarelado e mostarda (nunca esmeralda), fundo do miolo oliva escuro',
'TROVAO':'cinza-aço e raios branco-azulados (nunca violeta), fundo do miolo cinza-azulado escuro'}
POS=['1 (em cima, à esquerda)','2 (em cima, no meio)','3 (em cima, à direita)','4 (embaixo, à esquerda)','5 (embaixo, no meio)','6 (embaixo, à direita)']
rows=[l.rstrip('\n').split('\t') for l in open(__import__('os').environ.get('SUBJ','subjects.tsv'),encoding='utf8') if l.strip()]
n=int(sys.argv[1]); part=rows[n*6:n*6+6]
if sys.argv[2]=='names': print(','.join(r[0] for r in part)); sys.exit()
out=[open('common.txt',encoding='utf8').read().rstrip('\n')]
for i,r in enumerate(part):
    fam=r[1]
    if fam in PAL or '+' in fam:
        cols=' + '.join(PAL[f].split(', fundo')[0] for f in fam.split('+'))
        fundo=PAL[fam.split('+')[0]].split(', ')[-1]
        out.append('- Medalhão %s: %s. Cores: %s; %s.'%(POS[i],r[2],cols,fundo))
    else:
        out.append('- Medalhão %s: %s.'%(POS[i],r[2]))
for i in range(len(part),6):
    out.append('- Medalhão %s: deixe o miolo escuro vazio.'%POS[i])
if len(sys.argv)>3: out.append(open(sys.argv[3],encoding='utf8').read())
print('\n'.join(out))
