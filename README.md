Tactic - Awesome Time Tracking Application
================

Tactic Backend

## Setup

```
docker-compose build
```

# Restore DB

```
docker-compose up
docker-compose exec db sh
pg_restore -U postgres --no-owner -d tactic_development dumps/20220211.dump
```
