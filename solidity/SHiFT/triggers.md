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
// can be usefull
// poetry add redis <- if problems with import (e.g. multicall)
10527  poetry env use 3.11
10540  export PYTHONPATH=/Users/andrejstroganov/Desktop/shift/triggers/src
10547  poetry env activate
10557  source /Users/andrejstroganov/Library/Caches/pypoetry/virtualenvs/triggers-Cpqd3AL9-py3.11/bin/activate
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


### after approve
1. merge (no access now)
2. pipeline
3. deploy to prod
4. test manually in backoffice
5. write to `defi-workspace`: '@Defi_auditor [ref]name triggers[/ref] are done. Pls, verify.'
