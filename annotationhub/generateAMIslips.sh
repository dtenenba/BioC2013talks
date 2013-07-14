#!/bin/bash

for i in `cat instance_ids.txt`
do
	echo
	echo "--------"
	echo "AnnotationHubServer hostname: $i"
	echo "URL to shell: http://$i:4200"
	echo "login: ubuntu"
	echo "password: bioc"
	echo "AnnotationHubServer hostname: http://$i"
	echo
done