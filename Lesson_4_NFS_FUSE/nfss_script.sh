# Start and enable services.
for i in firewalld rpcbind nfs-server nfs-lock nfs-idmap; do
    systemctl start $i
    systemctl enable $i
done

# Configure firewall.
firewall-cmd --zone=public --add-interface=eth1 --permanent
for i in nfs nfs3 rpc-bind mountd; do
    firewall-cmd --add-service=$i  --permanent
done
firewall-cmd --reload
     
# Create folder for sharing.
mkdir -p /mnt/nfs/
chown -R nfsnobody:nfsnobody /mnt/nfs
chmod -R 777 /mnt/nfs

# Add alias for servers.
echo -e "192.168.50.10 nfss" >> /etc/hosts
echo -e "192.168.50.11 nfsc" >> /etc/hosts

# Export nfs.
echo "/mnt/nfs/ nfsc(rw,async,no_root_squash,no_subtree_check)" >> /etc/exports
exportfs -ra