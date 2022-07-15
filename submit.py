#!/usr/bin/env python
"""
I wrapper to execute commands the slurm interface on the CNAG cluster
without the need to write submission files
"""


from __future__ import print_function, division
import sys, os, re
import argparse
import subprocess
import uuid

def create_submission_script(cmd, name, initialDir, stdout, stderr,\
                             wallClockLimit, totalTasks, cpusPerTask, \
                             partition, priority, target):
    job=''
    shebang="#!/bin/bash\n"
    classPrefix='#@'
    
    jname=          '{} job_name = {}\n'.format(classPrefix, name)
    jinitialDir=    '{} initialdir = {}\n'.format(classPrefix, initialDir)
    jstdout=        '{} output = {}_%j\n'.format(classPrefix, stdout)
    jstderr=        '{} error = {}_%j\n'.format(classPrefix, stderr)
    jwcl=           '{} wall_clock_limit = {}\n'.format(classPrefix, wallClockLimit)
    jtt=            '{} total_tasks = {}\n'.format(classPrefix, totalTasks)
    jcpt=           '{} cpus_per_task = {}\n'.format(classPrefix, cpusPerTask)
    jpartition=     '{} partition = {}\n'.format(classPrefix, partition)
    jpriority=      '{} class = {}\n'.format(classPrefix, priority)
    
    cmd=            '{}'.format(cmd)
    
    job="".join([shebang, jname, jinitialDir, jstdout, \
                jstderr, jwcl, jtt, jcpt, jpartition, jpriority, cmd])
    
    print(job, file=target)
    return True

if __name__ == '__main__':

    #define defaults
    name=           'job'
    target=         os.path.join(os.path.expanduser("~"), "cluster_jobs")
    if not os.path.exists(target):
        os.makedirs(target)
    target=         os.path.join(target, name+"_"+str(uuid.uuid4()))

    initialDir=     os.getcwd()
    stdout=         target+'.out'
    stderr=         target+'.err'
    wallClockLimit= '10:00:00'
    totalTasks=     '1'
    cpusPerTask=    '1'
    partition=      'main'

    #parse arguments
    parser = argparse.ArgumentParser(prog='PROG',
                                    formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('-c','--command', type=str)
    parser.add_argument('-n','--name', type=str, default=name)
    parser.add_argument('-i','--initialDir', type=str, default=initialDir)
    parser.add_argument('-o','--stdout', type=str, default=stdout)
    parser.add_argument('-e','--stderr', type=str, default=stderr)
    parser.add_argument('-w','--wallClockLimit', type=str, default=wallClockLimit)
    parser.add_argument('-t','--totalTasks', type=str, default=totalTasks)
    parser.add_argument('-u','--cpusPerTask', type=str, default=cpusPerTask)
    parser.add_argument('-p','--partition', type=str, default=partition)
    parser.add_argument('-r', '--priority', type=str, default='normal')
    parser.add_argument('-g','--target', type=str, default=target)
    args=parser.parse_args()
    
    #check if were given a command string to execute
    if not args.command:
        print('I need something to execute...exiting')
        sys.exit(1)

    #open output file
    with open(args.target, 'w') as targetfh:
        create_submission_script(cmd=args.command, name=args.name, initialDir=args.initialDir, \
                                 stdout=args.stdout, stderr=args.stderr, \
                                 wallClockLimit=args.wallClockLimit,\
                                 totalTasks=args.totalTasks, cpusPerTask=args.cpusPerTask,\
                                 partition=args.partition, priority=args.priority,\
                                 target=targetfh)

    cmd='mnsubmit {}'.format(args.target)
    
    try:
        subprocess.check_call([cmd], shell=True)
    except:
        print("FAILED!\nexiting: {}".format('mnsubmit {}'.format(target)))
