## Terraform Setup Guide to provision the infrastructure on AWS

### Step 1: Install Terraform

### Step 2: Configure AWS Credentials

Ensure you have an AWS account and configure credentials:

```bash
aws configure
```

**After Entering the the above command:**

1. Enter Access Key
2. Secret Key, Region
3. Output format (json)

### Check the version of aws

```bash
aws --version
```

### Initialize Terraform

```bash
terraform init
```

### Preview changes

```bash
terraform plan
```

### Apply configuration without asking for the confirmation

```bash
terraform apply --auto-approve
```

### Destory the infrastructure without asking for the confirmation

```bash
terraform destroy --auto-approve
```
