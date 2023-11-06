# sts-wire-scale-tests



## Getting started

This repo includes scripts and configuration files to perform sts-wire scalability tests.

## Parameters

| Num of clients | Block size | File size | Software
| -------- | -------- | -------- | -------- |
|   1   | 4 kB     | 10 MB     | STS-wire
|   4 | 4 MB  |  1 GB | s3cmd
|  16
| 64
| 256


## Requirements 

- [ ] Py script for executing tests with FIO + baltig.infn.it:4567/fornari/sts-wire-scale-tests/sts-wire:rados (docker image for preparing env)
- [ ] Prepare gitLab CI/CD for execution and monitoring 
    - [ ] Create ssh key and add to client nodes
- [ ] Collect metrics and display visualization
