.PHONY: merge merge-linux-kernel merge-cpp merge-linux-userspace

default : merge

PY_SCRIPT=merge.py
PATH_LINUX_KERNEL=./linux-kernel-docs/
PATH_LINUX_USERSPACE=./linux-userspace-docs/
PATH_CPP=./cpp/
	
merge-linux-kernel:
	python ${PY_SCRIPT} ${PATH_LINUX_KERNEL}

merge-linux-userspace:
	python ${PY_SCRIPT} ${PATH_LINUX_USERSPACE}

merge-cpp:
	python ${PY_SCRIPT} ${PATH_CPP}

merge: merge-linux-kernel merge-linux-userspace merge-cpp
