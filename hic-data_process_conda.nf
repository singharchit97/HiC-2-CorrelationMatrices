#!/usr/bin/env nextflow

params.hic = file('4DNFI1OUWFSC.hic')

process hic2cool {
    conda '/home/shaon/antoni/ARCHIT/hic_analysis.yml'

    output:
    file '*.cool' into coolFile_ch

    script:
    """
    hicConvertFormat -m ${params.hic} --inputFormat hic --outputFormat cool -o out.cool --resolutions 500000
    """
}

process pearsonMatrices_cool {
    conda '/home/shaon/antoni/ARCHIT/hic_analysis.yml'

    input:
    file y from coolFile_ch

    output:
    file 'GM12878_chr*_*_pearson_500000.cool' into txtFile_ch

    shell:
    '''
    x="$(seq -s ' ' 1 22)"
        for i in $x
        do
            for j in $(seq $i 22)
            do
                hicTransform -m !{y} --method pearson --"chromosomes" $i $j -o "GM12878_chr"$i"_"$j"_pearson_500000.cool"
            done
        done
    '''
}

process pearsonMatrices_txt{
    conda '/home/shaon/antoni/ARCHIT/hic_analysis.yml'

    input:
    file z from txtFile_ch

    output:
    file 'GM12878_chr*_*_pearson_500kb.txt' into final_ch

    shell:
    '''
    x="$(seq -s ' ' 1 22)"
        for i in $x
        do
            for j in $(seq $i 22)
            do
                cooler dump --join !{z} > "GM12878_chr"$i"_"$j"_pearson_500kb.txt"
            done
        done
    echo -e "### Pipeline Run Complete ###"
    '''
}

final_ch.subscribe { it.copyTo("./") }
