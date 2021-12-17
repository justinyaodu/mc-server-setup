# Default server directory.
# The minecraft-server service will start this server.
default_server=''

# When a server directory is specified with a relative path, use this as the base directory.
servers_dir='/var/minecraft'

# JVM arguments.
jvm_args=(-XX:+UseZGC -Xmx8G)

# Minecraft arguments.
mc_args=(--nogui)

# Filename of the server JAR in each server directory.
server_jar='server.jar'

# Filename for the optional server-specific config in each server directory.
server_config='config.sh'

# tmux session name.
session_name='minecraft-server'
