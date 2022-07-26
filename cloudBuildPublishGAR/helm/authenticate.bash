#!/usr/bin/env bash

gcloud auth application-default print-access-token | helm registry login -u oauth2accesstoken \
--password-stdin https://us-docker.pkg.dev