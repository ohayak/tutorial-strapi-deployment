### Docker

```bash
export AWS_PROFILE=<profile>
aws ecr get-login-password | docker login --username AWS --password-stdin 098441577635.dkr.ecr.eu-west-1.amazonaws.com
docker build -t 098441577635.dkr.ecr.eu-west-1.amazonaws.com/strapi-tutorial:latest .
docker push 098441577635.dkr.ecr.eu-west-1.amazonaws.com/strapi-tutorial:latest
```