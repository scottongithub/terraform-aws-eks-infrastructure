# Terraform-aws-eks Infrastructure and Cluster
A Terraform script that creates the necessary infrastructure for an AWS EKS cluster. The module [terraform-aws-eks](terraform-aws-modules/eks/aws) is then called and a cluster is created. The default setup has one worker node (`m4.large`) in a public subnet. Parameters are configurable in `variables.tf`. An AWS ElasticSearch instance is available as well (disabled by default), also with parameters configurable in `variables.tf`

## Prerequisites
* `terraform`, configured to use the `aws` provider, with AWS IAM permissions to create/delete all included resources
* `aws-iam-authenticator` for authenticating to the cluster
* `kubectl` for testing/usage

## Usage
Review/edit `variables.tf`. The default setup provides a public-facing EKS Kubernetes cluster with 2 nodes: one master-node and one worker-node @ `m4.large`. The `terraform-aws-eks` module's `local.tf` has variables that control many attributes of the worker nodes - they can be overridden by placing the desired key:value in the `workers_group_defaults` map in the stanza that calls the module  

Execute `terraform init`, `terraform plan`, `terraform apply`

Once `terraform apply` has completed it will leave the kubeconfig file in the working directory by default. It can then be copied to a directory that kubectl is watching, or alternatively the configuration output path can be specified as the value of `config_output_path` when the module is called

`kubectl` should now be interacting with the cluster
