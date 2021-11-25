#!/bin/bash

apt-get update && apt-get install python-certbot-apache -y && yes 1 | certbot --apache -d your.domain.com
