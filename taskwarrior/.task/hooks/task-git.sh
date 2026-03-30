#!/bin/bash

# Get task command
TASK_COMMAND="task ${@}"
# Get data dir
DATA_RC=$(task _show | grep data.location)
DATA=(${DATA_RC//=/ })
DATA_DIR=${DATA[1]}
if [ ! -d "$DATA_DIR" ]; then
  echo 'Could not load data directory!'
  exit 1
fi

# Call task and commit changes.
command task $@
cd $DATA_DIR
git add .
git commit -m "$TASK_COMMAND" > /dev/null
exit 0
