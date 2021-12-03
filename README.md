# Packer automation example


<i> Since I've played with Packer, and it didn't allow me to grab my AMI ID that easily when deploying with Terraform... </i> 

For a modular and less hardcoded approach, go and check <a href="https://github.com/Floriquek/Pac2">Pac2</a>


Requirements:

> you have setup a vpc and a subnet 

> you have setup a pem key

<b> Steps </b> 



<b> [ 1 ] Clone repository:</b>
```
 root@kek:/home/wrenchie# git clone https://github.com/Floriquek/Pac1.git
 ```
 
 
<b> [ 2 ] Build Packer AMI with Terraform (folder packer_terraform) - init, plan and apply</b>

```
 root@kek:/home/wrenchie# cd Pac1/
 root@kek:/home/wrenchie/Pac1# cd packer_terraform/
 root@kek:/home/wrenchie/Pac1/packer_terraform# terraform init 
 [ ... snip ... ]
 ```
 ```
 root@kek:/home/wrenchie/Pac1/packer_terraform# terraform plan
   + create

Terraform will perform the following actions:

  # null_resource.packer will be created
  + resource "null_resource" "packer" {
      + id = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

[ ... snip  ... ]
```
At "terraform apply", check if file "amihost.tfvars" is created:

```
 root@kek:/home/wrenchie/Pac1/packer_terraform# terraform apply
 
 [ ... snip ... ]
 
null_resource.packer: Creating...
null_resource.packer: Provisioning with 'local-exec'...
null_resource.packer (local-exec): Executing: ["/bin/sh" "-c" "\n\tpacker build aws-ubuntu.pkr.hcl | tee output_packer\n\n\tif [ $? -eq 0 ]; then\n  \t\tprintf \"good...creating the new_image and amihost.tfvars files\"\n\t\tcat output_packer | tail -n2 | awk 'NR==1{print $2}' > new_image\n                sed -e 's/.*/\\\"&\\\"/' -e  's/^/ami_host = /g' new_image  > amihost.tfvars\n\n\telse\n  \t\tprintf \"errors... exiting...\" \n  \t\texit 1\n\tfi\n"]


 
 [ .... snip .... if no error ... you should notice following output when completed... snip ... ]

null_resource.packer (local-exec): ==> Wait completed after 3 minutes 22 seconds

null_resource.packer (local-exec): ==> Builds finished. The artifacts of successful builds are:
null_resource.packer (local-exec): --> learn-packer.amazon-ebs.ubuntu: AMIs were created:
null_resource.packer (local-exec): us-east-2: ami-03f74c213ed9defce

null_resource.packer (local-exec): good...creating the new_image and amihost.tfvars files
null_resource.packer: Creation complete after 3m24s [id=4272288445061974220]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.


```

You should by now have a new AMI that can be used for a future deploy:

```
root@kek:/home/wrenchie/Pac1/packer_terraform#  aws ec2 describe-images --region us-east-2  --owners=self |\
>  jq -r '.Images[] | "\(.ImageId)\t\(.Name)\t\(.State)"'
ami-03f74c213ed9defce   12learn-packer-linux-aws        available
root@kek:/home/wrenchie/Pac1/packer_terraform#

```

Check to see if the files <i> new_image </i> and <i> amihost.tfvars </i> were created:

```
root@kek:/home/wrenchie/Pac1/packer_terraform# cat new_image
ami-03f74c213ed9defce
root@kek:/home/wrenchie/Pac1/packer_terraform# cat amihost.tfvars
ami_host = "ami-03f74c213ed9defce"

```

Now you can proceed with testing the new AMI by deploying an EC2 with Terraform



<b>[ 3 ] Test the new AMI with the .tfvars file we created previously:</b>


Go to folder test_packer:

```
root@kek:/home/wrenchie/Pac1/packer_terraform# cd ../test_packer/
root@kek:/home/wrenchie/Pac1/test_packer#
```

Proceed with initializing the backened...

```
root@kek:/home/wrenchie/Pac1/test_packer# terraform init
```

Check resources that will be deployed, by adding the tfvars file which will provide the ami for instance - <i> check instance.tf for more details </i> (the amihost.tfvars that we created at previous step):

```
root@kek:/home/wrenchie/Pac1/test_packer#  terraform plan -var-file=../packer_terraform/amihost.tfvars

```

Deploy with same file:

```
root@kek:/home/wrenchie/Pac1/test_packer#   terraform apply -var-file=../packer_terraform/amihost.tfvars
[....]

aws_instance.example: Creation complete after 1m26s [id=i-00494b40034b7bbc8]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

public_ip = "3.135.217.22"


```
Check if you can login:

```
root@kek:/home/wrenchie/Pac1/test_packer# get_in=$(terraform output | awk {'print $3'} | sed 's/"//g')
root@kek:/home/wrenchie/Pac1/test_packer# echo $get_in
3.135.217.22
root@kek:/home/wrenchie/Pac1/test_packer#
root@kek:/home/wrenchie/Pac1/test_packer# ssh -i ~/.aws/pems/key-pair-example.pem ubuntu@$get_in
Welcome to Ubuntu 16.04.7 LTS (GNU/Linux 4.4.0-1128-aws x86_64)

[ ... snip ... ]

ubuntu@ip-10-0-0-40:~$

```

So, we deployed a new instance by using a Packer AMI, both case scenarios with the help of Terraform



<i> Fini!  </i> 
