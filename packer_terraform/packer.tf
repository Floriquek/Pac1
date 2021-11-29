resource "null_resource" "packer" {

  provisioner "local-exec" {
    command = <<EOF

	packer build aws-ubuntu.pkr.hcl | tee output_packer

	if [ $? -eq 0 ]; then
  		printf "good...creating the new_image and amihost.tfvars files"
		cat output_packer | tail -n2 | awk 'NR==1{print $2}' > new_image
                sed -e 's/.*/\"&\"/' -e  's/^/ami_host = /g' new_image  > amihost.tfvars

	else
  		printf "errors... exiting..." 
  		exit 1
	fi
	EOF
  }
}

