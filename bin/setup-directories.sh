# Create directories
mkdir -p $GITLAB_HOME/config
mkdir -p $GITLAB_HOME/logs
mkdir -p $GITLAB_HOME/data

# Set proper permissions
chmod -R 777 $GITLAB_HOME/data
chmod -R 777 $GITLAB_HOME/logs
chmod -R 777 $GITLAB_HOME/config
