nohup sudo ssh $SSH_ARGS -ostricthostkeychecking=no $SSH_USER@$1 'sudo chmod +x ~/execute.sh; cd tpcc; ../execute.sh' > /tmp/$1_execute.txt &
