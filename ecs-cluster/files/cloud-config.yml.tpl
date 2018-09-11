#cloud-config
bootcmd:
  - echo 'SERVER_ENVIRONMENT=${environment}' >> /etc/environment
  - echo 'SERVER_GROUP=${name}' >> /etc/environment
  - echo 'SERVER_REGION=${region}' >> /etc/environment

  - mkdir -p /etc/ecs
  - echo 'ECS_CLUSTER=${name}' >> /etc/ecs/ecs.config
  - echo 'ECS_ENGINE_AUTH_TYPE=${docker_auth_type}' >> /etc/ecs/ecs.config
  - echo 'ECS_ENGINE_AUTH_DATA=${docker_auth_data}' >> /etc/ecs/ecs.config
  - echo 'ECS_DATADIR=/data' >> /etc/ecs/ecs.config
  - echo 'ECS_ENABLE_TASK_IAM_ROLE=true' >> /etc/ecs/ecs.config
  - echo 'ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true' >> /etc/ecs/ecs.config
  - echo 'ECS_LOGFILE=/log/ecs-agent.log' >> /etc/ecs/ecs.config
  - echo 'ECS_AVAILABLE_LOGGING_DRIVERS=["json-file","awslogs"]' >> /etc/ecs/ecs.config
  - echo 'ECS_LOGLEVEL=info' >> /etc/ecs/ecs.config
