version ?= 0.0.0-pre.0

ci: clean deps lint package

clean:
	rm -rf logs/ stage/
stage:
	mkdir -p stage/

package:
	rm -rf stage
	mkdir -p stage
	tar \
	    --exclude='.git*' \
	    --exclude='.librarian*' \
	    --exclude='.tmp*' \
			--exclude='.yamllint' \
	    --exclude='stage*' \
	    --exclude='.idea*' \
	    --exclude='.DS_Store*' \
	    --exclude='logs*' \
	    --exclude='*.retry' \
	    --exclude='*.iml' \
	    -cvf \
	    stage/devopsnetworks-iac-$(version).tar ./
	gzip stage/evopsnetworks-iac-$(version).tar

################################################################################
# Code styling check and validation targets:
# - lint Ansible inventory and playbook files
# - check shell scripts
################################################################################

lint:
	 yamllint \
	   conf/ansible/inventory/group_vars/*.yaml \
	   provisioners/ansible/playbooks/*.yaml \
	   templates/cloudformation/*.yaml
	shellcheck scripts/*.sh
	for playbook in provisioners/ansible/playbooks/*.yaml; do \
		ANSIBLE_LIBRARY=conf/ansible/library ansible-playbook -vvv $$playbook --syntax-check; \
	done
	
# resolve dependencies from remote artifact registries
deps: stage
	pip3 install -r requirements.txt


################################################################################
# AWS resources targets.
################################################################################
create-static-website:
	./scripts/create-static-website.sh static-website "$(stack_prefix)" "$(website)" "$(config_path)"

delete-static-website:
	./scripts/delete-static-website.sh static-website "$(stack_prefix)" "$(website)" "$(config_path)"


.PHONY: stage lint deps static-website
