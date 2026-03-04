#!/bin/bash
openssl genrsa -out alex.key 2048
openssl req -new -key alex.key -out alex.csr -subj "/CN=alex/O=developers"

openssl genrsa -out grisha.key 2048
openssl req -new -key grisha.key -out grisha.csr -subj "/CN=grisha/O=analysts"
