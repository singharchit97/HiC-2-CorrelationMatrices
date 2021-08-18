#!/bin/bash
set -e
#recommended: setting up conda environment for easy installation of packages
#you can skip the below three commands & install the packages manually yourself
echo -e
echo -e "### This Program Generates Pearson's Correlation-HiC matrices from Observed Data ###\n"
echo -e "### Please proceed only if you have the required input.hic/ input.mcool file ###\n"
echo -e "### Enter (0) if you want to continue OR any other character to terminate ###\n"
read -p "Enter your choice:" usr_inp
echo -e
echo -e "You entered: $usr_inp\n"
b=0
if [ $usr_inp == $b ]
then
    echo -e "*** Enter (1) if you want to setup anaconda and install the packages automatically (connection to the internet required) ***\n"
    echo -e "*** Enter any other chracter if you have already setup the environment ***\n"
    read -p "Enter your choice:" user_input
    echo -e
    echo -e "You entered: $user_input\n"
    a=1
    if [ $user_input == $a ]
    then
        #download the latest anaconda shell script to install and follow the steps
        read -p "Enter the link for downloading anaconda shell script:" link
        echo -e
        wget $link
        read -p "Enter the name of the downloaded anaconda shell script:" shell
        echo -e
        bash $shell
        #press enter & type yes where required during the process of installation
        #activate base environment to check if conda installed properly
        echo -e
        eval "$(conda shell.bash hook)"
        conda activate base
        #should get the base environment loaded up
        
        #now create environment for hic-explorer and install the required packages
        #below command will downlaod all the required packages in the environment called "hic_analysis"
        read -p "Enter the name you want to give to your Environment:\n" env_name
        echo -e
        echo -e "Downloading & Installing HiC-Explorer Package in the $env_name Environment..."
        echo -e
        eval "$(conda shell.bash hook)"
        conda create --name $env_name hicexplorer=3.6 python=3.8 -c bioconda -c conda-forge
        echo -e
        echo -e "*** Package Downloaded ***"
        echo -e
        echo -e "Activating Environment..."
        eval "$(conda shell.bash hook)"
        conda activate $envname
        echo -e
        echo -e "*** Environment Activated ***"
        #now the hic_analysis envoironment is activated & contains only the dependencies and python scripts for hic-explorer program
        #next install cooler python package in hic_analysis environment
        echo -e "Downloading & Installing Cooler Package in the $env_name Environment..."
        echo -e
        eval "$(conda shell.bash hook)"
        conda install -c conda-forge -c bioconda cooler
        #now you have both the packages in the same environment
        conda list
        echo -e
        #if you have a .cool file already, then skip the next command
        #hicConvert to convert .hic file to .cool file for downstream analysis
        echo -e "*** Setup a working directory ***"
        echo -e
        #creating new folder to store the files
        read -p "Enter name of folder you want to create (this will be your working directory):\n" wd
        mkdir $wd
        cd $wd
        echo -e "What is your input file extension?\n"
        echo -e
        echo -e "1: hic"
        echo -e "2: mcool"
        echo -e
        read -p "Your Input: " ext_file
        x=1
        if [ $ext_file == $x ]
        then
            read -p "Enter the name of the input.hic file: " file1
            echo -e
            read -p "Enter the name of the output.cool file: " file2
            echo -e
            read -p "Enter the resolution you want for the output data: " res
            echo -e
            echo -e "Running hicConvertFormat Program...\n"
            hicConvertFormat -m $file1 --inputFormat hic --outputFormat cool -o $file2 --resolutions $res
            echo -e
            echo -e "*** Run Complete ***"
            echo -e
            echo -e "Find $file2 in:"
            pwd
            
        else
            read -p "Enter the name of the input.mcool file: " file1
            echo -e
            read -p "Enter the name of the output.cool file: " file2
            echo -e
            read -p "Enter the resolution you want for the output data: " res
            echo -e
            echo -e "Running hicConvertFormat Program...\n"
            hicConvertFormat -m $file1 --inputFormat mcool --outputFormat cool -o $file2 --resolutions $res
            echo -e
            echo -e "*** Run Complete ***"
            echo -e
            echo -e "Find $file2 in:"
            pwd
        fi
        
        #now running the commands in a loop for each chromosome comparison- inter & intra-chromosomal
        echo -e
        echo -e "Enter the name of the output.cool file from hicConvertFormat Program: \n"
        echo -e
        read -p "File name: " file3
        echo -e
        echo -e "*** Proceeding to run to hicTransform Program ***"
        echo -e
        echo -e "*** Running Program for All Chromosomes ***"
        echo -e
        x="$(seq -s ' ' 1 22)"
        for i in $x
        do
            for j in $(seq $i 22)
            do
                echo -e "Analyzing:"
                echo -e "Chromosome $i"
                echo -e "Chromosome $j"
                echo -e
                #below command creates pearson's correlation matrix for the chromosomes
                #change the name of the output files accordingly
                hicTransform -m $file3 --method pearson --"chromosomes" $i $j -o "GM12878_chr"$i"_"$j"_pearson_100000.cool"
                #below command extracts the correlation matrix to a .txt file which is easier to manipulate
                #change the name of the input/ output files accordingly
                cooler dump --join "GM12878_chr"$i"_"$j"_pearson_100000.cool" > "GM12878_chr"$i"_"$j"_pearson_100kb.txt"
            done
        done
        echo -e "### Program Run Complete ###"
        echo -e
        echo -e "All files are stored in: "
        pwd
        echo -e
    else
        read -p "Enter the name of your Environment (with all dependencies installed): " env_name
        echo -e
        echo -e "*** Activating Conda Environment... ***"
        eval "$(conda shell.bash hook)"
        conda activate $env_name
        #conda activate $envname
        echo -e
        echo -e "*** Environment Activated ***"
        echo -e
        #hicConvert to convert .hic/.mcool file to .cool file for downstream analysis
        echo -e "*** Setup a working directory ***"
        echo -e
        #creating new folder to store the files
        read -p "Enter name of folder you want to create (this will be your working directory): " wd
        mkdir $wd
        cd $wd
        echo -e
        echo -e "What is your input file extension?\n"
        echo -e
        echo -e "1: hic"
        echo -e "2: mcool"
        echo -e
        read -p "Your Input: " ext_file
        x=1
        if [ $ext_file == $x ]
        then
            read -p "Enter the name of the input.hic file: " file1
            echo -e
            read -p "Enter the name of the output.cool file: " file2
            echo -e
            read -p "Enter the resolution you want for the output data: " res
            echo -e
            echo -e "Running hicConvertFormat Program...\n"
            hicConvertFormat -m $file1 --inputFormat hic --outputFormat cool -o $file2 --resolutions $res
            echo -e
            echo -e "*** Run Complete ***"
            echo -e
            echo -e "Find $file2 in:"
            pwd
            
        else
            read -p "Enter the name of the input.mcool file: " file1
            echo -e
            read -p "Enter the name of the output.cool file: " file2
            echo -e
            read -p "Enter the resolution you want for the output data: " res
            echo -e
            echo -e "Running hicConvertFormat Program...\n"
            hicConvertFormat -m $file1 --inputFormat mcool --outputFormat cool -o $file2 --resolutions $res
            echo -e
            echo -e "*** Run Complete ***"
            echo -e
            echo -e "Find $file2 in:"
            pwd
        fi
        
        
        #now running the commands in a loop for each chromosome comparison- inter & intra-chromosomal
        echo -e
        echo -e "Enter the name of the output.cool file from hicConvertFormat Program:"
        echo -e
        read -p "File name: " file3
        echo -e
        echo -e "*** Proceeding to run to hicTransform Program ***"
        echo -e
        echo -e "*** Running Program for All Chromosomes ***"
        echo -e
        x="$(seq -s ' ' 1 22)"
        for i in $x
        do
            for j in $(seq $i 22)
            do
                echo -e "Analyzing:"
                echo -e "Chromosome $i"
                echo -e "Chromosome $j"
                echo -e
                #below command creates pearson's correlation matrix for the chromosomes
                #change the name of the output file accordingly
                hicTransform -m $file3 --method pearson --"chromosomes" $i $j -o "GM12878_chr"$i"_"$j"_pearson_100000.cool"
                #below command extracts the correlation matrix to a .txt file which is easier to manipulate
                #change the name of the input/output file accordingly
                cooler dump --join "GM12878_chr"$i"_"$j"_pearson_100000.cool" > "GM12878_chr"$i"_"$j"_pearson_100kb.txt"
            done
        done
        echo -e "### Program Run Complete ###"
        echo -e
        echo -e "All files are stored in: "
        pwd
    fi
else
    echo -e "### Program has terminated ###"
    exit
fi
