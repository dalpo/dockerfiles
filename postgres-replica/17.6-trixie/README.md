# Postgres replica Docker image

## Required environment variables

```bash
$PG_REP_HOSTNAME=1.2.3.4
$PG_REP_PORT=5432
$PG_REP_USERNAME=replicator
$PG_REP_PASSWORD=S3cr3tP4$$w0rd
```

## Tips & tricks

Skip the entrypoint for debugging:

```
docker run -it --entrypoint /bin/bash [docker_image]
```
