#! /bin/bash

kind create cluster --name demo --config ~/panoptica/lab/kind-config.yaml --image="kindest/node:v1.23.10@sha256:f047448af6a656fae7bc909e2fab360c18c487ef3edc93f06d78cdfd864b2d12"
