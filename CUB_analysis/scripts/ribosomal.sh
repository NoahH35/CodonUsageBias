#!/bin/bash

level=$1
curl 'https://data.orthodb.org/current/search?query=ribosomes&level='$level -L -o ribosomes.tsv