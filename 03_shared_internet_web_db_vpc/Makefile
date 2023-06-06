.PHONY: init plan apply destroy check

init: 
	@terraform init

plan: check
	@terraform plan

apply: check
	@terraform apply
	@mkdir -p .ssh
	@terraform output -raw ssh_private_key > .ssh/sshkey
	@chmod 600 .ssh/sshkey
	@terraform output -raw ssh_public_key > .ssh/sshkey.pub
	@chmod 644 .ssh/sshkey.pub

destroy: check
	@terraform destroy

check:
	@terraform fmt -recursive
	@terraform fmt -check
	@terraform validate
