.PHONY: merge merge-linux-kernel merge-cpp merge-linux-userspace

default : merge

PY_SCRIPT=merge.py
PATH_LINUX_KERNEL=./linux-kernel-docs/
PATH_GENERAL=./general/
PATH_CPP=./cpp/
	
merge-linux-kernel:
	python ${PY_SCRIPT} ${PATH_LINUX_KERNEL}

merge-general:
	python ${PY_SCRIPT} ${PATH_GENERAL}

merge-cpp:
	python ${PY_SCRIPT} ${PATH_CPP}

merge: merge-linux-kernel merge-general merge-cpp
