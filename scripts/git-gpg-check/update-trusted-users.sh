
#adding new keys
echo "Adding new keys:"
for k in $(python read-trusted-users.py $WTL_TRUSTED_KEYS_REPO add)
do
    echo "   #${k}"
    gpg --import $k
done

#removing keys no more here
echo "Removing keys:"
for j in $(python read-trusted-users.py $WTL_TRUSTED_KEYS_REPO delete)
do
    echo "    #${k}"
    gpg --delete-keys $j
done
