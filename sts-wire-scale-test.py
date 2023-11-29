#!/usr/bin/python3

import sys
import argparse
import subprocess
import configparser

if __name__ == '__main__' :

    parser = argparse.ArgumentParser()
    parser.add_argument('-clients','--num_clients',dest='clients',help='insert number of clients to test sts-wire (4*)')
    parser.add_argument('-fsize','--file_size',dest='fsize',help='insert file size (10 MB or 1 GB)')
    parser.add_argument('-bsize','--block_size',dest='bsize',help='insert block size (4 kB or 4 MB)')
    
    try:
        args = parser.parse_args()
    except argparse.ArgumentError as e:
        print(f"Errore negli argomenti: {e}")
        sys.exit(1)

    config = configparser.ConfigParser()
    config.read('sh_scripts.cfg')
    start_containers = config.get('start/stop containers','start')
    stop_containers = config.get('start/stop containers','stop')

    #start containers, takes in input the number of client ($1) 
    cmd=(f'./{start_containers} {args.clients}')
    proc=subprocess.run(cmd,shell=True,check=False)

    #Run fio tests
    for option in config.options('fio tests'):
        fio_test=config.get('fio tests',option)
        cmd=(f'./{fio_test} {args.clients} {args.fsize} {args.bsize}')
        proc=subprocess.run(cmd,shell=True,check=False)
    
    #Convert fio output
    for option in config.options('fio output'):
        fio_conv=config.get('fio output',option)
        cmd=(f'./{fio_conv} {args.clients}')
        proc=subprocess.run(cmd,shell=True,check=False)

    #stop the containers 
    cmd=(f'./{stop_containers} {args.clients}')
    proc=subprocess.run(cmd,shell=True,check=False)

