#!/bin/bash

echo './rfc.sed -k news'
./rfc.sed -k news
echo
echo './rfc.sed -k News'
./rfc.sed -k News
echo
echo './rfc.sed -k "network news transfer protocol"'
./rfc.sed -k 'network news transfer protocol'
echo
echo './rfc.sed -k "network communication"'
./rfc.sed -k 'network communication'
