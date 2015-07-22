#!/bin/bash

appledoc -h --project-name InfoStats2 --project-company "Matchstic" --company-id com.matchstic -t ./Appledoc_template --output ./help --ignore .m --ignore MediaRemote.h --ignore .mm --no-create-docset ./InfoStats2
