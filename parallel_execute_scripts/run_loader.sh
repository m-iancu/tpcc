nohup ssh $SSH_ARGS -ostricthostkeychecking=no $SSH_USER@$1 'sudo chmod +x ~/loader.sh; cd tpcc; ../loader.sh' > /tmp/$1_loader.txt &
sleep 2
