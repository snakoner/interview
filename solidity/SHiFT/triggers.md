### before testing event trigger
Need to run event service:
```
cd ~/Desktop/shift/triggers/src
poetry env activate
source /Users/andrejstroganov/Library/Caches/pypoetry/virtualenvs/triggers-Cpqd3AL9-py3.11/bin/activate
source /Users/andrejstroganov/Desktop/shift/triggers/rpcs.sh
python events/app.py
```

### snapshot example
```python
class AbracadabraProposals(SnapshotProposal):
    id = "e7bbfbcc-fece-4bf4-a153-1ad92d8373f6"
    space = "abracadabrabymerlinthemagician.eth"


from datetime import datetime

t = AbracadabraProposals()
raw = t.collect_raw_data(1741787619)
pre = t.precompute_data(raw)
result = t.trigger_rule(pre)

print(result)
```

```
10518  export PYTHONPATH=/Users/andrejstroganov/Desktop/shift/triggers
10519  ls
10520  poetry --help
10521  brew install poetry
10522  ls
10523  poetry install
10524  ls
10525  python
10526  poetry install
10527  poetry env use 3.11
10528  poetry install
10529  python src/triggers/snapshots.py
10530  ls
10531  cd src
10532  python triggers/snapshots.py
10533  cd ..
10534  pwd
10535  export PYTHONPATH=/Users/andrejstroganov/Desktop/shift/triggers
10536  cd src
10537  python triggers/snapshots.py
10538  ls
10539  pwd
10540  export PYTHONPATH=/Users/andrejstroganov/Desktop/shift/triggers/src
10541  python triggers/snapshots.py
10542  LS
10543  ls
10544  cd ..
10545  ls
10546  poetry shell
10547  poetry env activate
10548  ls
10549  cd src
10550  python triggers/snapshots.py
10551  python
10552  cd ..
10553  poetry env activate
10554  /Users/andrejstroganov/Library/Caches/pypoetry/virtualenvs/triggers-Cpqd3AL9-py3.11/bin/activate
10555  chmod +x /Users/andrejstroganov/Library/Caches/pypoetry/virtualenvs/triggers-Cpqd3AL9-py3.11/bin/activate
10556  /Users/andrejstroganov/Library/Caches/pypoetry/virtualenvs/triggers-Cpqd3AL9-py3.11/bin/activate
10557  source /Users/andrejstroganov/Library/Caches/pypoetry/virtualenvs/triggers-Cpqd3AL9-py3.11/bin/activate
10558  python
10559  ls
10560  cd src
10561  ls
10562  python triggers/snapshots.py
10563  clear
10564  ls
10565  python triggers/snapshots.py
10566* clear
10567* ls
10568* clear
10569* l
10570  python triggers/snapshots.py
```


### Event trigger

```python

from datetime import datetime

t = SdeusdPermissionedSwapper()
# raw = t.collect_raw_data(int(datetime(year=2025, month=3, day=14).timestamp()))
raw = t.collect_raw_data(1733770139)
pre = t.precompute_data(raw)
print(raw)
print(pre)

```
