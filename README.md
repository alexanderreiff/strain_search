# StrainSearch

A basic search-as-you-type service using Sinatra and Elasticsearch.

## Setup

1. Install Docker for [Mac](https://download.docker.com/mac/stable/Docker.dmg)/Linux/Windows
2. Run `docker-compose up` from the project directory
3. There is no step 3!

## Some tips
The Elasticsearch index will need to be rebuild after each index setting/analyzer change. The app will perform this at boot. To restart after making changes, run `docker-compose restart app`
