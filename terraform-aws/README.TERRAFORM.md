## Terraform Setup Guide for AWS Free Tier (t2.micro Instances)

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

# Initialize Terraform

terraform init

# Preview changes

terraform plan

# Apply configuration without asking for the confimation

terraform apply -auto-approve
