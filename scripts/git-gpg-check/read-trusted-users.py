import sys
import os
from glob import glob

def keys_to_add (folder):
    #loading data
    #walking subdir of key dir
    keys_file = {(y.split('/')[-1].split('-')[-1][:-4]):y
        for x in os.walk(folder) for y in glob(os.path.join(x[0], '*.key'))}
    #key directly in the dir
    for y in glob(folder +'/*.key'):
        keys_file[y.split('/')[-1].split('-')[-1][:-4]] = y
    #now reading the last configs
    active_keys = [l for l in open(folder+'/active-keys','r')]
    keys_to_add = []
    for kp,kf in keys_file.items():
        if kp not in active_keys:
            keys_to_add.append(kf)
            active_keys.append(kp)
    #printing new active keys file
    open(folder+'/active-keys','w').write("\n".join(active_keys))
    print("\n".join(keys_to_add))

def keys_to_delete (folder):
    #loading data
    keys_file = {(y.split('/')[-1].split('-')[-1][:-4]):y
        for x in os.walk(folder) for y in glob(os.path.join(x[0], '*.key'))}
    #key directly in the dir
    for y in glob(folder +'/*.key'):
        keys_file[y.split('/')[-1].split('-')[-1][:-4]] = y
    #now reading the last configs
    active_keys = [l for l in open(folder+'/active-keys','r')]
    keys_to_delete = []
    f = open(folder +'/active-keys', 'w')
    for kp in active_keys:
        if kp not in keys_file:
            keys_to_delete.append(kp)
        else:
            f.write(kp)
    print( "\n".join(keys_to_delete))

if __name__ == '__main__':
    folder = sys.argv[1]
    cmd = sys.argv[2]
    if cmd == 'add':
        keys_to_add(folder)
    elif cmd =='delete':
        keys_to_delete(folder)
