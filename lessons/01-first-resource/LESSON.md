# Lesson 01: Setup & First Resource 🪣

## 🎯 Mission

The Little Gamestore needs somewhere to keep its brand assets. Your first job is to create a **storage bucket** and upload the shop's **logo** into it, using Terraform only (no clicking in the console).

By the end of this lesson you'll have:
- working credentials for AWS
- a bucket with a globally unique name
- `logo.svg` stored in that bucket
- a full `init → plan → apply → destroy` cycle done

---

## Part 1: AWS

### Step 0: Create AWS access (one time)

For learning, use a dedicated IAM user. Don't use your root account.

1. Sign in to the AWS console as root or as an admin.
2. **IAM → Users → Create user** → name: `terraform-learner`.
3. Permissions: **Attach policies directly** → `AdministratorAccess`.
   *(Broad, but fine for a personal learning account. In real projects you'd use least privilege.)*
4. Open the user → **Security credentials → Create access key** → use case "Command Line Interface (CLI)".
5. In your terminal:
   ```bash
   aws configure --profile gamestore
   # Access key ID:      <paste>
   # Secret access key:  <paste>
   # Default region:     eu-central-1
   # Output format:      json
   ```
6. Check that it works:
   ```bash
   aws sts get-caller-identity --profile gamestore
   ```
   You should see the ARN `arn:aws:iam::<account-id>:user/terraform-learner`.

> 💸 **Recommended:** go to **Billing → Budgets → Create budget → "Zero spend budget"**. AWS will email you as soon as anything costs money.

> 🔐 Never put access keys in `.tf` files. Terraform will read the `gamestore` profile.

### Step 1: Your turn: write the code

Work in `lessons/01-first-resource/aws/`. Create **three files** (Terraform reads every `*.tf` file in the folder, so the file names are only a convention):

#### `versions.tf`: which Terraform and which providers

You need **two providers**:
- `hashicorp/aws` with a version constraint allowing any `6.x`
- `hashicorp/random`: we'll use it to make the bucket name unique

Also require Terraform `>= 1.10`.

```hcl
terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    # TODO: add the random provider (source "hashicorp/random", version "~> 3.6")
  }
}
```

#### `providers.tf`: configure AWS

```hcl
provider "aws" {
  region  = # TODO: eu-central-1
  profile = # TODO: the CLI profile you just created

  default_tags {
    tags = {
      Project   = "the-little-gamestore"
      ManagedBy = "terraform"
      Lesson    = "01"
    }
  }
}
```

#### `main.tf`: the actual resources

Build these three resources yourself. Use the Terraform Registry docs (links below) to find the arguments.

| # | Resource type | Local name | What it should do |
|---|---------------|-----------|--------------------|
| 1 | `random_pet` | `suffix` | Generate a fun 2-word suffix (e.g. `happy-panda`). Hint: `length` |
| 2 | `aws_s3_bucket` | `assets` | Bucket name `little-gamestore-assets-<suffix>` |
| 3 | `aws_s3_object` | `logo` | Upload `assets/logo.svg` into the bucket under key `brand/logo.svg`, with `content_type = "image/svg+xml"` |

Hints:
- To reference another resource's attribute: `<TYPE>.<NAME>.<ATTRIBUTE>`, e.g. `random_pet.suffix.id`
- To build a string, use interpolation: `"little-gamestore-assets-${...}"`
- To point at a local file: `"${path.module}/assets/logo.svg"`
- Bonus: make the object re-upload when the file changes, using `etag = filemd5(...)`

📚 Docs:
- https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object

### Step 2: Run the workflow

```bash
cd lessons/01-first-resource/aws
terraform init       # look at what it downloads, and at the new .terraform.lock.hcl
terraform fmt        # did it change anything?
terraform validate
terraform plan       # how many resources "to add"?
terraform apply
```

Then check your work:
```bash
terraform state list
terraform show
aws s3 ls --profile gamestore
aws s3 ls s3://<your-bucket-name>/brand/ --profile gamestore
```

### Step 3: Experiment (5 min, this is where you learn)

1. Edit `logo.svg` (change a color), then run `terraform plan`. What does Terraform want to do? With `etag` and without it?
2. Change the `Lesson` tag to `"01-test"` and run `plan`. Notice the `~` (update in-place).
3. Change `length` on `random_pet` and run `plan`. Notice `-/+` (replace). Why does the **bucket** get replaced too?

### Step 4: 🧹 Destroy

```bash
terraform destroy
```

> ❓ If destroy fails with `BucketNotEmpty`, think about why. (Hint: did Terraform create everything inside the bucket?) Look up the bucket argument `force_destroy`.

**When you're done, tell me and paste your `main.tf`, and I'll review it.** After that you get the theory and exam corner for this part.

---

## Part 2: STACKIT

*(Next session.)*
