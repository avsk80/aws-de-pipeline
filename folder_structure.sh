mkdir -p ./lambda/src && \
mkdir -p ./terraform/modules/network && \
mkdir -p ./terraform/modules/s3 && \
mkdir -p ./terraform/envs/dev && \
mkdir -p ./terraform/envs/qa && \
mkdir -p ./terraform/envs/prod && \

touch ./lambda/src/handler.py && \

touch ./terraform/modules/network/main.tf && \
touch ./terraform/modules/network/variables.tf && \
touch ./terraform/modules/network/outputs.tf && \

touch ./terraform/modules/s3/main.tf && \
touch ./terraform/modules/s3/variables.tf && \
touch ./terraform/modules/s3/outputs.tf && \

touch ./terraform/envs/dev/main.tf && \
touch ./terraform/envs/dev/variables.tf && \
touch ./terraform/envs/dev/backend.tf && \
touch ./terraform/envs/dev/dev.tfvars && \

touch ./terraform/envs/qa/main.tf && \
touch ./terraform/envs/qa/variables.tf && \
touch ./terraform/envs/qa/backend.tf && \
touch ./terraform/envs/qa/qa.tfvars && \

touch ./terraform/envs/prod/main.tf && \
touch ./terraform/envs/prod/variables.tf && \
touch ./terraform/envs/prod/backend.tf && \
touch ./terraform/envs/prod/prod.tfvars