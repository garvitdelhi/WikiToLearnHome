
#adding new keys
for k in $(python read-trusted-users.py $WTL_TRUSTED_KEYS_REPO add)
do
    gpg --import $k
done

#removing keys no more here
for j in $(python read-trusted-users.py $WTL_TRUSTED_KEYS_REPO delete)
do
    gpg --delete-keys $j
done
